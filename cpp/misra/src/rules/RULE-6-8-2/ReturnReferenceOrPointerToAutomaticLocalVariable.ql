/**
 * @id cpp/misra/return-reference-or-pointer-to-automatic-local-variable
 * @name RULE-6-8-2: A function must not return a reference or a pointer to a local variable with automatic storage
 * @description A function must not return a reference or a pointer to a local variable with
 *              automatic storage duration.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-8-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.returnreferenceorpointertoautomaticlocalvariable_shared.ReturnReferenceOrPointerToAutomaticLocalVariable_shared

class ReturnReferenceOrPointerToAutomaticLocalVariableQuery extends ReturnReferenceOrPointerToAutomaticLocalVariable_sharedSharedQuery
{
  ReturnReferenceOrPointerToAutomaticLocalVariableQuery() {
    this = ImportMisra23Package::returnReferenceOrPointerToAutomaticLocalVariableQuery()
  }
}
