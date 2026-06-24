import 'dart:convert';
import 'dart:io';

const _defaultRoots = ['lib'];

final _excludedPathParts = [
  '${Platform.pathSeparator}l10n${Platform.pathSeparator}',
  '${Platform.pathSeparator}generated${Platform.pathSeparator}',
];

const _uiArgumentNames = {
  'text',
  'title',
  'subtitle',
  'label',
  'labelText',
  'hint',
  'hintText',
  'helperText',
  'errorText',
  'semanticLabel',
  'tooltip',
  'message',
  'content',
  'placeholder',
  'emptyMessage',
};

const _uiConstructors = {
  'Text',
  'SelectableText',
  'TextSpan',
  'SnackBar',
  'AlertDialog',
  'Tooltip',
  'Semantics',
  'Tab',
  'Chip',
  'InputDecoration',
};

const _ignoreLinePatterns = [
  'import ',
  'export ',
  'part ',
  'library ',
  '@JsonKey',
];

const _ignoreValuePatterns = [
  r'^https?://',
  r'^/[A-Za-z0-9_/{}/.-]+$',
  r'^[A-Z0-9_]+$',
  r'^[a-z0-9_]+$',
  r'^[a-z]+/[a-z0-9+.-]+$',
  r'^[a-zA-Z0-9_./:-]+\.(png|jpg|jpeg|svg|webp|json|pdf|mp4|mov|arb|dart)$',
  r'^#[0-9a-fA-F]{3,8}$',
  r'^[0-9\s.,:;+\-/%#()]+$',
];

void main(List<String> args) {
  final options = _Options.parse(args);

  if (options.showHelp) {
    _printHelp();
    return;
  }

  final roots = options.paths.isEmpty ? _defaultRoots : options.paths;
  final findings = <_Finding>[];

  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root);
    if (entity == FileSystemEntityType.notFound) {
      stderr.writeln('Path not found: $root');
      exitCode = 2;
      return;
    }

    if (entity == FileSystemEntityType.file && root.endsWith('.dart')) {
      _scanFile(File(root), findings);
      continue;
    }

    if (entity == FileSystemEntityType.directory) {
      for (final file
          in Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        _scanFile(file, findings);
      }
    }
  }

  findings.sort((a, b) {
    final fileCompare = a.file.compareTo(b.file);
    if (fileCompare != 0) return fileCompare;
    return a.line.compareTo(b.line);
  });

  _ArbWriteResult? arbWriteResult;
  if (options.writeArb) {
    arbWriteResult = _writeArbEntries(findings, options.arbDir);
  }

  final report = options.locationsOnly
      ? _toLocationsReport(findings)
      : options.format == _OutputFormat.json
      ? _toJson(findings)
      : _toTextReport(findings);

  stdout.writeln(report);
  if (arbWriteResult != null) {
    stdout.writeln('');
    stdout.writeln(_toArbWriteReport(arbWriteResult));
  }

  if (options.outputPath != null) {
    final outputFile = File(options.outputPath!);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync('$report\n');
    stdout.writeln('Wrote localization audit report to ${outputFile.path}');
  }

  if (findings.isNotEmpty && options.failOnFindings) {
    exitCode = 1;
  }
}

_ArbWriteResult _writeArbEntries(List<_Finding> findings, String arbDir) {
  final arFile = File('$arbDir${Platform.pathSeparator}app_ar.arb');
  final enFile = File('$arbDir${Platform.pathSeparator}app_en.arb');

  if (!arFile.existsSync() || !enFile.existsSync()) {
    stderr.writeln('Missing ARB files in $arbDir');
    exitCode = 2;
    return const _ArbWriteResult(added: [], existing: [], skipped: []);
  }

  final arMessages = _readArb(arFile);
  final enMessages = _readArb(enFile);
  final added = <_ArbEntry>[];
  final existing = <_ArbEntry>[];
  final skipped = <_ArbEntry>[];

  for (final finding in findings) {
    final template = _toArbMessageTemplate(finding.text);
    if (template == null) {
      skipped.add(_ArbEntry(key: 'unsafe-arb-message', finding: finding));
      continue;
    }
    final existingKey = _findExistingArbKey(template, arMessages, enMessages);
    if (existingKey != null) {
      existing.add(_ArbEntry(key: existingKey, finding: finding));
      continue;
    }

    final key = _makeUniqueArbKey(finding, arMessages, enMessages);
    final metadata = _metadataForFinding(finding, template);

    arMessages[key] = template.message;
    arMessages['@$key'] = metadata;
    enMessages[key] = template.message;
    enMessages['@$key'] = metadata;

    added.add(_ArbEntry(key: key, finding: finding));
  }

  if (added.isNotEmpty) {
    arFile.writeAsStringSync('${_prettyJson(arMessages)}\n');
    enFile.writeAsStringSync('${_prettyJson(enMessages)}\n');
  }

  return _ArbWriteResult(added: added, existing: existing, skipped: skipped);
}

