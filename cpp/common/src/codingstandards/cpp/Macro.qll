import cpp

/**
 * Macros with parentheses, e.g. `#define MACRO(x) (x * 2)`.
 *
 * Note that this includes macros with empty parameter lists, e.g. `#define MACRO() 42`.
 */
class FunctionLikeMacro extends Macro {
  FunctionLikeMacro() { this.getHead().regexpMatch("[_a-zA-Z0-9]+\\s*\\([^\\)]*?\\)") }

  string getParameter(int i) {
    result =
      this.getHead()
          .regexpCapture("[_a-zA-Z0-9]+\\s*\\(([^\\)]*)\\)", 1)
          .splitAt(",", i)
          .trim()
          .replaceAll("...", "") and
    not result = ""
  }

  string getAParameter() { result = getParameter(_) }

  int getAParameterUse(int index) {
    exists(string parameter | parameter = getParameter(index) |
      // Find identifier tokens in the program that match the parameter name
      exists(this.getBody().regexpFind("\\#?\\b" + parameter + "\\b", _, result))
    )
  }

  /**
   * Holds if the parameter is used in a way that may make it vulnerable to precedence issues.
   *
   * Typically, parameters are wrapped in parentheses to protect them from precedence issues, but
   * that is not always possible.
   */
  predicate parameterPrecedenceUnprotected(int index) {
    // Check if the parameter is used in a way that requires parentheses
    exists(string parameter | parameter = getParameter(index) |
      // Finds any occurence of the parameter that is not preceded by, or followed by, either a
      // parenthesis or the '#' token operator.
      //
      // Note the following cases:
      // - "(x + 1)" is preceded by a parenthesis, but not followed by one, so SHOULD be matched.
      // - "x # 1" is followed by "#" (though not preceded by #) and SHOULD be matched.
      // - "(1 + x)" is followed by a parenthesis, but not preceded by one, so SHOULD be matched.
      // - "1 # x" is preceded by "#" (though not followed by #) and SHOULD NOT be matched.
      //
      // So the regex is structured as follows:
      // - paramMatch: Matches the parameter at a word boundary, with optional whitespace
      // - notHashed: Finds parameters not used with a leading # operator.
      // - The final regex finds cases of `notHashed` that are not preceded by a parenthesis,
      //   and cases of `notHashed` that are not followed by a parenthesis.
      //
      // Therefore, a parameter with parenthesis on both sides is not matched, a parameter with
      // parenthesis missing on one or both sides is only matched if there is no leading or trailing
      // ## operator.
      exists(string noBeforeParen, string noAfterParen, string paramMatch, string notHashed |
        // Not preceded by a parenthesis
        noBeforeParen = "(?<!\\(\\s*)" and
        // Not followed by a parenthesis
        noAfterParen = "(?!\\s*\\))" and
        // Parameter at word boundary in optional whitespace
        paramMatch = "\\s*\\b" + parameter + "\\b\\s*" and
        // A parameter is ##'d if it is preceded or followed by the # operator.
        notHashed = "(?<!#)" + paramMatch and
        // Parameter is used without a leading or trailing parenthesis, and without #.
        getBody()
            .regexpMatch(".*(" + noBeforeParen + notHashed + "|" + notHashed + noAfterParen + ").*")
      )
    )
  }
}

newtype TMacroOperator =
  TTokenPastingOperator(FunctionLikeMacro m, string operand, int operatorOffset, int operandOffset) {
    m.getAParameter() = operand and
    (
      exists(string match |
        match = m.getBody().regexpFind("#{2}\\s*" + operand, _, operatorOffset)
      |
        operandOffset = operatorOffset + match.indexOf(operand)
      )
      or
      exists(string match | match = m.getBody().regexpFind(operand + "\\s*#{2}", _, operandOffset) |
        operatorOffset = operandOffset + match.indexOf("##")
      )
    )
  } or
  TStringizingOperator(FunctionLikeMacro m, string operand, int operatorOffset, int operandOffset) {
    operand = m.getAParameter() and
    exists(string match |
      match = m.getBody().regexpFind("(?<!#)#\\s*" + operand, _, operatorOffset)
    |
      operandOffset = operatorOffset + match.indexOf(operand)
    )
  }

class TokenPastingOperator extends TTokenPastingOperator {
  string getOperand() { this = TTokenPastingOperator(_, result, _, _) }

  FunctionLikeMacro getMacro() { this = TTokenPastingOperator(result, _, _, _) }

  int getOffset() { this = TTokenPastingOperator(_, _, result, _) }

  string toString() { result = getMacro().toString() }
}

class StringizingOperator extends TStringizingOperator {
  string getOperand() { this = TStringizingOperator(_, result, _, _) }

  FunctionLikeMacro getMacro() { this = TStringizingOperator(result, _, _, _) }

  int getOffset() { this = TStringizingOperator(_, _, result, _) }

  string toString() { result = getMacro().toString() }
}

pragma[noinline]
predicate isMacroInvocationLocation(MacroInvocation mi, File f, int startChar, int endChar) {
  mi.getActualLocation().charLoc(f, startChar, endChar)
}

/** A macro within the source location of this project. */
class UserProvidedMacro extends Macro {
  UserProvidedMacro() {
    exists(this.getFile().getRelativePath()) and
    // Exclude macros in our standard library header stubs for tests, because qltest sets the source
    // root to the qlpack root, which means our stubs all look like source files.
    //
    // This may affect "real" code as well, if it happens to be at this path, but given the name
    // I think it's likely that we'd want that to be the case anyway.
    not this.getFile().getRelativePath().substring(0, "includes/standard-library".length()) =
      "includes/standard-library"
  }
}

/** A macro defined within a library used by this project. */
class LibraryMacro extends Macro {
  LibraryMacro() { not this instanceof UserProvidedMacro }
}

/**
 * A macro which is suggestive that it is used to determine the precision of an integer.
 */
class PrecisionMacro extends Macro {
  PrecisionMacro() { this.getName().toLowerCase().matches("precision") }
}
