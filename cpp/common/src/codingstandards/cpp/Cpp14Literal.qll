/**
 * A module which models C++14 literals.
 *
 * This module should not be imported unqualified, as it clashes with some standard library classes.
 */
module Cpp14Literal {
  private import cpp as StandardLibrary

  /** An numeric literal. */
  abstract class NumericLiteral extends StandardLibrary::Literal { }

  /** An integer literal. */
  abstract class IntegerLiteral extends NumericLiteral {
    predicate isSigned() { not isUnsigned() }

    predicate isUnsigned() { getValueText().regexpMatch(".*[uU][lL]?$") }
  }

  /**
   * An octal literal. For example:
   * ```
   * char esc = 033;
   * ```
   * Octal literals must always start with the digit `0`.
   */
  class OctalLiteral extends IntegerLiteral {
    OctalLiteral() { getValueText().regexpMatch("\\s*0[0-7']*[uUlL]*\\s*") }

    override string getAPrimaryQlClass() { result = "OctalLiteral" }
  }

  /**
   * A hexadecimal literal.
   * ```
   * unsigned int32_t minus2 = 0xfffffffe;
   * ```
   */
  class HexLiteral extends IntegerLiteral {
    HexLiteral() { getValueText().regexpMatch("\\s*0[xX][0-9a-fA-F']+[uUlL]*\\s*") }

    override string getAPrimaryQlClass() { result = "HexLiteral" }
  }

  /**
   * A binary literal.
   * ```
   * unsigned int32_t binary = 0b101010;
   * ```
   */
  class BinaryLiteral extends IntegerLiteral {
    BinaryLiteral() { getValueText().regexpMatch("\\s*0[bB][0-1']*[uUlL]*\\s*") }

    override string getAPrimaryQlClass() { result = "BinaryLiteral" }
  }

  /**
   * A decimal literal.
   * ```
   * unsigned int32_t decimal = 10340923;
   * ```
   */
  class DecimalLiteral extends IntegerLiteral {
    DecimalLiteral() { getValueText().regexpMatch("\\s*[1-9][0-9']*[uUlL]*\\s*") }

    override string getAPrimaryQlClass() { result = "DecimalLiteral" }
  }

  /**
   * A floating literal.
   * ```
   * double floating = 1.340923e-19;
   * ```
   */
  class FloatingLiteral extends NumericLiteral {
    FloatingLiteral() {
      getValueText().regexpMatch("\\s*[0-9][0-9']*(\\.[0-9']+)?([eE][\\+\\-]?[0-9']+)?[flFL]?\\s*") and
      // A decimal literal takes precedent
      not this instanceof DecimalLiteral and
      // Not '0' only
      not this instanceof OctalLiteral
    }

    override string getAPrimaryQlClass() { result = "FloatingLiteral" }
  }

  /**
   * A character literal.  For example:
   * ```
   * char c1 = 'a';
   * char16_t c2 = u'a';
   * char32_t c3 = U'a';
   * wchar_t c4 = L'b';
   * ```
   */
  class CharLiteral extends StandardLibrary::TextLiteral {
    CharLiteral() { this.getValueText().regexpMatch("(?s)\\s*(L|u|U)?'.*") }

    override string getAPrimaryQlClass() { result = "CharLiteral" }

    /**
     * Gets the character of this literal. For example `L'a'` has character `"a"`.
     */
    string getCharacter() {
      result = this.getValueText().regexpCapture("(?s)\\s*(L|u|U)?'(.*)'", 1)
    }
  }
}
