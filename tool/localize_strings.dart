// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// localize_strings.dart
//
// Usage:
//   dart run tool/localize_strings.dart [--dry-run] [--skip-arb] [--verbose]
//
// What it does:
//   1. Runs check_unlocalized_text.dart --locations-only to collect findings.
//   2. Filters to view/pages and view/widgets only (skips demo/mock/model).
//   3. For each finding:
//        a. Derives a camelCase ARB key from the Arabic/English text.
//        b. Converts Dart interpolations (${expr} / $var) → ICU placeholders.
//        c. Appends new keys to app_en.arb and app_ar.arb (skips duplicates).
//        d. Rewrites the Dart source: replaces the raw string literal with
//           AppLocalizations.of(context).keyName  (or keyName(args) for
//           parametrized strings).
//        e. Adds the AppLocalizations import if missing.
//   4. Prints a summary report.  Strings it cannot safely rewrite are listed
//      in the MANUAL REVIEW section.
//
// Flags:
//   --dry-run   Parse + plan everything, print the plan, write nothing.
//   --skip-arb  Rewrite Dart files only; do not touch the .arb files.
//   --verbose   Print every individual replacement as it happens.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const _enArbPath = 'lib/l10n/app_en.arb';
const _arArbPath = 'lib/l10n/app_ar.arb';
const _l10nAccessor = 'AppLocalizations.of(context)';

// Dart files we never touch.
final _skipPathFragments = [
  'demo_data',
  'mock_data',
  'app_countries',
  'app_strings',
  '/datasources/',
  '_model.',
  '/l10n/',
  '/generated/',
];

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final skipArb = args.contains('--skip-arb');
  final verbose = args.contains('--verbose');

  print('');
  print('╔══════════════════════════════════════════════════════╗');
  print('║          localize_strings.dart${dryRun ? "  [DRY RUN]" : "            "}      ║');
  print('╚══════════════════════════════════════════════════════╝');
  print('');

  // ── Step 1: collect findings ────────────────────────────────────────────
  print('▶ Running check_unlocalized_text.dart --locations-only ...');
  final checkResult = await Process.run(
    'dart',
    ['run', 'tool/check_unlocalized_text.dart', '--locations-only'],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  final lines = (checkResult.stdout as String)
      .split('\n')
      .where((l) => l.startsWith('[HIGH]') || l.startsWith('[MED] '))
      .where((l) => _isRelevantPath(l))
      .toList();

  print('  Found ${lines.length} relevant findings.\n');

  // ── Step 2: load existing ARB keys ──────────────────────────────────────
  final enArb = _loadArb(_enArbPath);
  final arArb = _loadArb(_arArbPath);
  final existingKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();

  // ── Step 3: parse findings → planned replacements ───────────────────────
  final byFile = <String, List<_Replacement>>{};
  final manual = <_ManualItem>[];
  final keyRegistry = <String, _ArbEntry>{}; // key → entry (new keys only)

  for (final line in lines) {
    final parsed = _parseFinding(line);
    if (parsed == null) continue;

    // Skip artefacts from map-subscript interpolations like ${data['key']} ج.م.
    // The check tool sees only the suffix "]} ج.م" as a separate string literal.
    if (parsed.text.startsWith(']}')) {
      manual.add(_ManualItem(finding: parsed, reason: 'map-subscript suffix — rewrite manually'));
      continue;
    }

    // Skip obvious dev/test values (controller defaults, phone masks, IDs).
    if (_isDevValue(parsed.text)) continue;

    final plan = _planReplacement(
      finding: parsed,
      existingKeys: existingKeys,
      keyRegistry: keyRegistry,
      enArb: enArb,
    );

    if (plan == null) {
      manual.add(_ManualItem(finding: parsed, reason: 'unparseable pattern'));
      continue;
    }

    if (plan.needsManualReview) {
      manual.add(_ManualItem(finding: parsed, reason: plan.manualReason!));
      continue;
    }

    byFile.putIfAbsent(parsed.file, () => []).add(plan);
  }

  // ── Step 4: report plan ─────────────────────────────────────────────────
  final totalAuto = byFile.values.fold(0, (s, l) => s + l.length);
  print('Plan:');
  print('  Auto-replaceable : $totalAuto');
  print('  New ARB keys     : ${keyRegistry.length}');
  print('  Manual review    : ${manual.length}');
  print('  Files to touch   : ${byFile.length}');
  print('');

  if (dryRun) {
    _printDryRunPlan(byFile, keyRegistry, manual, verbose);
    return;
  }

  // ── Step 5: write ARB files ──────────────────────────────────────────────
  if (!skipArb && keyRegistry.isNotEmpty) {
    print('▶ Writing ARB files ...');
    _writeArb(_enArbPath, enArb, keyRegistry, lang: 'en');
    _writeArb(_arArbPath, arArb, keyRegistry, lang: 'ar');
    print('  Done.\n');
  }

  // ── Step 6: resolve offsets then rewrite Dart files ─────────────────────
  print('▶ Resolving string offsets ...');
  for (final entry in byFile.entries) {
    final source = File(entry.key).readAsStringSync();
    _resolveOffsets(entry.value, source);
  }
  print('  Done.\n');

  print('▶ Rewriting Dart files ...');
  var filesDone = 0;
  var replacementsDone = 0;

  for (final entry in byFile.entries) {
    final filePath = entry.key;
    final replacements = entry.value;

    // Sort by offset descending so we can splice without shifting indices.
    replacements.sort((a, b) => b.offset.compareTo(a.offset));

    var source = File(filePath).readAsStringSync();

    for (final r in replacements) {
      if (r.offset < 0 || r.offset + r.originalLength > source.length) {
        if (verbose) {
          print('  SKIP (offset out of range): ${r.keyName} in $filePath');
        }
        continue;
      }

      final before = source.substring(0, r.offset);
      final after = source.substring(r.offset + r.originalLength);
      source = before + r.replacement + after;

      if (verbose) {
        print('  [${r.keyName}]  ${_short(r.originalText)}  →  ${r.replacement}');
      }
      replacementsDone++;
    }

    // Add import if missing.
    if (!source.contains('app_localizations')) {
      source = _addImport(source, filePath);
    }

    File(filePath).writeAsStringSync(source);
    filesDone++;
  }

  print('  Replaced $replacementsDone strings across $filesDone files.\n');

  // ── Step 7: manual review ────────────────────────────────────────────────
  if (manual.isNotEmpty) {
    print('══════════════════════════════════════════════════════');
    print('MANUAL REVIEW REQUIRED (${manual.length} items)');
    print('══════════════════════════════════════════════════════');
    for (final m in manual) {
      print('  ${m.finding.file}:${m.finding.line}:${m.finding.col}');
      print('    Text   : ${_short(m.finding.text)}');
      print('    Reason : ${m.reason}');
      print('');
    }
  }

  print('══════════════════════════════════════════════════════');
  print('Done. Run `flutter gen-l10n` to regenerate the l10n classes.');
  print('══════════════════════════════════════════════════════\n');
}

