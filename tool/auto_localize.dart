// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Skip rules
// ---------------------------------------------------------------------------

final _skipPathFragments = [
  '${Platform.pathSeparator}l10n${Platform.pathSeparator}',
  '${Platform.pathSeparator}generated${Platform.pathSeparator}',
  '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
  '${Platform.pathSeparator}test${Platform.pathSeparator}',
  '_demo_data.dart',
  '_mock_data.dart',
  'app_strings.dart',
  'app_countries.dart',
];

const _uiArgumentNames = {
  'text', 'title', 'subtitle', 'label', 'labelText',
  'hint', 'hintText', 'helperText', 'errorText',
  'semanticLabel', 'tooltip', 'message', 'content',
  'placeholder', 'emptyMessage', 'emptyText', 'noDataText',
  'prefixText', 'suffixText', 'counterText',
  'description', 'body', 'header', 'footer',
  'confirmText', 'cancelText', 'buttonText', 'actionText',
};

const _uiConstructors = {
  'Text', 'SelectableText', 'TextSpan',
  'SnackBar', 'AlertDialog', 'SimpleDialog', 'Tooltip',
  'Semantics', 'Tab', 'Chip', 'InputDecoration',
};

final _ignoreValuePatterns = [
  RegExp(r'^https?://'),
  RegExp(r'^/[A-Za-z0-9_/{}/.\-]+$'),
  RegExp(r'^[A-Z0-9_]+$'),
  RegExp(r'^[a-z0-9_]+$'),
  RegExp(r'^[a-z]+/[a-z0-9+.\-]+$'),
  RegExp(r'^[a-zA-Z0-9_./:\-]+\.(png|jpg|jpeg|svg|webp|json|pdf|mp4|mov|arb|dart)$'),
  RegExp(r'^#[0-9a-fA-F]{3,8}$'),
  RegExp(r'^[0-9\s.,:;+\-/%#()]+$'),
];

const _ignoreLinePatterns = [
  'import ', 'export ', 'part ', 'library ', '@JsonKey',
];

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final verbose = args.contains('--verbose');

  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  // --- Load ARB files -------------------------------------------------------
  final arFile = File('lib/l10n/app_ar.arb');
  final enFile = File('lib/l10n/app_en.arb');

  if (!arFile.existsSync() || !enFile.existsSync()) {
    stderr.writeln('Cannot find lib/l10n/app_ar.arb or lib/l10n/app_en.arb');
    exitCode = 2;
    return;
  }

  final arArb = jsonDecode(arFile.readAsStringSync()) as Map<String, dynamic>;
  final enArb = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

  // Build reverse map: exact string value → ARB key name
  final valueToKey = <String, String>{};
  for (final e in arArb.entries) {
    if (!e.key.startsWith('@') && e.value is String) {
      valueToKey[e.value as String] = e.key;
    }
  }
  for (final e in enArb.entries) {
    if (!e.key.startsWith('@') && e.value is String) {
      valueToKey.putIfAbsent(e.value as String, () => e.key);
    }
  }

  // --- Scan and fix files ---------------------------------------------------
  var filesFixed = 0;
  var stringsFixed = 0;
  final unmatched = <_UnmatchedEntry>[];

  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  for (final file in files) {
    if (_skipPathFragments.any(file.path.contains)) continue;

    final source = file.readAsStringSync();

    // Only localize files that have Widget build(BuildContext …)
    if (!source.contains('Widget build(BuildContext')) continue;

    final result = _processFile(
      file: file,
      source: source,
      valueToKey: valueToKey,
      dryRun: dryRun,
      verbose: verbose,
    );

    if (result.stringsFixed > 0) {
      filesFixed++;
      stringsFixed += result.stringsFixed;
    }
    unmatched.addAll(result.unmatched);
  }

  // --- Summary --------------------------------------------------------------
  print('');
  print('════════════════════════════════════════════');
  print('Auto-localize ${dryRun ? "[DRY RUN] " : ""}complete');
  print('  Files modified : $filesFixed');
  print('  Strings fixed  : $stringsFixed');
  print('  Unmatched      : ${unmatched.length}  ← need new ARB keys');
  print('════════════════════════════════════════════');

  if (unmatched.isNotEmpty) {
    print('');
    print('Strings with no existing ARB key (fix manually):');
    for (final u in unmatched) {
      print('  ${u.file}:${u.line}  "${u.text}"');
    }
  }

  if (stringsFixed > 0 && !dryRun) {
    print('');
    print('Next: run  flutter gen-l10n  (or flutter pub get) to re-generate');
    print('      then  flutter analyze  to catch any remaining const issues.');
  }
}

