import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const _defaultRoots = ['lib'];

final _excludedPathParts = [
  '${Platform.pathSeparator}l10n${Platform.pathSeparator}',
  '${Platform.pathSeparator}generated${Platform.pathSeparator}',
  '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
];

const _localizationImportMarker = 'app_localizations';

const _uiArgumentNames = {
  // Text content
  'text', 'title', 'subtitle', 'label', 'labelText',
  'hint', 'hintText', 'helperText', 'errorText',
  'semanticLabel', 'tooltip', 'message', 'content',
  'placeholder', 'emptyMessage', 'emptyText', 'noDataText',
  // Decoration
  'prefixText', 'suffixText', 'counterText',
  // Dialogs / buttons
  'description', 'body', 'header', 'footer',
  'confirmText', 'cancelText', 'buttonText', 'actionText',
};

const _uiConstructors = {
  'Text', 'SelectableText', 'TextSpan',
  'SnackBar', 'AlertDialog', 'SimpleDialog', 'Tooltip',
  'Semantics', 'Tab', 'Chip', 'InputDecoration',
};

const _ignoreLinePatterns = [
  'import ', 'export ', 'part ', 'library ', '@JsonKey',
];

// Strings that are clearly NOT human-readable UI text.
final _ignoreValuePatterns = [
  RegExp(r'^https?://'),
  RegExp(r'^/[A-Za-z0-9_/{}/.\-]+$'),
  RegExp(r'^[A-Z0-9_]+$'),       // ALL_CAPS constants
  RegExp(r'^[a-z0-9_]+$'),       // single lowercase token / snake_case key
  RegExp(r'^[a-z]+/[a-z0-9+.\-]+$'),   // mime types
  RegExp(r'^[a-zA-Z0-9_./:\-]+\.(png|jpg|jpeg|svg|webp|json|pdf|mp4|mov|arb|dart)$'),
  RegExp(r'^#[0-9a-fA-F]{3,8}$'), // hex colors
  RegExp(r'^[0-9\s.,:;+\-/%#()]+$'), // pure numbers / punctuation
];

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main(List<String> args) {
  final options = _Options.parse(args);

  if (options.showHelp) {
    _printHelp();
    return;
  }

  final roots = options.paths.isEmpty ? _defaultRoots : options.paths;
  final findings = <_Finding>[];
  final missingImportFiles = <String>[];

  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root);
    if (entity == FileSystemEntityType.notFound) {
      stderr.writeln('Path not found: $root');
      exitCode = 2;
      return;
    }

    final files = entity == FileSystemEntityType.file && root.endsWith('.dart')
        ? [File(root)]
        : Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .toList();

    for (final file in files) {
      _scanFile(file, findings, missingImportFiles);
    }
  }

  // Sort by severity (HIGH first), then file + line.
  findings.sort((a, b) {
    final sev = b.severity.index.compareTo(a.severity.index);
    if (sev != 0) return sev;
    final file = a.file.compareTo(b.file);
    if (file != 0) return file;
    return a.line.compareTo(b.line);
  });

  // Apply --high-only filter.
  final filtered = options.highOnly
      ? findings.where((f) => f.severity == _Severity.high).toList()
      : findings;

  _printReport(
    filtered,
    missingImportFiles,
    options,
  );

  if ((filtered.isNotEmpty || missingImportFiles.isNotEmpty) &&
      options.failOnFindings) {
    exitCode = 1;
  }
}

// ---------------------------------------------------------------------------
// File scanning
// ---------------------------------------------------------------------------

