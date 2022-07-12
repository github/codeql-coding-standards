/**
 * @id cpp/autosar/declaration-contain-less-than-two-levels-of-indirection
 * @name A5-0-3: The declaration of objects shall contain no more than two levels of pointer indirection
 * @description The declaration of objects shall contain no more than two levels of pointer
 *              indirection, because the use or more than two levels can impair the ability to
 *              understand the behavior of the code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-0-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

Type getBaseType(DerivedType t) { result = t.getBaseType() }

int levelsOfIndirection(Type t) {
  if t instanceof FunctionPointerType
  then result = t.(FunctionPointerType).getReturnType().getPointerIndirectionLevel()
  else result = t.getPointerIndirectionLevel()
}

int paramLevelsOfIndirection(Type t) {
  if t instanceof ArrayType
  then result = 1 + levelsOfIndirection(t.(ArrayType).getBaseType())
  else result = levelsOfIndirection(t)
}

from Variable v, Type type
where
  not isExcluded(v, PointersPackage::declarationContainLessThanTwoLevelsOfIndirectionQuery()) and
  type = getBaseType*(v.getType()) and
  (
    if v instanceof Parameter
    then paramLevelsOfIndirection(type) > 2
    else levelsOfIndirection(type) > 2
  )
select v,
  "The declaration of " + v.getName() + " contain more than two levels of pointer indirection."