// ---------------------------------------------------------------------------
// File processor
// ---------------------------------------------------------------------------

_FileResult _processFile({
  required File file,
  required String source,
  required Map<String, String> valueToKey,
  required bool dryRun,
  required bool verbose,
}) {
  final unmatched = <_UnmatchedEntry>[];
  // Each replacement: start/end offsets in source + replacement text.
  final replacements = <_Replacement>[];

  for (final literal in _findStringLiterals(source)) {
    final rawValue = literal.rawValue;

    // Skip interpolated strings — they need parameterised keys.
    if (_containsInterpolation(rawValue)) continue;

    final value = _decodeForAudit(rawValue);
    if (!_looksHumanReadable(value)) continue;

    // Check line-level ignore patterns.
    final lineStart = source.lastIndexOf('\n', literal.start) + 1;
    final lineEnd = source.indexOf('\n', literal.start);
    final lineText = source.substring(
      lineStart,
      lineEnd == -1 ? source.length : lineEnd,
    );
    if (_ignoreLinePatterns.any((p) => lineText.trimLeft().startsWith(p))) {
      continue;
    }

    final arabic = _containsArabic(value);
    final uiReason = _uiPositionReason(source, literal.start);

    if (!arabic && uiReason == null) continue;

    final key = valueToKey[value];
    if (key == null) {
      final loc = _lineColumn(source, literal.start);
      unmatched.add(_UnmatchedEntry(
        file: _norm(file.path),
        line: loc.line,
        text: value,
      ));
      continue;
    }

    replacements.add(_Replacement(
      start: literal.start,
      end: literal.end,
      newText: 'l.$key',
    ));
  }

  if (replacements.isEmpty) return _FileResult(0, unmatched);

  // Apply replacements in reverse so offsets stay valid.
  replacements.sort((a, b) => b.start.compareTo(a.start));
  var modified = source;
  for (final r in replacements) {
    modified = modified.substring(0, r.start) + r.newText + modified.substring(r.end);
  }

  // Strip `const` before any widget whose argument is now `l.xxx`
  modified = _removeConstBeforeL(modified);

  // Ensure l10n import.
  modified = _ensureImport(modified);

  // Ensure `final l = AppLocalizations.of(context);` in every build() body.
  modified = _ensureLVar(modified);

  if (!dryRun) {
    file.writeAsStringSync(modified);
  }

  if (verbose) {
    print('  [${dryRun ? "dry" : "fix"}] ${_norm(file.path)}  '
        '(${replacements.length} strings)');
  }

  return _FileResult(replacements.length, unmatched);
}

// ---------------------------------------------------------------------------
// Source transformations
// ---------------------------------------------------------------------------

/// Adds the AppLocalizations import after the last existing import, if absent.
String _ensureImport(String source) {
  const marker = 'app_localizations';
  if (source.contains(marker)) return source;

  const importLine = "import 'package:pigeon_planet/l10n/app_localizations.dart';";

  // Find the last import/part line, insert after it.
  final importRegex = RegExp(r"^(import|export|part|library) ", multiLine: true);
  final matches = importRegex.allMatches(source).toList();
  if (matches.isEmpty) {
    return '$importLine\n$source';
  }
  final lastMatch = matches.last;
  final lastLineEnd = source.indexOf('\n', lastMatch.start);
  if (lastLineEnd == -1) return '$source\n$importLine';
  return '${source.substring(0, lastLineEnd + 1)}$importLine\n${source.substring(lastLineEnd + 1)}';
}