void _scanFile(
  File file,
  List<_Finding> findings,
  List<String> missingImportFiles,
) {
  final path = file.path;
  if (_excludedPathParts.any(path.contains)) return;

  final String source;
  try {
    source = file.readAsStringSync();
  } catch (_) {
    return;
  }

  final normPath = _normalizePath(path);

  // Check for Widget files that never import AppLocalizations.
  if (_hasWidgetBuild(source) && !source.contains(_localizationImportMarker)) {
    missingImportFiles.add(normPath);
  }

  // Scan every string literal.
  for (final literal in _findStringLiterals(source)) {
    final value = _decodeForAudit(literal.rawValue);
    if (!_looksHumanReadable(value)) continue;

    final lineStart = source.lastIndexOf('\n', literal.start) + 1;
    final lineEnd = source.indexOf('\n', literal.start);
    final line = source.substring(
      lineStart,
      lineEnd == -1 ? source.length : lineEnd,
    );

    if (_ignoreLinePatterns.any((p) => line.trimLeft().startsWith(p))) {
      continue;
    }

    final arabic = _containsArabic(value);

    // Determine whether this string is in a UI position.
    final uiReason = _uiPositionReason(source, literal.start);

    // Arabic text anywhere → HIGH finding.
    if (arabic) {
      final location = _lineColumn(source, literal.start);
      findings.add(_Finding(
        file: normPath,
        line: location.line,
        column: location.column,
        text: value,
        reason: uiReason ?? 'arabic text',
        severity: _Severity.high,
      ));
      continue;
    }

    // Non-Arabic: only flag if it's in a known UI position.
    if (uiReason != null) {
      final location = _lineColumn(source, literal.start);
      findings.add(_Finding(
        file: normPath,
        line: location.line,
        column: location.column,
        text: value,
        reason: uiReason,
        severity: _Severity.medium,
      ));
    }
  }
}

// ---------------------------------------------------------------------------
// Detection helpers
// ---------------------------------------------------------------------------

bool _hasWidgetBuild(String source) =>
    source.contains('Widget build(BuildContext');

bool _containsArabic(String value) =>
    RegExp(r'[؀-ۿ]').hasMatch(value);

/// Returns the reason string if the literal appears in a UI position, else null.
String? _uiPositionReason(String source, int literalStart) {
  final lookStart = (literalStart - 200).clamp(0, source.length);
  final before = source.substring(lookStart, literalStart);
  final tail = before.replaceAll(RegExp(r'\s+'), ' ').trimRight();

  for (final constructor in _uiConstructors) {
    if (RegExp('(?:const\\s+)?$constructor\\s*\\(\\s*\$').hasMatch(tail)) {
      return '$constructor(…)';
    }
  }

  for (final name in _uiArgumentNames) {
    if (RegExp('(?:^|[,({]\\s*)$name\\s*:\\s*\$').hasMatch(tail)) {
      return '$name:';
    }
  }

  // SnackBar content Text pattern.
  if (RegExp(r'SnackBar\s*\([^)]*content\s*:\s*Text\s*\(\s*$')
      .hasMatch(tail)) {
    return 'SnackBar content';
  }

  return null;
}

bool _looksHumanReadable(String value) {
  final text = _stripInterpolations(value).trim();
  if (text.length < 2) return false;

  // Arabic text always counts as human-readable regardless of other heuristics.
  if (_containsArabic(text)) return true;

  for (final pattern in _ignoreValuePatterns) {
    if (pattern.hasMatch(text)) return false;
  }

  final hasLetters = RegExp(r'[A-Za-z]').hasMatch(text);
  if (!hasLetters) return false;

  final words = RegExp(r'[A-Za-z]{2,}').allMatches(text).length;
  final hasSeparator = RegExp(r'[\s?!.,:;()\-]').hasMatch(text);
  return words >= 2 || hasSeparator;
}

String _stripInterpolations(String value) {
  return value
      .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '');
}

// ---------------------------------------------------------------------------
// String literal parser
// ---------------------------------------------------------------------------

Iterable<_StringLiteral> _findStringLiterals(String source) sync* {
  var index = 0;
  while (index < source.length) {
    final char = source[index];

    // Skip line comments.
    if (char == '/' && index + 1 < source.length) {
      final next = source[index + 1];
      if (next == '/') {
        final end = source.indexOf('\n', index + 2);
        index = end == -1 ? source.length : end + 1;
        continue;
      }
      if (next == '*') {
        final end = source.indexOf('*/', index + 2);
        index = end == -1 ? source.length : end + 2;
        continue;
      }
    }

    final rawPrefix =
        char == 'r' &&
        index + 1 < source.length &&
        _isQuote(source[index + 1]);
    final quoteIndex = rawPrefix ? index + 1 : index;

    if (!_isQuote(source[quoteIndex])) {
      index++;
      continue;
    }

    final quote = source[quoteIndex];
    final triple =
        quoteIndex + 2 < source.length &&
        source[quoteIndex + 1] == quote &&
        source[quoteIndex + 2] == quote;
    final contentStart = quoteIndex + (triple ? 3 : 1);
    final literalEnd = _findLiteralEnd(
      source,
      contentStart,
      quote,
      triple: triple,
      raw: rawPrefix,
    );

    if (literalEnd == -1) {
      index = contentStart;
      continue;
    }

    yield _StringLiteral(
      start: rawPrefix ? index : quoteIndex,
      end: literalEnd,
      rawValue: source.substring(contentStart, literalEnd - (triple ? 3 : 1)),
    );
    index = literalEnd;
  }
}