Map<String, dynamic> _readArb(File file) {
  return (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>).map(
    (key, value) => MapEntry(key, value),
  );
}

String? _findExistingArbKey(
  _ArbTemplate template,
  Map<String, dynamic> arMessages,
  Map<String, dynamic> enMessages,
) {
  for (final messages in [arMessages, enMessages]) {
    for (final entry in messages.entries) {
      if (entry.key.startsWith('@')) continue;
      if (entry.value == template.message) return entry.key;
    }
  }
  return null;
}

_ArbTemplate? _toArbMessageTemplate(String text) {
  final placeholders = <String, String>{};
  var index = 0;
  final message = text
      .replaceAllMapped(RegExp(r'\$\{[^}]*\}'), (match) {
        index++;
        final name = 'value$index';
        placeholders[name] = match.group(0)!;
        return '{$name}';
      })
      .replaceAllMapped(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), (match) {
        index++;
        final name = 'value$index';
        placeholders[name] = match.group(0)!;
        return '{$name}';
      });

  var safetyCheck = message;
  for (final name in placeholders.keys) {
    safetyCheck = safetyCheck.replaceAll('{$name}', '');
  }
  if (safetyCheck.contains('{') ||
      safetyCheck.contains('}') ||
      safetyCheck.contains(r'$')) {
    return null;
  }

  return _ArbTemplate(message: message, placeholders: placeholders);
}

Map<String, dynamic> _metadataForFinding(
  _Finding finding,
  _ArbTemplate template,
) {
  final metadata = <String, dynamic>{
    'description':
        'Generated from ${finding.file}:${finding.line}:${finding.column}. '
        'Review translations before release.',
  };

  if (template.placeholders.isNotEmpty) {
    metadata['placeholders'] = {
      for (final placeholder in template.placeholders.entries)
        placeholder.key: {
          'type': 'Object',
          'description': 'Original Dart interpolation: ${placeholder.value}',
        },
    };
  }

  return metadata;
}

String _makeUniqueArbKey(
  _Finding finding,
  Map<String, dynamic> arMessages,
  Map<String, dynamic> enMessages,
) {
  final fileName = finding.file.split('/').last.replaceFirst('.dart', '');
  final base =
      'generated${_toPascalCase(fileName)}L${finding.line}C${finding.column}';
  var key = base;
  var suffix = 2;
  while (arMessages.containsKey(key) || enMessages.containsKey(key)) {
    key = '$base$suffix';
    suffix++;
  }
  return key;
}

String _toPascalCase(String value) {
  final words = value
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty);
  return words.map((word) => word[0].toUpperCase() + word.substring(1)).join();
}

void _scanFile(File file, List<_Finding> findings) {
  final path = file.path;
  if (_excludedPathParts.any(path.contains)) return;
  if (path.endsWith('${Platform.pathSeparator}app_strings.dart')) return;

  final source = file.readAsStringSync();
  for (final literal in _findStringLiterals(source)) {
    final value = _decodeForAudit(literal.rawValue);
    if (!_looksHumanReadable(value)) continue;

    final lineStart = source.lastIndexOf('\n', literal.start) + 1;
    final lineEnd = source.indexOf('\n', literal.start);
    final line = source.substring(
      lineStart,
      lineEnd == -1 ? source.length : lineEnd,
    );

    if (_ignoreLinePatterns.any(
      (pattern) => line.trimLeft().startsWith(pattern),
    )) {
      continue;
    }

    final reason = _localizationReason(source, literal.start);
    if (reason == null) continue;

    final location = _lineColumn(source, literal.start);
    findings.add(
      _Finding(
        file: _normalizePath(path),
        line: location.line,
        column: location.column,
        text: value,
        reason: reason,
        snippet: line.trim(),
      ),
    );
  }
}

String? _localizationReason(String source, int literalStart) {
  final lookBehindStart = literalStart - 180 < 0 ? 0 : literalStart - 180;
  final before = source.substring(lookBehindStart, literalStart);
  final compactBefore = before.replaceAll(RegExp(r'\s+'), ' ');
  final tail = compactBefore.trimRight();

  for (final constructor in _uiConstructors) {
    if (RegExp('(?:const\\s+)?$constructor\\s*\\(\\s*\$').hasMatch(tail)) {
      return '$constructor literal';
    }
  }

  for (final name in _uiArgumentNames) {
    if (RegExp('(?:^|[,({]\\s*)$name\\s*:\\s*\$').hasMatch(tail)) {
      return '$name argument';
    }
  }

  if (RegExp(r'SnackBar\s*\([^)]*content\s*:\s*Text\s*\(\s*$').hasMatch(tail)) {
    return 'SnackBar content';
  }

  return null;
}

