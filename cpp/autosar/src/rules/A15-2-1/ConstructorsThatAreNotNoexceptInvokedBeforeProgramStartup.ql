/**
 * @id cpp/autosar/constructors-that-are-not-noexcept-invoked-before-program-startup
 * @name A15-2-1: Constructors that are not noexcept shall not be invoked before program startup
 * @description Exceptions thrown before startup cannot be caught and therefore are subject to
 *              abruptly terminating the program, leaving resources in an indeterminate state.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionSpecifications

from GlobalOrNamespaceVariable gv, ConstructorCall constructorCall, Constructor constructor
where
  not isExcluded(gv,
    Exceptions1Package::constructorsThatAreNotNoexceptInvokedBeforeProgramStartupQuery()) and
  gv.getInitializer().getExpr().getAChild*() = constructorCall and
  constructor = constructorCall.getTarget() and
  not isNoExceptTrue(constructor)
select constructorCall,
  "Initializer for variable $@ invokes constructor $@ which is not marked as noexcept(true) or equivalent.",
  gv, gv.getName(), constructor, constructor.getName()
