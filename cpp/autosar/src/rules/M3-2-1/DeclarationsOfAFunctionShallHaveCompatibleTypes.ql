/**
 * @id cpp/autosar/declarations-of-a-function-shall-have-compatible-types
 * @name M3-2-1: All declarations of a function shall have compatible types
 * @description It is undefined behavior if the declarations of an object or function in two
 *              different translation units do not have compatible types. The easiest way of
 *              ensuring object or function types are compatible is to make the declarations
 *              identical.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m3-2-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Typehelpers

from FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
where
  not isExcluded(f1) and
  not isExcluded(f2, DeclarationsPackage::declarationsOfAFunctionShallHaveCompatibleTypesQuery()) and
  not f1 = f2 and
  f1.getDeclaration() = f2.getDeclaration() and
  not areCompatible(f1.getType(), f2.getType())
select f1, "The return type of the re-declaration of $@ is not compatible with declaration $@", f1,
  f1.getName(), f2, f2.getName()