// ---------------------------------------------------------------------------
// Finding parser
// ---------------------------------------------------------------------------

// Line format produced by check_unlocalized_text.dart --locations-only:
// [HIGH]  lib/features/.../page.dart:42:10  (reason)  "text"
// [MED]   lib/features/.../page.dart:42:10  (reason)  "text"
final _findingRe = RegExp(
  r'^\[(HIGH|MED) *\]\s+'
  r'(lib/[^\s]+\.dart):(\d+):(\d+)\s+'
  r'\(([^)]+)\)\s+'
  r'"(.*)"$',
);

_Finding? _parseFinding(String line) {
  final m = _findingRe.firstMatch(line);
  if (m == null) return null;
  return _Finding(
    file: m.group(2)!,
    line: int.parse(m.group(3)!),
    col: int.parse(m.group(4)!),
    reason: m.group(5)!,
    text: m.group(6)!,
  );
}

bool _isRelevantPath(String line) {
  if (!line.contains('view/pages') && !line.contains('view/widgets')) {
    return false;
  }
  for (final frag in _skipPathFragments) {
    if (line.contains(frag)) return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// Replacement planner
// ---------------------------------------------------------------------------

_Replacement? _planReplacement({
  required _Finding finding,
  required Set<String> existingKeys,
  required Map<String, _ArbEntry> keyRegistry,
  required Map<String, dynamic> enArb,
}) {
  final rawText = finding.text;

  // Parse Dart string interpolations: collect ${expr} and $varName tokens.
  final interpolations = _extractInterpolations(rawText);

  // Build the clean text (interpolations stripped) for key name derivation.
  final cleanText = _stripInterpolations(rawText).trim();

  if (cleanText.length < 2 && interpolations.isEmpty) return null;

  // Derive a camelCase key.
  final key = _deriveKey(cleanText, existingKeys, keyRegistry);

  // Figure out the ARB value and ICU placeholders.
  String enValue;
  String arValue;
  List<_Placeholder> placeholders;

  if (interpolations.isEmpty) {
    // Plain string — both ARB values are the clean text.
    // English: we keep the Arabic text as-is (translator will update via Crowdin
    // or manually); the script marks EN value with a TODO prefix so it's obvious.
    final isArabic = _containsArabic(cleanText);
    arValue = cleanText;
    enValue = isArabic ? 'TODO: $cleanText' : cleanText; // ignore: todo
    placeholders = [];
  } else {
    // Interpolated string — convert to ICU.
    final result = _buildIcuString(rawText, interpolations);
    if (result == null) {
      return _Replacement.manual('complex interpolation');
    }
    arValue = result.icuString;
    enValue = _containsArabic(result.icuString)
        ? 'TODO: ${result.icuString}'
        : result.icuString;
    placeholders = result.placeholders;
  }

  // Check if this key already exists (exact value match → reuse, else create
  // a new suffixed key).
  if (existingKeys.contains(key)) {
    final existingValue = enArb[key];
    if (existingValue != arValue && existingValue != enValue) {
      // Different text, same derived key — suffix.
      final suffixed = _uniqueKey(key, existingKeys, keyRegistry);
      _registerKey(
          suffixed, enValue, arValue, placeholders, keyRegistry, existingKeys);
      return _buildReplacement(finding, suffixed, placeholders, rawText);
    }
    // Reuse existing key — no new ARB entry needed.
    return _buildReplacement(finding, key, placeholders, rawText,
        reuseKey: true);
  }

  // Brand-new key.
  if (!keyRegistry.containsKey(key)) {
    _registerKey(key, enValue, arValue, placeholders, keyRegistry, existingKeys);
  }
  return _buildReplacement(finding, key, placeholders, rawText);
}

_Replacement _buildReplacement(
  _Finding finding,
  String key,
  List<_Placeholder> placeholders,
  String rawText, {
  bool reuseKey = false,
}) {
  // Build the Dart replacement expression.
  String expr;
  if (placeholders.isEmpty) {
    expr = '$_l10nAccessor.$key';
  } else {
    // dartExpr is the raw interpolation token (e.g. "${days ~/ 30}" or "$days").
    // Strip the wrapping ${ } / $ to get the bare Dart expression for the call arg.
    final argList = placeholders.map((p) {
      final raw = p.dartExpr;
      if (raw.startsWith(r'${') && raw.endsWith('}')) {
        return raw.substring(2, raw.length - 1);
      }
      if (raw.startsWith(r'$')) {
        return raw.substring(1);
      }
      return raw;
    }).join(', ');
    expr = '$_l10nAccessor.$key($argList)';
  }

  // Determine the exact byte offset in the file so we can splice.
  // The finding gives us line:col (1-based), so we resolve it later when
  // we have the source. We store the finding and let the file-rewriting
  // step find the literal by scanning from that line.
  return _Replacement(
    file: finding.file,
    line: finding.line,
    col: finding.col,
    keyName: key,
    originalText: rawText,
    replacement: expr,
    reuseKey: reuseKey,
    offset: -1, // resolved in _resolveOffsets
    originalLength: 0, // resolved in _resolveOffsets
  );
}

// ---------------------------------------------------------------------------
// Offset resolution
//
// The check tool reports the offset of the opening quote, not the Dart
// string literal as a whole.  We scan the source for the literal starting
// near that line/col and return both its start offset and its full length
// (including quotes, prefix chars like r/b, and triple-quote variants).
// ---------------------------------------------------------------------------

// Called before we start rewriting.  Mutates each _Replacement in place.
void _resolveOffsets(List<_Replacement> replacements, String source) {
  for (final r in replacements) {
    final resolved = _findLiteralInSource(source, r.line, r.col, r.originalText);
    if (resolved != null) {
      r.offset = resolved.$1;
      r.originalLength = resolved.$2;
    }
    // If not found we leave offset = -1; the caller will skip this one.
  }
}

(int, int)? _findLiteralInSource(
  String source,
  int targetLine,
  int targetCol,
  String expectedContent,
) {
  // Walk to the line start.
  var lineNum = 1;
  var lineStart = 0;
  while (lineNum < targetLine) {
    final next = source.indexOf('\n', lineStart);
    if (next == -1) return null;
    lineStart = next + 1;
    lineNum++;
  }

  // col is 1-based column of the opening quote character.
  final approxOffset = lineStart + targetCol - 1;

  // Search a window around that offset for a matching string literal.
  final searchStart = (approxOffset - 5).clamp(0, source.length);
  final searchEnd = (approxOffset + 300).clamp(0, source.length);

  return _scanForLiteral(source, searchStart, searchEnd, expectedContent);
}

(int, int)? _scanForLiteral(
  String source,
  int from,
  int to,
  String expectedContent,
) {
  var i = from;
  while (i < to) {
    final ch = source[i];

    // Skip string prefix characters (r, b, etc.) before the quote.
    final prefixLen =
        (ch == 'r' || ch == 'b') && i + 1 < source.length ? 1 : 0;
    final quoteIdx = i + prefixLen;
    if (quoteIdx >= source.length) break;

    final q = source[quoteIdx];
    if (q != "'" && q != '"') {
      i++;
      continue;
    }

    // Detect triple-quote.
    final triple = quoteIdx + 2 < source.length &&
        source[quoteIdx + 1] == q &&
        source[quoteIdx + 2] == q;
    final contentStart = quoteIdx + (triple ? 3 : 1);

    // Find the closing quote.
    final end = _findLiteralEnd(source, contentStart, q, triple: triple);
    if (end == -1) {
      i++;
      continue;
    }

    final rawContent = source.substring(
        contentStart, end - (triple ? 3 : 1));
    final decoded = _decodeRaw(rawContent);

    if (_normalise(decoded) == _normalise(expectedContent)) {
      return (i, end - i);
    }
    i++;
  }
  return null;
}

String _normalise(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').trim();

int _findLiteralEnd(String source, int start, String q,
    {required bool triple}) {
  var i = start;
  while (i < source.length) {
    if (source[i] == r'\') {
      i += 2;
      continue;
    }
    if (triple) {
      if (i + 2 < source.length &&
          source[i] == q &&
          source[i + 1] == q &&
          source[i + 2] == q) {
        return i + 3;
      }
      i++;
      continue;
    }
    if (source[i] == q) return i + 1;
    i++;
  }
  return -1;
}

String _decodeRaw(String raw) => raw
    .replaceAll(r'\n', '\n')
    .replaceAll(r'\t', '\t')
    .replaceAll(r"\'", "'")
    .replaceAll(r'\"', '"');

// ---------------------------------------------------------------------------
// Interpolation handling
// ---------------------------------------------------------------------------

final _interpRe = RegExp(r'\$\{([^}]+)\}|\$([A-Za-z_][A-Za-z0-9_]*)');

List<_InterpToken> _extractInterpolations(String rawText) {
  return _interpRe.allMatches(rawText).map((m) {
    final expr = m.group(1) ?? m.group(2)!;
    return _InterpToken(
      fullMatch: m.group(0)!,
      expr: expr,
      start: m.start,
      end: m.end,
    );
  }).toList();
}

String _stripInterpolations(String text) =>
    text.replaceAll(_interpRe, '').replaceAll(RegExp(r'\s+'), ' ').trim();

_IcuResult? _buildIcuString(
  String rawText,
  List<_InterpToken> tokens,
) {
  // Map each unique expression to a placeholder name.
  final exprToName = <String, String>{};
  final placeholders = <_Placeholder>[];

  for (final token in tokens) {
    if (exprToName.containsKey(token.expr)) continue;

    final name = _exprToPlaceholderName(token.expr);
    if (name == null) return null; // Too complex — flag for manual review.

    exprToName[token.expr] = name;

    // Determine type heuristic:
    // - ends in .length, Count, count, .inDays, .inHours, .inMinutes → int
    // - otherwise Object (safe for any Dart type)
    final type = _inferPlaceholderType(token.expr);
    placeholders.add(_Placeholder(
      name: name,
      dartExpr: token.fullMatch.startsWith(r'${') ? token.fullMatch : token.fullMatch,
      type: type,
    ));
  }

  // Build ICU string by replacing each interpolation with {name}.
  var icu = rawText;
  // Replace longest matches first to avoid partial replacements.
  final sortedTokens = List.of(tokens)
    ..sort((a, b) => b.fullMatch.length.compareTo(a.fullMatch.length));
  for (final token in sortedTokens) {
    final name = exprToName[token.expr]!;
    icu = icu.replaceAll(token.fullMatch, '{$name}');
  }

  return _IcuResult(icuString: icu, placeholders: placeholders);
}

String? _exprToPlaceholderName(String expr) {
  // Map subscript access like data['key'] or items[i] → too dynamic, skip.
  if (expr.contains('[') || expr.contains(']')) return null;

  // $var → var
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(expr)) return expr;

  // ${simple.property} or ${simple.property.property} → last segment
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_.]+$').hasMatch(expr)) {
    return expr.split('.').last;
  }

  // ${obj.toStringAsFixed(n)} → obj name
  final fixedMatch =
      RegExp(r'^([A-Za-z_][A-Za-z0-9_.]*)\.toStringAsFixed\(\d+\)$')
          .firstMatch(expr);
  if (fixedMatch != null) {
    final base = fixedMatch.group(1)!.split('.').last;
    // Strip trailing ! (null-assert)
    return base.replaceAll('!', '');
  }

  // ${expr ~/ divisor} — integer division, e.g. days ~/ 30 → days
  final intDivMatch =
      RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*~\/\s*\d+$').firstMatch(expr);
  if (intDivMatch != null) return intDivMatch.group(1);

  // ${obj.method()} → method
  final methodMatch = RegExp(r'\.(\w+)\(\)$').firstMatch(expr);
  if (methodMatch != null) return methodMatch.group(1);

  // ${(expr).floor()} → value
  if (expr.contains('.floor()') || expr.contains('.ceil()') ||
      expr.contains('.round()')) {
    return 'value';
  }

  // ${numericExpr} where it's just math/number formatting → value
  if (RegExp(r'^[\w\s./*()+\-]+$').hasMatch(expr)) return 'value';

  return null; // Too complex.
}

