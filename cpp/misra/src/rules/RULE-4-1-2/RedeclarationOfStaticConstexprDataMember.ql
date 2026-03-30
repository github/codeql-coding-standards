/**
 * @id cpp/misra/redeclaration-of-static-constexpr-data-member
 * @name RULE-4-1-2: Redeclaration of static constexpr data members is a deprecated language feature should not be used
 * @description Deprecated language features such as redeclaration of static constexpr data members
 *              are only supported for backwards compatibility; these are considered bad practice,
 *              or have been superseded by better alternatives.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from Variable v, Initializer i
where
  not isExcluded(v, Toolchain3Package::redeclarationOfStaticConstexprDataMemberQuery()) and
  v.isStatic() and
  i.getDeclaration() = v and
  v.isConstexpr() and
  (
    // The initializer location is in the class, and the varibale location is outside.
    // Detect if they're different files:
    not v.getLocation().getFile() = i.getLocation().getFile()
    or
    // Or if the variable is declared after the initializer:
    i.getLocation().getEndLine() < v.getLocation().getEndLine()
  )
select v,
  "Static constexpr data member '" + v.getName() +
    "' is redeclared, which is a deprecated language feature."
