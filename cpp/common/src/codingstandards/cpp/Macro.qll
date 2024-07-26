import cpp

/**
 * Macros with a parameter
 */
class FunctionLikeMacro extends Macro {
  FunctionLikeMacro() { this.getHead().regexpMatch("[_a-zA-Z0-9]+\\s*\\([^\\)]*?\\)") }

  string getParameter(int i) {
    result =
      this.getHead().regexpCapture("[_a-zA-Z0-9]+\\s*\\(([^\\)]*)\\)", 1).splitAt(",", i).trim()
  }

  string getAParameter() { result = getParameter(_) }

  int getAParameterUse(int index) {
    exists(string parameter | parameter = getParameter(index) |
      // Find identifier tokens in the program that match the parameter name
      exists(this.getBody().regexpFind("\\#?\\b" + parameter + "\\b", _, result))
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
