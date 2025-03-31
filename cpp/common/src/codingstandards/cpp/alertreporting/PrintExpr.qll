import cpp

signature class ShouldPrettyPrint extends Expr;

module PrintExpr<ShouldPrettyPrint PrintExpr> {
  bindingset[e]
  string print(Expr e) {
    if not e instanceof PrintExpr
    then result = e.toString()
    else
      if exists(getMacroInvocationString(e))
      then result = getMacroInvocationString(e)
      else
        if e instanceof SupportedExpr
        then result = e.(SupportedExpr).getExprString()
        else result = e.toString()
  }

  private string getMacroInvocationString(PrintExpr e) {
    exists(MacroInvocation mi |
      mi.getExpr() = e and
      result = mi.getMacroName()
    )
  }

  final class FinalPrintExpr = PrintExpr;

  abstract class SupportedExpr extends FinalPrintExpr {
    abstract string getExprString();
  }

  final class FinalBinaryOperation = BinaryOperation;

  class PrintBinaryExpr extends SupportedExpr, FinalBinaryOperation {
    override string getExprString() {
      result = print(getLeftOperand()) + " " + getOperator() + " " + print(getRightOperand())
    }
  }

  final class FinalLiteral = Literal;

  private class PrintLiteral extends SupportedExpr, FinalLiteral {
    override string getExprString() { result = getValue() }
  }
}
