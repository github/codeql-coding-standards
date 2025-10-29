/**
 * @id c/misra/function-types-not-in-prototype-form
 * @name RULE-8-2: Function types shall be in prototype form with named parameters
 * @description Omission of parameter types or names prevents the compiler from doing type checking
 *              when those functions are used and therefore may result in undefined behaviour.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-8-2
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.functiontypesnotinprototypeformshared.FunctionTypesNotInPrototypeFormShared

class FunctionTypesNotInPrototypeFormQuery extends FunctionTypesNotInPrototypeFormSharedSharedQuery {
  FunctionTypesNotInPrototypeFormQuery() {
    this = Declarations4Package::functionTypesNotInPrototypeFormQuery()
  }
}
