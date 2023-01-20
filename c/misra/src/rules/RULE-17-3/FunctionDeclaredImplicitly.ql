/**
 * @id c/misra/function-declared-implicitly
 * @name RULE-17-3: A function shall not be declared implicitly
 * @description Omission of type specifiers may not be supported by some compilers. Additionally
 *              implicit typing can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-3
 *       correctness
 *       readability
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from FunctionDeclarationEntry fde
where
  not isExcluded(fde, Declarations6Package::functionDeclaredImplicitlyQuery()) and
  (
    //use before declaration
    fde.isImplicit()
    or
    //declared but type not explicit
    isDeclaredImplicit(fde.getDeclaration())
  )
select fde, "Function declaration is implicit."