bool _looksHumanReadable(String value) {
  final text = _visibleText(value).trim();
  if (text.length < 2) return false;

  for (final pattern in _ignoreValuePatterns) {
    if (RegExp(pattern).hasMatch(text)) return false;
  }

  final hasLetters = RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(text);
  if (!hasLetters) return false;

  final words = RegExp(r'[A-Za-z\u0600-\u06FF]{2,}').allMatches(text).length;
  final hasSpaceOrPunctuation = RegExp(r'[\s?!.,:;-]').hasMatch(text);
  return words >= 2 || hasSpaceOrPunctuation;
}

String _visibleText(String value) {
  return value
      .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '');
}

Iterable<_StringLiteral> _findStringLiterals(String source) sync* {
  var index = 0;
  while (index < source.length) {
    final char = source[index];

    if (char == '/' && index + 1 < source.length) {
      final next = source[index + 1];
      if (next == '/') {
        final lineEnd = source.indexOf('\n', index + 2);
        index = lineEnd == -1 ? source.length : lineEnd + 1;
        continue;
      }
      if (next == '*') {
        final commentEnd = source.indexOf('*/', index + 2);
        index = commentEnd == -1 ? source.length : commentEnd + 2;
        continue;
      }
    }

    final rawPrefix =
        char == 'r' && index + 1 < source.length && _isQuote(source[index + 1]);
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

String _toTextReport(List<_Finding> findings) {
  if (findings.isEmpty) {
    return 'No likely unlocalized UI text found.';
  }

  final buffer = StringBuffer()
    ..writeln('Likely unlocalized UI text: ${findings.length}')
    ..writeln();

  var currentFile = '';
  for (final finding in findings) {
    if (finding.file != currentFile) {
      currentFile = finding.file;
      buffer.writeln(currentFile);
    }
    buffer.writeln(
      '  ${finding.line}:${finding.column}  '
      '[${finding.reason}] ${_quote(finding.text)}',
    );
    buffer.writeln('    ${finding.snippet}');
  }

  return buffer.toString().trimRight();
}

String _toLocationsReport(List<_Finding> findings) {
  if (findings.isEmpty) {
    return 'No likely unlocalized UI text found.';
  }

  final buffer = StringBuffer()
    ..writeln('Likely unlocalized UI locations: ${findings.length}')
    ..writeln();

  for (final finding in findings) {
    buffer.writeln(
      '${finding.file}:${finding.line}:${finding.column}  '
      '${_quote(finding.text)}',
    );
  }

  return buffer.toString().trimRight();
}

String _toArbWriteReport(_ArbWriteResult result) {
  final buffer = StringBuffer()
    ..writeln('ARB localization entries:')
    ..writeln('  Added: ${result.added.length}')
    ..writeln('  Already existed: ${result.existing.length}')
    ..writeln('  Skipped: ${result.skipped.length}');

  if (result.added.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Added keys:');
    for (final entry in result.added) {
      buffer.writeln(
        '  ${entry.finding.file}:${entry.finding.line}:${entry.finding.column} '
        '=> ${entry.key}',
      );
    }
  }

  if (result.skipped.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Skipped unsafe messages:');
    for (final entry in result.skipped) {
      buffer.writeln(
        '  ${entry.finding.file}:${entry.finding.line}:${entry.finding.column} '
        '${_quote(entry.finding.text)}',
      );
    }
  }

  return buffer.toString().trimRight();
}

String _toJson(List<_Finding> findings) {
  final entries = findings.map((finding) {
    return {
      'file': finding.file,
      'line': finding.line,
      'column': finding.column,
      'text': finding.text,
      'reason': finding.reason,
      'snippet': finding.snippet,
    };
  }).toList();

  final buffer = StringBuffer('[\n');
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.writeln('  {');
    var fieldIndex = 0;
    for (final field in entry.entries) {
      final comma = fieldIndex == entry.length - 1 ? '' : ',';
      final value = field.value is num
          ? '${field.value}'
          : '"${_escapeJson('${field.value}')}"';
      buffer.writeln('    "${field.key}": $value$comma');
      fieldIndex++;
    }
    buffer.write('  }');
    buffer.writeln(i == entries.length - 1 ? '' : ',');
  }
  buffer.write(']');
  return buffer.toString();
}

String _escapeJson(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
}

String _prettyJson(Object? value, {int indent = 0}) {
  final spaces = ' ' * indent;
  final childSpaces = ' ' * (indent + 2);

  if (value is Map) {
    if (value.isEmpty) return '{}';
    final entries = value.entries.toList();
    final buffer = StringBuffer('{\n');
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final comma = i == entries.length - 1 ? '' : ',';
      buffer
        ..write(childSpaces)
        ..write(jsonEncode(entry.key))
        ..write(': ')
        ..write(_prettyJson(entry.value, indent: indent + 2))
        ..writeln(comma);
    }
    buffer.write('$spaces}');
    return buffer.toString();
  }

  if (value is List) {
    if (value.isEmpty) return '[]';
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < value.length; i++) {
      final comma = i == value.length - 1 ? '' : ',';
      buffer
        ..write(childSpaces)
        ..write(_prettyJson(value[i], indent: indent + 2))
        ..writeln(comma);
    }
    buffer.write('$spaces]');
    return buffer.toString();
  }

  return jsonEncode(value);
}