String _inferPlaceholderType(String expr) {
  if (expr.contains('.length') ||
      expr.contains('Count') ||
      expr.contains('count') ||
      expr.contains('.inDays') ||
      expr.contains('.inHours') ||
      expr.contains('.inMinutes') ||
      expr.contains('.floor()') ||
      expr.contains('.ceil()') ||
      expr.contains('.round()') ||
      RegExp(r'~\/\s*\d+').hasMatch(expr)) {
    return 'int';
  }
  if (expr.contains('.toStringAsFixed(')) return 'double';
  return 'Object';
}

// ---------------------------------------------------------------------------
// Key derivation
// ---------------------------------------------------------------------------

String _deriveKey(String text, Set<String> existing, Map<String, _ArbEntry> registry) {
  final isArabic = _containsArabic(text);

  String base;
  if (isArabic) {
    base = _arabicToKey(text);
  } else {
    base = _englishToKey(text);
  }

  if (base.isEmpty) base = 'text';

  return _uniqueKey(base, existing, registry);
}

String _uniqueKey(String base, Set<String> existing, Map<String, _ArbEntry> registry) {
  if (!existing.contains(base) && !registry.containsKey(base)) return base;
  var i = 2;
  while (existing.contains('$base$i') || registry.containsKey('$base$i')) {
    i++;
  }
  return '$base$i';
}

