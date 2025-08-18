/**
 * @id cpp/misra/use-smart-ptr-factory-functions
 * @name RULE-23-11-1: The raw pointer constructors of std::shared_ptr and std::unique_ptr should not be used
 * @description Using raw pointer constructors of std::shared_ptr and std::unique_ptr instead of
 *              make_shared/make_unique can lead to memory leaks if exceptions occur during
 *              construction.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-23-11-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from ConstructorCall call, Class smartPtrClass
where
  not isExcluded(call, BannedAPIsPackage::useSmartPtrFactoryFunctionsQuery()) and
  smartPtrClass = call.getTarget().getDeclaringType() and
  (
    smartPtrClass.hasQualifiedName("std", "shared_ptr") or
    smartPtrClass.hasQualifiedName("std", "unique_ptr")
  ) and
  // The rule only applies to constructors that take a raw pointer as the first argument
  // This includes the (*p, deleter) and (*p, deleter, alloc) constructors
  // and excludes e.g. the move or aliasing constructors.
  call.getArgument(0).getType().getUnspecifiedType() instanceof PointerType
select call, "Use of raw pointer constructor for 'std::" + smartPtrClass.getSimpleName() + "'."