String _quote(String value) {
  const maxLength = 90;
  final shortened = value.length <= maxLength
      ? value
      : '${value.substring(0, maxLength)}...';
  return '"$shortened"';
}

void _printHelp() {
  stdout.writeln('''
Checks Dart files for likely user-facing string literals that should use AppLocalizations.

Usage:
  dart run tool/check_unlocalized_text.dart [options] [paths...]

Options:
  --fail-on-findings   Exit with code 1 when findings exist. Useful for CI.
  --format=json        Emit machine-readable JSON.
  --locations-only     Emit only file:line:column locations and text.
  --output=<path>      Write the report to a file.
  --write-arb          Add missing findings to lib/l10n/app_ar.arb and app_en.arb.
  --arb-dir=<path>     Override the ARB directory. Defaults to lib/l10n.
  --help               Show this help.

Examples:
  dart run tool/check_unlocalized_text.dart
  dart run tool/check_unlocalized_text.dart --locations-only --output=unlocalized_locations.txt
  dart run tool/check_unlocalized_text.dart --write-arb lib/features/cart
  dart run tool/check_unlocalized_text.dart --fail-on-findings lib/features/cart
''');
}

class _Options {
  const _Options({
    required this.failOnFindings,
    required this.format,
    required this.locationsOnly,
    required this.outputPath,
    required this.writeArb,
    required this.arbDir,
    required this.showHelp,
    required this.paths,
  });

  final bool failOnFindings;
  final _OutputFormat format;
  final bool locationsOnly;
  final String? outputPath;
  final bool writeArb;
  final String arbDir;
  final bool showHelp;
  final List<String> paths;

  factory _Options.parse(List<String> args) {
    var failOnFindings = false;
    var format = _OutputFormat.text;
    var locationsOnly = false;
    String? outputPath;
    var writeArb = false;
    var arbDir = 'lib/l10n';
    var showHelp = false;
    final paths = <String>[];

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      switch (arg) {
        case '--fail-on-findings':
          failOnFindings = true;
        case '--format=json':
          format = _OutputFormat.json;
        case '--locations-only':
          locationsOnly = true;
        case '--write-arb':
          writeArb = true;
        case '--help':
        case '-h':
          showHelp = true;
        default:
          if (arg.startsWith('--output=')) {
            outputPath = arg.substring('--output='.length);
          } else if (arg.startsWith('--arb-dir=')) {
            arbDir = arg.substring('--arb-dir='.length);
          } else if (arg == '--output') {
            if (index + 1 >= args.length) {
              stderr.writeln('--output requires a file path');
              exitCode = 2;
              showHelp = true;
            } else {
              index++;
              outputPath = args[index];
            }
          } else if (arg == '--arb-dir') {
            if (index + 1 >= args.length) {
              stderr.writeln('--arb-dir requires a directory path');
              exitCode = 2;
              showHelp = true;
            } else {
              index++;
              arbDir = args[index];
            }
          } else {
            paths.add(arg);
          }
      }
    }

    return _Options(
      failOnFindings: failOnFindings,
      format: format,
      locationsOnly: locationsOnly,
      outputPath: outputPath,
      writeArb: writeArb,
      arbDir: arbDir,
      showHelp: showHelp,
      paths: paths,
    );
  }
}

enum _OutputFormat { text, json }

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
    required this.snippet,
  });

  final String file;
  final int line;
  final int column;
  final String text;
  final String reason;
  final String snippet;
}

class _ArbTemplate {
  const _ArbTemplate({required this.message, required this.placeholders});

  final String message;
  final Map<String, String> placeholders;
}

class _ArbEntry {
  const _ArbEntry({required this.key, required this.finding});

  final String key;
  final _Finding finding;
}

class _ArbWriteResult {
  const _ArbWriteResult({
    required this.added,
    required this.existing,
    required this.skipped,
  });

  final List<_ArbEntry> added;
  final List<_ArbEntry> existing;
  final List<_ArbEntry> skipped;
}

class _Location {
  const _Location(this.line, this.column);

  final int line;
  final int column;
}
