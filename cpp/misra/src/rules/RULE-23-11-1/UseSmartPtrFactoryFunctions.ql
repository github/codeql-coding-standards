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
  call.getNumberOfArguments() >= 1 and
  exists(Type argType |
    argType = call.getArgument(0).getType().getUnspecifiedType() and
    argType instanceof PointerType
  )
select call, "Use of raw pointer constructor for 'std::" + smartPtrClass.getSimpleName() + "'."
