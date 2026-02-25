import codeql.util.Numbers

/**
 * Provides properties of a Unicode code point, where the property is of 'enumeration', 'catalog',
 * or 'string-valued' type, however, the only supported property is `NFC_QC`.
 *
 * For example, `Block` is an enumeration property, `Line_Break` is a catalog property, and
 * `Uppercase_Mapping` is a string-valued property.
 *
 * For boolean properties, see `unicodeHasBooleanProperty`, and for numeric properties, see
 * `unicodeHasNumericProperty`.
 */
extensible predicate unicodeHasProperty(int codePoint, string propertyName, string propertyValue);

/**
 * Holds when the Unicode code point's boolean property of the given name is true.
 *
 * For example, `Alphabetic` is a boolean property that can be true or false for a code point.
 *
 * For other types of properties, see `unicodeHasProperty`.
 */
extensible predicate unicodeHasBooleanProperty(int codePoint, string propertyName);

bindingset[input]
int unescapedCodePointAt(string input, int index) {
  exists(string match |
    match = input.regexpFind("(\\\\u[0-9a-fA-F]{4}|.)", index, _) and
    if match.matches("\\u%")
    then result = parseHexInt(match.substring(2, match.length()))
    else result = match.codePointAt(0)
  )
}

bindingset[input]
string unescapeUnicode(string input) {
  result =
    concat(int code, int idx |
      code = unescapedCodePointAt(input, idx)
    |
      code.toUnicode() order by idx
    )
}

bindingset[id]
predicate nonUax44IdentifierCodepoint(string id, int index) {
  exists(int codePoint |
    codePoint = id.codePointAt(index) and
    (
      not unicodeHasBooleanProperty(codePoint, "XID_Start") and
      not unicodeHasBooleanProperty(codePoint, "XID_Continue")
      or
      index = 0 and
      not unicodeHasBooleanProperty(codePoint, "XID_Start")
    )
  )
}

bindingset[id]
predicate nonNfcNormalizedCodepoint(string id, int index, string noOrMaybe) {
  exists(int codePoint |
    codePoint = id.codePointAt(index) and
    unicodeHasProperty(codePoint, "NFC_QC", noOrMaybe) and
    noOrMaybe = ["N", "M"]
  )
}