int _findLiteralEnd(
  String source,
  int index,
  String quote, {
  required bool triple,
  required bool raw,
}) {
  while (index < source.length) {
    if (!raw && source[index] == r'\') {
      index += 2;
      continue;
    }
    if (triple) {
      if (index + 2 < source.length &&
          source[index] == quote &&
          source[index + 1] == quote &&
          source[index + 2] == quote) {
        return index + 3;
      }
      index++;
      continue;
    }
    if (source[index] == quote) return index + 1;
    index++;
  }
  return -1;
}

bool _isQuote(String char) => char == "'" || char == '"';

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

String _decodeForAudit(String raw) {
  return raw
      .replaceAll(r'\n', ' ')
      .replaceAll(r'\t', ' ')
      .replaceAll(r"\'", "'")
      .replaceAll(r'\"', '"')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

_Location _lineColumn(String source, int offset) {
  var line = 1;
  var column = 1;
  for (var i = 0; i < offset; i++) {
    if (source.codeUnitAt(i) == 10) {
      line++;
      column = 1;
    } else {
      column++;
    }
  }
  return _Location(line, column);
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

void _printReport(
  List<_Finding> findings,
  List<String> missingImportFiles,
  _Options options,
) {
  final buf = StringBuffer();

  // ── Missing import section ────────────────────────────────────────────────
  if (missingImportFiles.isNotEmpty && !options.locationsOnly) {
    missingImportFiles.sort();
    buf.writeln(
      'Widget files missing AppLocalizations import: '
      '${missingImportFiles.length}',
    );
    buf.writeln(
      '(These files have Widget build() but never import app_localizations)',
    );
    buf.writeln();
    for (final f in missingImportFiles) {
      buf.writeln('  $f');
    }
    buf.writeln();
  }

  // ── Findings section ──────────────────────────────────────────────────────
  if (findings.isEmpty) {
    buf.writeln('No unlocalized UI text found.');
  } else {
    final highCount = findings.where((f) => f.severity == _Severity.high).length;
    final medCount = findings.where((f) => f.severity == _Severity.medium).length;

    buf.writeln('Unlocalized UI text: ${findings.length} total'
        '  [HIGH: $highCount  MED: $medCount]');
    buf.writeln();

    if (options.locationsOnly) {
      for (final f in findings) {
        final tag = f.severity == _Severity.high ? '[HIGH]' : '[MED] ';
        buf.writeln(
          '$tag  ${f.file}:${f.line}:${f.column}  '
          '(${f.reason})  ${_quote(f.text)}',
        );
      }
    } else if (options.byFeature) {
      _writeByFeature(findings, buf);
    } else {
      _writeByFile(findings, buf);
    }
  }

  final report = buf.toString().trimRight();
  stdout.writeln(report);

  if (options.outputPath != null) {
    final outputFile = File(options.outputPath!);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync('$report\n');
    stderr.writeln('Wrote report to ${outputFile.path}');
  }
}

void _writeByFile(List<_Finding> findings, StringBuffer buf) {
  final byFile = <String, List<_Finding>>{};
  for (final f in findings) {
    byFile.putIfAbsent(f.file, () => []).add(f);
  }

  // Sort files: files with HIGH findings first.
  final sortedFiles = byFile.keys.toList()
    ..sort((a, b) {
      final aHigh = byFile[a]!.any((f) => f.severity == _Severity.high);
      final bHigh = byFile[b]!.any((f) => f.severity == _Severity.high);
      if (aHigh != bHigh) return aHigh ? -1 : 1;
      return a.compareTo(b);
    });

  for (final file in sortedFiles) {
    final list = byFile[file]!;
    final high = list.where((f) => f.severity == _Severity.high).length;
    final med = list.length - high;
    final tag = high > 0 ? '[HIGH:$high  MED:$med]' : '[MED:$med]';
    buf.writeln('$file  $tag');
  }
}

void _writeByFeature(List<_Finding> findings, StringBuffer buf) {
  final byFeature = <String, List<_Finding>>{};
  for (final f in findings) {
    final feature = _extractFeature(f.file);
    byFeature.putIfAbsent(feature, () => []).add(f);
  }

  final sorted = byFeature.keys.toList()..sort();
  for (final feature in sorted) {
    final list = byFeature[feature]!;
    final high = list.where((f) => f.severity == _Severity.high).length;
    final med = list.length - high;
    buf.writeln(
      '$feature  — ${list.length} findings'
      '  [HIGH: $high  MED: $med]',
    );
    for (final f in list) {
      final tag = f.severity == _Severity.high ? 'HIGH' : 'MED ';
      buf.writeln(
        '    [$tag] ${f.file}:${f.line}  (${f.reason})  ${_quote(f.text)}',
      );
    }
    buf.writeln();
  }
}

String _extractFeature(String filePath) {
  final match = RegExp(r'lib/features/([^/]+)').firstMatch(filePath);
  if (match != null) return match.group(1)!;
  final coreMatch = RegExp(r'lib/core/([^/]+)').firstMatch(filePath);
  if (coreMatch != null) return 'core/${coreMatch.group(1)}';
  return 'other';
}

String _quote(String value) {
  const max = 80;
  final s = value.length <= max ? value : '${value.substring(0, max)}…';
  return '"$s"';
}

// ---------------------------------------------------------------------------
// Help
// ---------------------------------------------------------------------------

void _printHelp() {
  stdout.writeln('''
Scans Dart files for user-facing strings that should use AppLocalizations.

Severity:
  [HIGH]  Arabic text detected — must be localized.
  [MED]   English/mixed text in a UI widget position — likely needs localization.

Usage:
  dart run tool/check_unlocalized_text.dart [options] [paths...]

Options:
  --locations-only     Show file:line:col for every finding (good for editors).
  --by-feature         Group findings by feature folder.
  --high-only          Show only HIGH severity (Arabic) findings.
  --output=<path>      Write the report to a file as well.
  --fail-on-findings   Exit code 1 when findings exist (for CI).
  --help, -h           Show this help.

Examples:
  dart run tool/check_unlocalized_text.dart
  dart run tool/check_unlocalized_text.dart --locations-only
  dart run tool/check_unlocalized_text.dart --by-feature
  dart run tool/check_unlocalized_text.dart --high-only --locations-only
  dart run tool/check_unlocalized_text.dart --locations-only --output=unlocalized_locations.txt
  dart run tool/check_unlocalized_text.dart lib/features/auctions
''');
}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

class _Options {
  const _Options({
    required this.locationsOnly,
    required this.byFeature,
    required this.highOnly,
    required this.outputPath,
    required this.failOnFindings,
    required this.showHelp,
    required this.paths,
  });

  final bool locationsOnly;
  final bool byFeature;
  final bool highOnly;
  final String? outputPath;
  final bool failOnFindings;
  final bool showHelp;
  final List<String> paths;

  factory _Options.parse(List<String> args) {
    var locationsOnly = false;
    var byFeature = false;
    var highOnly = false;
    String? outputPath;
    var failOnFindings = false;
    var showHelp = false;
    final paths = <String>[];

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '--locations-only':
          locationsOnly = true;
        case '--by-feature':
          byFeature = true;
        case '--high-only':
          highOnly = true;
        case '--fail-on-findings':
          failOnFindings = true;
        case '--help':
        case '-h':
          showHelp = true;
        default:
          if (arg.startsWith('--output=')) {
            outputPath = arg.substring('--output='.length);
          } else if (arg == '--output') {
            if (i + 1 >= args.length) {
              stderr.writeln('--output requires a file path');
              exitCode = 2;
              showHelp = true;
            } else {
              i++;
              outputPath = args[i];
            }
          } else {
            paths.add(arg);
          }
      }
    }

    return _Options(
      locationsOnly: locationsOnly,
      byFeature: byFeature,
      highOnly: highOnly,
      outputPath: outputPath,
      failOnFindings: failOnFindings,
      showHelp: showHelp,
      paths: paths,
    );
  }
}

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

enum _Severity { medium, high }

class _StringLiteral {
  const _StringLiteral({
    required this.start,
    required this.end,
    required this.rawValue,
  });

  final int start;
  final int end;
  final String rawValue;
}

class _Finding {
  const _Finding({
    required this.file,
    required this.line,
    required this.column,
    required this.text,
    required this.reason,
    required this.severity,
  });

  final String file;
  final int line;
  final int column;
  final String text;
  final String reason;
  final _Severity severity;
}

class _Location {
  const _Location(this.line, this.column);

  final int line;
  final int column;
}
