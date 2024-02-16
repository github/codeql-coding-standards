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

/**
 * A literal resulting from the use of a constexpr
 * variable, or macro expansion.
 */
class CompileTimeComputedIntegralLiteral extends Literal {
  CompileTimeComputedIntegralLiteral() {
    this.getUnspecifiedType() instanceof IntegralType and
    not this.getUnspecifiedType() instanceof BoolType and
    not this.getUnspecifiedType() instanceof CharType and
    // In some cases we still type char constants like '.' as int
    not this.getValueText().trim().matches("'%'") and
    not this.getValueText()
        .trim()
        .regexpMatch("([0-9][0-9']*|0[xX][0-9a-fA-F']+|0b[01']+)[uU]?([lL]{1,2}|[zZ])?") and
    // Exclude class field initializers whose value text equals the initializer expression, e.g., `x(0)`
    not any(ConstructorFieldInit cfi).getExpr() = this
  }
}
