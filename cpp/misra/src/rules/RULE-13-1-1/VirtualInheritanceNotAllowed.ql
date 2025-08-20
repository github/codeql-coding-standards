/**
 * @id cpp/misra/virtual-inheritance-not-allowed
 * @name RULE-13-1-1: Classes should not be inherited virtually
 * @description Virtual inheritance should not be used as it may lead to unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-13-1-1
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from VirtualClassDerivation vcd
where not isExcluded(vcd, Classes2Package::virtualInheritanceNotAllowedQuery())
select vcd,
  "Class '" + vcd.getDerivedClass().getName() + "' inherits virtually from '" +
    vcd.getBaseClass().getName() + "'."
