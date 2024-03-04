/**
 * Provides a library for working with standard literals.
 */

import cpp
import codingstandards.cpp.Cpp14Literal

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
 * We rely on the fact that the value text of a literal is equal to the
 * `constexpr` variable or macro name.
 */
class CompileTimeComputedIntegralLiteral extends Literal {
  CompileTimeComputedIntegralLiteral() {
    this.getUnspecifiedType() instanceof IntegralType and
    // Exclude bool, whose value text is true or false, but the value itself
    // is 1 or 0.
    not this instanceof BoolLiteral and
    // Exclude character literals, whose value text is the quoted character, but the value
    // is the numeric value of the character.
    not this instanceof Cpp14Literal::CharLiteral and
    not this.getValueText()
        .trim()
        .regexpMatch("([0-9][0-9']*|0[xX][0-9a-fA-F']+|0b[01']+)[uU]?([lL]{1,2}|[zZ])?") and
    // Exclude class field initializers whose value text equals the initializer expression, e.g., `x(0)`
    not any(ConstructorFieldInit cfi).getExpr() = this
  }
}

class BoolLiteral extends Literal {
  BoolLiteral() {
    this.getType() instanceof BoolType
    or
    // When used as non-type template arguments, bool literals might
    // have been converted to a non-bool type.
    this.getValue() = "1" and this.getValueText() = "true"
    or
    this.getValue() = "0" and this.getValueText() = "false"
  }
}