String _englishToKey(String text) {
  // Take first 6 meaningful words (min length 2), camelCase them.
  final words = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length >= 2 && !_stopWords.contains(w))
      .take(6)
      .toList();
  if (words.isEmpty) return 'label';
  // Require at least the first word to be ≥3 chars to avoid single-char keys.
  final first = words.first.length >= 3 ? words.first : words.join();
  if (first.isEmpty) return 'label';
  return first +
      words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

// A simple Arabic → Latin transliteration for key names.
// We map common Arabic words to English equivalents so the keys are readable.
String _arabicToKey(String text) {
  // First try exact-phrase lookups.
  final stripped = _stripInterpolations(text).trim();

  for (final entry in _arabicKeyMap.entries) {
    if (stripped == entry.key || stripped.contains(entry.key)) {
      return entry.value;
    }
  }

  // Fallback: transliterate word-by-word and camelCase.
  final words = stripped
      .replaceAll(RegExp(r'[^؀-ۿ\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(5)
      .map(_transliterateArabicWord)
      .where((w) => w.isNotEmpty)
      .toList();

  if (words.isEmpty) return 'arabicLabel';
  return words.first +
      words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

// Most-used Arabic UI phrases → readable English key names.
const _arabicKeyMap = {
  'إلغاء': 'cancel',
  'تأكيد': 'confirm',
  'حفظ': 'save',
  'إرسال': 'submit',
  'موافق': 'ok',
  'نعم': 'yes',
  'لا': 'no',
  'تحميل': 'loading',
  'جارٍ التحميل': 'loading',
  'جاري التحميل': 'loading',
  'جارٍ التحميل...': 'loadingEllipsis',
  'جاري الإرسال...': 'submittingEllipsis',
  'تحديث': 'refresh',
  'بحث': 'search',
  'فلتر': 'filter',
  'الكل': 'all',
  'إضافة': 'add',
  'تعديل': 'edit',
  'حذف': 'delete',
  'عرض': 'view',
  'إغلاق': 'close',
  'رجوع': 'back',
  'العودة': 'goBack',
  'التالي': 'next',
  'السابق': 'previous',
  'نشط': 'active',
  'غير نشط': 'inactive',
  'منتهي': 'expired',
  'قادم': 'upcoming',
  'مُباع': 'sold',
  'غير مُباع': 'unsold',
  'مغلق': 'closed',
  'تقديم شكوى': 'submitComplaint',
  'تقديم الشكوى': 'submitComplaintAction',
  'الشكاوى': 'complaints',
  'لا توجد شكاوى حتى الآن': 'noComplaints',
  'لا يوجد وصف': 'noDescription',
  'لا يوجد وصف.': 'noDescriptionDot',
  'ملاحظة الإدارة': 'adminNote',
  'زايد الآن': 'bidNow',
  'اشتري الآن': 'buyNow',
  'شراء فوري': 'instantBuy',
  'تقديم مزايدة': 'placeBid',
  'تمت المزايدة بنجاح': 'bidSuccessful',
  'سعر البداية': 'startingPrice',
  'السعر الحالي': 'currentPrice',
  'الحد الأدنى': 'minimumBid',
  'الحد الأدنى للمزايدة': 'minimumBidAmount',
  'أدخل رقمًا صحيحًا': 'enterValidNumber',
  'عرض تفاصيل الدفع': 'viewPaymentDetails',
  'إرسال طلب دفع': 'sendPaymentRequest',
  'ملاحظة للبائع (اختياري)': 'noteToSellerOptional',
  'هذا مزادك — لا يمكنك المزايدة': 'cannotBidOwnAuction',
  'انتهى المزاد': 'auctionEnded',
  'المزاد لم يبدأ بعد': 'auctionNotStarted',
  'فردي': 'singleType',
  'متعدد': 'multipleType',
  'زوج': 'pairType',
  'تناسل': 'breedingType',
  'سباق': 'racingType',
  'باقة': 'packageLabel',
  'نقاط': 'pointsLabel',
  'اشترك': 'subscribe',
  'لا توجد باقة نشطة — ستُرفض عملية الإنشاء': 'noActivePackageWarning',
  'إضافة طائر جديد': 'addNewBird',
  'اختيار من طيوري': 'chooseFromMyBirds',
  'اختر طائراً': 'chooseBird',
  'طيوري المتاحة للإضافة في المزاد': 'myBirdsAvailableForAuction',
  'لا توجد طيور متاحة': 'noBirdsAvailable',
  'جميع طيورك مدرجة في مزادات أو المتجر': 'allBirdsListed',
  'غير محدد': 'notSpecified',
  'غير متاح': 'notAvailable',
  'مشتري': 'buyer',
  'مستخدم': 'user',
  'الآن': 'now',
  'تحميل المزيد': 'loadMore',
  'مزايداتي': 'myBids',
  'من أتابع': 'following',
  'لا تتابع أحداً بعد': 'notFollowingAnyone',
  'مربيون قد تعرفهم': 'peopleMayKnow',
  'لا توجد اقتراحات حالياً': 'noSuggestionsNow',
  'الغرف': 'rooms',
  'غرفة': 'room',
  'معروضة': 'listed',
  'مزاد': 'auction',
  'عنصر': 'item',
  'تقييم': 'rating',
  'لا توجد غرف حالياً': 'noRoomsNow',
  'حدث خطأ': 'errorOccurred',
  'فشل تحميل الرسائل': 'failedToLoadMessages',
  'يجب متابعة البائع أولاً': 'mustFollowSellerFirst',
  'ابدأ المحادثة بإرسال رسالة': 'startConversationMessage',
  'لا توجد محادثات بعد': 'noConversationsYet',
  'اعتراض على رفض الدفع': 'paymentRejectionDispute',
  'شكوى ما بعد البيع': 'postSaleComplaint',
  'رقم الشكوى': 'complaintNumber',
  'طلب الدفع': 'paymentRequest',
  'النوع': 'type',
  'تاريخ الإنشاء': 'creationDate',
  'تاريخ الحل': 'resolutionDate',
  'تاريخ الإلغاء': 'cancellationDate',
};

// Simple Arabic → Latin letter mapping for fallback.
String _transliterateArabicWord(String word) {
  const map = {
    'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'a', 'ب': 'b', 'ت': 't', 'ث': 'th',
    'ج': 'j', 'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'th', 'ر': 'r', 'ز': 'z',
    'س': 's', 'ش': 'sh', 'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': 'a',
    'غ': 'gh', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
    'ه': 'h', 'و': 'w', 'ي': 'y', 'ى': 'a', 'ة': 'a', 'ء': '', 'ئ': 'y',
    'ؤ': 'w', 'ُ': '', 'ِ': '', 'َ': '', 'ّ': '', 'ْ': '', 'ً': '', 'ٌ': '',
    'ٍ': '',
  };
  return word.runes
      .map((r) => map[String.fromCharCode(r)] ?? '')
      .join()
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

const _stopWords = {
  'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
  'of', 'with', 'is', 'are', 'was', 'be', 'it', 'this', 'that',
};

bool _containsArabic(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);

// Strings that are dev/test defaults, not real UI text.
bool _isDevValue(String text) {
  // Phone number masks or defaults.
  if (RegExp(r'^\+?\d[\dX\s\-x]+$').hasMatch(text)) return true;
  // Passwords or credential placeholders.
  if (RegExp(r'^[A-Za-z]+\d+[!@#\$%^&*]+$').hasMatch(text)) return true;
  // ID-format strings like EG-2024-001.
  if (RegExp(r'^[A-Z]{2,}-\d{4}-\d{3,}$').hasMatch(text)) return true;
  return false;
}

// ---------------------------------------------------------------------------
// ARB key registration & writing
// ---------------------------------------------------------------------------

void _registerKey(
  String key,
  String enValue,
  String arValue,
  List<_Placeholder> placeholders,
  Map<String, _ArbEntry> registry,
  Set<String> existingKeys,
) {
  registry[key] = _ArbEntry(
    key: key,
    enValue: enValue,
    arValue: arValue,
    placeholders: placeholders,
  );
  existingKeys.add(key); // prevent future duplicates
}

Map<String, dynamic> _loadArb(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void _writeArb(
  String path,
  Map<String, dynamic> existing,
  Map<String, _ArbEntry> newEntries,
  {required String lang}
) {
  final out = <String, dynamic>{...existing};

  for (final entry in newEntries.values) {
    final value = lang == 'ar' ? entry.arValue : entry.enValue;
    out[entry.key] = value;

    final meta = <String, dynamic>{};
    if (entry.placeholders.isNotEmpty) {
      final placeholdersMeta = <String, dynamic>{};
      for (final p in entry.placeholders) {
        placeholdersMeta[p.name] = {'type': p.type};
      }
      meta['placeholders'] = placeholdersMeta;
    }
    out['@${entry.key}'] = meta;
  }

  // Serialise preserving existing key order, then appending new keys at end.
  final buf = StringBuffer('{\n');
  var first = true;
  for (final k in out.keys) {
    if (!first) buf.write(',\n');
    first = false;
    final v = out[k];
    if (v is String) {
      buf.write('  ${jsonEncode(k)}: ${jsonEncode(v)}');
    } else if (v is Map) {
      buf.write('  ${jsonEncode(k)}: ${jsonEncode(v)}');
    } else {
      buf.write('  ${jsonEncode(k)}: ${jsonEncode(v)}');
    }
  }
  buf.write('\n}\n');

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Import injection
// ---------------------------------------------------------------------------

String _addImport(String source, String filePath) {
  // Compute the relative path depth to l10n/.
  // e.g. lib/features/auctions/view/pages/foo.dart → ../../../../l10n/
  final parts = filePath.replaceAll('\\', '/').split('/');
  final libIndex = parts.indexOf('lib');
  if (libIndex == -1) return source;
  final depth = parts.length - libIndex - 2; // dirs below lib/
  final prefix = '../' * depth;
  final importLine = "import '${prefix}l10n/app_localizations.dart';";

  // Insert after last existing import line.
  final lines = source.split('\n');
  var lastImportIdx = -1;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trimLeft().startsWith('import ')) lastImportIdx = i;
  }

  if (lastImportIdx >= 0) {
    lines.insert(lastImportIdx + 1, importLine);
  } else {
    lines.insert(0, importLine);
  }
  return lines.join('\n');
}

// ---------------------------------------------------------------------------
// Dry-run output
// ---------------------------------------------------------------------------

void _printDryRunPlan(
  Map<String, List<_Replacement>> byFile,
  Map<String, _ArbEntry> keyRegistry,
  List<_ManualItem> manual,
  bool verbose,
) {
  print('── New ARB keys (${keyRegistry.length}) ──────────────────────────────');
  for (final e in keyRegistry.values) {
    if (e.placeholders.isEmpty) {
      print('  "${e.key}": "${e.arValue}"');
    } else {
      print('  "${e.key}": "${e.arValue}"  '
          '[params: ${e.placeholders.map((p) => "${p.name}:${p.type}").join(", ")}]');
    }
  }

  if (verbose) {
    print('');
    print('── Replacements by file ─────────────────────────────────────────');
    for (final entry in byFile.entries) {
      print('  ${entry.key}');
      for (final r in entry.value) {
        print('    L${r.line} [${r.keyName}]  ${_short(r.originalText)}');
      }
    }
  }

  if (manual.isNotEmpty) {
    print('');
    print('── Manual review items (${manual.length}) ──────────────────────────');
    for (final m in manual) {
      print('  ${m.finding.file}:${m.finding.line}');
      print('    ${_short(m.finding.text)}  (${m.reason})');
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _short(String s) {
  const max = 60;
  return s.length > max ? '${s.substring(0, max)}…' : s;
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _Finding {
  final String file;
  final int line;
  final int col;
  final String reason;
  final String text;
  const _Finding({
    required this.file,
    required this.line,
    required this.col,
    required this.reason,
    required this.text,
  });
}

class _Replacement {
  final String file;
  final int line;
  final int col;
  final String keyName;
  final String originalText;
  final String replacement;
  final bool reuseKey;
  int offset;
  int originalLength;
  bool get needsManualReview => _manualReason != null;
  String? get manualReason => _manualReason;
  final String? _manualReason;

  _Replacement({
    required this.file,
    required this.line,
    required this.col,
    required this.keyName,
    required this.originalText,
    required this.replacement,
    required this.reuseKey,
    required this.offset,
    required this.originalLength,
    String? manualReason,
  }) : _manualReason = manualReason;

  factory _Replacement.manual(String reason) => _Replacement(
        file: '',
        line: 0,
        col: 0,
        keyName: '',
        originalText: '',
        replacement: '',
        reuseKey: false,
        offset: -1,
        originalLength: 0,
        manualReason: reason,
      );
}

class _InterpToken {
  final String fullMatch;
  final String expr;
  final int start;
  final int end;
  const _InterpToken({
    required this.fullMatch,
    required this.expr,
    required this.start,
    required this.end,
  });
}

class _Placeholder {
  final String name;
  final String dartExpr; // original Dart interpolation expression
  final String type;    // 'int' | 'String' | 'Object'
  const _Placeholder({
    required this.name,
    required this.dartExpr,
    required this.type,
  });
}

class _IcuResult {
  final String icuString;
  final List<_Placeholder> placeholders;
  const _IcuResult({required this.icuString, required this.placeholders});
}

class _ArbEntry {
  final String key;
  final String enValue;
  final String arValue;
  final List<_Placeholder> placeholders;
  const _ArbEntry({
    required this.key,
    required this.enValue,
    required this.arValue,
    required this.placeholders,
  });
}

class _ManualItem {
  final _Finding finding;
  final String reason;
  const _ManualItem({required this.finding, required this.reason});
}
