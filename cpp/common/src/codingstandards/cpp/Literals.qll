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
