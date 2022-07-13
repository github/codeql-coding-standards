/**
 * @id cpp/autosar/catch-all-ellipsis-used-in-non-main
 * @name A15-3-4: Catch-all (ellipsis and std::exception) handlers shall be used only in main-like or encapsulating functions
 * @description Catch-all (ellipsis and std::exception) handlers shall be used only in (a) main, (b)
 *              task main functions, (c) in functions that are supposed to isolate independent
 *              components and (d) when calling third-party code that uses exceptions not according
 *              to AUTOSAR C++14 guidelines.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-3-4
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.EncapsulatingFunctions

from CatchAnyBlock catchAll, Function f
where
  not isExcluded(catchAll, Exceptions1Package::catchAllEllipsisUsedInNonMainQuery()) and
  f = catchAll.getEnclosingFunction() and
  not f instanceof EncapsulatingFunction and
  not f instanceof MainLikeFunction
select catchAll,
  "Catch-all handler defined in $@ which is not a main function or encapsulating functions.", f,
  f.getName()
