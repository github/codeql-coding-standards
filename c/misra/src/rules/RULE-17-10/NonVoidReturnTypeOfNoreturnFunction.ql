/**
 * @id c/misra/non-void-return-type-of-noreturn-function
 * @name RULE-17-10: A function declared with _noreturn shall have a return type of void
 * @description Function declared with _noreturn will by definition not return a value, and should
 *              be declared to return void.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-17-10
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Noreturn

from NoreturnFunction f, Type returnType
where
  not isExcluded(f, NoReturnPackage::nonVoidReturnTypeOfNoreturnFunctionQuery()) and
  returnType = f.getType() and
  not returnType instanceof VoidType and
  not f.isCompilerGenerated()
select f,
  "The function " + f.getName() + " is declared _noreturn but has a return type of " +
    returnType.toString() + "."