/// Injects `final l = AppLocalizations.of(context);` at the top of every
/// build(BuildContext context) method body that doesn't already have it.
String _ensureLVar(String source) {
  const lDecl = 'AppLocalizations.of(context)';
  // Regex to locate the opening brace of Widget build(BuildContext …) {
  final buildRegex = RegExp(
    r'Widget\s+build\s*\(\s*BuildContext\s+\w+\s*\)\s*\{',
  );

  var result = source;
  var offset = 0;

  for (final match in buildRegex.allMatches(source)) {
    final bracePos = match.end - 1; // position of `{`
    final adjustedBracePos = bracePos + offset;

    // Find the matching closing brace to know the method body.
    final bodyEnd = _findMatchingBrace(result, adjustedBracePos);
    if (bodyEnd == -1) continue;

    final body = result.substring(adjustedBracePos, bodyEnd);

    if (body.contains(lDecl)) continue; // already has it
    if (!body.contains('l.')) continue; // no l.key usage — skip

    // Insert after the `{`.
    const inject = '\n    final l = AppLocalizations.of(context);';
    result = result.substring(0, adjustedBracePos + 1) +
        inject +
        result.substring(adjustedBracePos + 1);
    offset += inject.length;
  }

  return result;
}

/// Removes `const ` immediately before a constructor call whose arguments
/// contain `l.xxx`, since l.xxx is not a const expression.
String _removeConstBeforeL(String source) {
  // Replace patterns like:  const Text(l.   →  Text(l.
  // and:                     const SomeWidget(…l.   →  SomeWidget(…l.
  //
  // Strategy: remove `const ` on the same "call" line when `l.` appears
  // inside that call's argument list.  We do a conservative line-by-line pass.
  final lines = source.split('\n');
  final result = <String>[];
  for (var line in lines) {
    if (line.contains('l.') && line.contains('const ')) {
      // Remove `const ` if the line contains l. (coarse but safe — Flutter
      // analyser will flag any remaining issues).
      line = line.replaceAll('const ', '');
    }
    result.add(line);
  }
  return result.join('\n');
}

// ---------------------------------------------------------------------------
// String literal parser (same as check script)
// ---------------------------------------------------------------------------

