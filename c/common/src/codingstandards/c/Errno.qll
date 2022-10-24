/** Provides a library for errno-setting functions. */

import cpp
import semmle.code.cpp.dataflow.DataFlow

/**
 * An errno-setting function
 */
abstract class ErrnoSettingFunction extends Function { }

/**
 * An errno-setting function that return out-of-band errors indicators
 * as listed in the MISRA standard
 */
class OutOfBandErrnoSettingFunctionMisra extends ErrnoSettingFunction {
  OutOfBandErrnoSettingFunctionMisra() {
    this.hasGlobalName(["ftell", "fgetpos", "fsetpos", "mbrtowc", "wcrtomb", "wcsrtombs"])
  }
}

/**
 * An errno-setting function that return out-of-band errors indicators
 * as listed in the CERT standard
 */
class OutOfBandErrnoSettingFunctionCert extends Function {
  OutOfBandErrnoSettingFunctionCert() {
    this.hasGlobalName([
        "ftell", "fgetpos", "fsetpos", "mbrtowc", "mbsrtowcs", "signal", "wcrtomb", "wcsrtombs",
        "mbrtoc16", "mbrtoc32", "c16rtomb", "c32rtomb"
      ])
  }
}

/**
 * An errno-setting function that return in-band errors indicators
 */
class InBandErrnoSettingFunction extends ErrnoSettingFunction {
  InBandErrnoSettingFunction() {
    this.hasGlobalName([
        "fgetwc", "fputwc", "strtol", "wcstol", "strtoll", "wcstoll", "strtoul", "wcstoul",
        "strtoull", "wcstoull", "strtoumax", "wcstoumax", "strtod", "wcstod", "strtof", "wcstof",
        "strtold", "wcstold", "strtoimax", "wcstoimax"
      ])
  }
}

/**
 * A call to an `InBandErrnoSettingFunction`
 */
class InBandErrnoSettingFunctionCall extends FunctionCall {
  InBandErrnoSettingFunctionCall() { this.getTarget() instanceof InBandErrnoSettingFunction }
}

/**
 * An expression reading the value of `errno`
 */
class ErrnoRead extends Expr {
  ErrnoRead() {
    this = any(MacroInvocation ma | ma.getMacroName() = "errno").getAnExpandedElement()
    or
    this.(FunctionCall).getTarget().hasName(["perror", "strerror"])
  }
}

/**
 * A assignment expression setting `errno` to 0
 */
class ErrnoZeroed extends AssignExpr {
  ErrnoZeroed() {
    this.getLValue() = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr() and
    this.getRValue().getValue() = "0"
  }
}

/**
 * A guard controlled by a errno comparison
 */
abstract class ErrnoGuard extends StmtParent {
  abstract ControlFlowNode getZeroedSuccessor();

  abstract ControlFlowNode getNonZeroedSuccessor();
}

class ErrnoIfGuard extends ErrnoGuard {
  ControlStructure i;

  ErrnoIfGuard() {
    i.getControllingExpr() = this and
    this.(EqualityOperation).getAnOperand*() =
      any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr()
  }

  Stmt getThenSuccessor() {
    i.getControllingExpr() = this and
    (result = i.(IfStmt).getThen() or result = i.(Loop).getStmt())
  }

  Stmt getElseSuccessor() {
    i.getControllingExpr() = this and
    (
      i.(IfStmt).hasElse() and result = i.(IfStmt).getElse()
      or
      result = i.getFollowingStmt()
    )
  }

  override ControlFlowNode getZeroedSuccessor() {
    (
      if this instanceof EQExpr
      then result = this.getThenSuccessor()
      else result = getElseSuccessor()
    ) and
    (
      this.(EqualityOperation).getAnOperand().getValue() = "0"
      or
      this = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr()
    )
  }

  override ControlFlowNode getNonZeroedSuccessor() {
    (
      if this instanceof NEExpr
      then result = this.getThenSuccessor()
      else result = getElseSuccessor()
    ) and
    (
      this.(EqualityOperation).getAnOperand().getValue() = "0"
      or
      this = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr()
    )
  }
}

class ErrnoSwitchGuard extends SwitchCase, ErrnoGuard {
  ErrnoSwitchGuard() {
    this.getSwitchStmt().getExpr() = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr()
  }

  override ControlFlowNode getZeroedSuccessor() {
    result = this.getAStmt() and this.getExpr().getValue() = "0"
  }

  override ControlFlowNode getNonZeroedSuccessor() {
    result = this.getAStmt() and this.getExpr().getValue() != "0"
  }
}
