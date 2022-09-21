/** Provides a library for errno-setting functions. */

import cpp

/*
 * An errno-setting function
 */

abstract class ErrnoSettingFunction extends Function { }

/*
 * An errno-setting function that return out-of-band errors indicators
 */

class OutOfBandErrnoSettingFunction extends ErrnoSettingFunction {
  OutOfBandErrnoSettingFunction() {
    this.hasGlobalName([
        "ftell", "fgetpos", "fsetpos", "mbrtowc", "mbsrtowcs", "signal", "wcrtomb", "wcsrtombs",
        "mbrtoc16", "mbrtoc32", "c16rtomb", "c32rtomb"
      ])
  }
}

/*
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

/*
 * A assignment expression setting `errno` to 0
 */

class ErrnoZeroed extends AssignExpr {
  ErrnoZeroed() {
    this.getLValue() = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr() and
    this.getRValue().getValue() = "0"
  }
}

/*
 * A guard controlled by a errno comparison
 */

class ErrnoGuard extends EqualityOperation {
  ErrnoGuard() {
    this.getAnOperand() = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr() and
    this.getAnOperand().getValue() = "0" and
    exists(ControlStructure i | i.getControllingExpr() = this)
  }

  Stmt getThenSuccessor() {
    exists(ControlStructure i |
      i.getControllingExpr() = this and
      (result = i.(IfStmt).getThen() or result = i.(Loop).getStmt())
    )
  }

  Stmt getElseSuccessor() {
    exists(ControlStructure i |
      i.getControllingExpr() = this and
      (
        i.(IfStmt).hasElse() and result = i.(IfStmt).getElse()
        or
        result = i.getFollowingStmt()
      )
    )
  }

  ControlFlowNode getZeroedSuccessor() {
    if this instanceof EQExpr then result = this.getThenSuccessor() else result = getElseSuccessor()
  }

  ControlFlowNode getNonZeroedSuccessor() {
    if this instanceof EQExpr then result = this.getElseSuccessor() else result = getThenSuccessor()
  }
}