Iterable<_StringLiteral> _findStringLiterals(String source) sync* {
  var index = 0;
  while (index < source.length) {
    final char = source[index];

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
        char == 'r' && index + 1 < source.length && _isQuote(source[index + 1]);
    final quoteIndex = rawPrefix ? index + 1 : index;
    if (!_isQuote(source[quoteIndex])) {
      index++;
      continue;
    }

    final quote = source[quoteIndex];
    final triple = quoteIndex + 2 < source.length &&
        source[quoteIndex + 1] == quote &&
        source[quoteIndex + 2] == quote;
    final contentStart = quoteIndex + (triple ? 3 : 1);
    final literalEnd = _findLiteralEnd(
      source, contentStart, quote, triple: triple, raw: rawPrefix,
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
  String source, int index, String quote, {
  required bool triple, required bool raw,
}) {
  while (index < source.length) {
    if (!raw && source[index] == r'\') { index += 2; continue; }
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
// UI position detector (same logic as check script)
// ---------------------------------------------------------------------------

String? _uiPositionReason(String source, int literalStart) {
  final lookStart = (literalStart - 200).clamp(0, source.length);
  final before = source.substring(lookStart, literalStart);
  final tail = before.replaceAll(RegExp(r'\s+'), ' ').trimRight();

  for (final c in _uiConstructors) {
    if (RegExp('(?:const\\s+)?$c\\s*\\(\\s*\$').hasMatch(tail)) return c;
  }
  for (final n in _uiArgumentNames) {
    if (RegExp('(?:^|[,({]\\s*)$n\\s*:\\s*\$').hasMatch(tail)) return n;
  }
  if (RegExp(r'SnackBar\s*\([^)]*content\s*:\s*Text\s*\(\s*$').hasMatch(tail)) {
    return 'SnackBar content';
  }
  return null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

bool _containsArabic(String value) => RegExp(r'[؀-ۿ]').hasMatch(value);

bool _containsInterpolation(String raw) =>
    raw.contains(r'${') || RegExp(r'\$[A-Za-z_]').hasMatch(raw);

bool _looksHumanReadable(String value) {
  final text = _stripInterpolations(value).trim();
  if (text.length < 2) return false;
  if (_containsArabic(text)) return true;
  for (final p in _ignoreValuePatterns) {
    if (p.hasMatch(text)) return false;
  }
  final hasLetters = RegExp(r'[A-Za-z]').hasMatch(text);
  if (!hasLetters) return false;
  final words = RegExp(r'[A-Za-z]{2,}').allMatches(text).length;
  final hasSep = RegExp(r'[\s?!.,:;()\-]').hasMatch(text);
  return words >= 2 || hasSep;
}

String _stripInterpolations(String v) => v
    .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
    .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '');

String _decodeForAudit(String raw) => raw
    .replaceAll(r'\n', ' ')
    .replaceAll(r'\t', ' ')
    .replaceAll(r"\'", "'")
    .replaceAll(r'\"', '"')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Finds the index AFTER the closing `}` that matches the `{` at [openPos].
int _findMatchingBrace(String source, int openPos) {
  var depth = 0;
  for (var i = openPos; i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}') {
      depth--;
      if (depth == 0) return i + 1;
    }
  }
  return -1;
}

_Location _lineColumn(String source, int offset) {
  var line = 1;
  var column = 1;
  for (var i = 0; i < offset; i++) {
    if (source.codeUnitAt(i) == 10) { line++; column = 1; } else { column++; }
  }
  return _Location(line, column);
}

String _norm(String path) => path.replaceAll('\\', '/');

// ---------------------------------------------------------------------------
// Help
// ---------------------------------------------------------------------------

void _printHelp() {
  print('''
Automatically replaces hard-coded UI strings with AppLocalizations keys.

Usage:
  dart run tool/auto_localize.dart [options]

Options:
  --dry-run    Show what would be changed without writing any files.
  --verbose    Print each file as it is processed.
  --help, -h   Show this help.

What it does:
  1. Loads lib/l10n/app_ar.arb and app_en.arb to build a value→key map.
  2. Scans every Dart file that has Widget build(BuildContext …).
  3. Replaces matching hard-coded strings with  l.keyName .
  4. Adds the AppLocalizations import if missing.
  5. Injects  final l = AppLocalizations.of(context);  into each build() body.
  6. Strips  const  from widgets whose arguments are now l.xxx.
  7. Reports strings with no existing ARB key (interpolated or new strings).

Skips:
  - lib/l10n/, generated/, test/ folders
  - *_demo_data.dart, *_mock_data.dart
  - app_strings.dart, app_countries.dart
  - Files with no Widget build() (model/datasource layer)
  - Interpolated strings: e.g.  '\${x} ج.م'  — reported, not replaced

After running:
  flutter gen-l10n   (regenerate localization classes)
  flutter analyze    (fix any remaining const or type issues)
''');
}

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

class _StringLiteral {
  const _StringLiteral({required this.start, required this.end, required this.rawValue});
  final int start;
  final int end;
  final String rawValue;
}

class _Replacement {
  const _Replacement({required this.start, required this.end, required this.newText});
  final int start;
  final int end;
  final String newText;
}

class _UnmatchedEntry {
  const _UnmatchedEntry({required this.file, required this.line, required this.text});
  final String file;
  final int line;
  final String text;
}

class _FileResult {
  const _FileResult(this.stringsFixed, this.unmatched);
  final int stringsFixed;
  final List<_UnmatchedEntry> unmatched;
}

class _Location {
  const _Location(this.line, this.column);
  final int line;
  final int column;
}
