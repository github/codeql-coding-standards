/**
 * Provides a library for working with standard literals.
 */

import cpp

/** Gets `Literal.getValueText()` truncated to at most 20 characters. */
string getTruncatedLiteralText(Literal l) {
  exists(string text | text = l.getValueText() |
    if text.length() > 20
    then result = text.prefix(12) + "..." + text.suffix(text.length() - 5)
    else result = text
  )
}

class WideStringLiteral extends StringLiteral {
  WideStringLiteral() { this.getValueText().regexpMatch("(?s)\\s*L\".*") }
}

class Utf8StringLiteral extends StringLiteral {
  Utf8StringLiteral() { this.getValueText().regexpMatch("(?s)\\s*u8\".*") }
}

class Utf16StringLiteral extends StringLiteral {
  Utf16StringLiteral() { this.getValueText().regexpMatch("(?s)\\s*u\".*") }
}

class Utf32StringLiteral extends StringLiteral {
  Utf32StringLiteral() { this.getValueText().regexpMatch("(?s)\\s*U\".*") }
}
