/**
 * @id cpp/autosar/integer-used-for-enum
 * @name A7-2-5: Enumerations should be used to represent sets of related named constants
 * @description Enumeration types should be used instead of integer types (and constants) to select
 *              from a limited series of choices.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-2-5
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

/*
 * This query flags switch statements where every non-default case dispatches on a named integer
 * constant.
 */

from SwitchStmt s
where
  not isExcluded(s, TypeRangesPackage::integerUsedForEnumQuery()) and
  forex(SwitchCase sc | sc = s.getASwitchCase() and not sc instanceof DefaultCase |
    // Accesses a constant variable by name
    // This is a strong indication that these variables are related constants
    exists(Variable v | v.getAnAccess() = sc.getExpr() |
      v.isConst()
      or
      v.isConstexpr()
    )
  ) and
  // Not already an enum switch
  not s instanceof EnumSwitch
select s,
  "Enumeration types should be used instead of integers to select from a limited series of choices."
