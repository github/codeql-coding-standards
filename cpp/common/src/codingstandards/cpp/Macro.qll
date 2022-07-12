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
      result = this.getBody().indexOf(parameter)
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
