/**
 * @id cpp/misra/data-member-not-initialized
 * @name RULE-15-1-4: All direct, non-static data members of a class should be initialized before the class object is
 * @description Classes should be fully initialized before they are used, to prevent undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-15-1-4
 *       scope/single-translation-unit
 *       correctness
 *       security
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Classes2Package::dataMemberNotInitializedQuery()) and
select
