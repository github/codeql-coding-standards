/**
 * @id c/misra/function-types-not-in-prototype-form-obsolete
 * @name RULE-1-5: Function types shall be in prototype form with named parameters
 * @description The use of non-prototype format parameter type declarators is an obsolescent
 *              language feature.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-1-5
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.functiontypesnotinprototypeformshared.FunctionTypesNotInPrototypeFormShared

class FunctionTypesNotInPrototypeFormObsoleteQuery extends FunctionTypesNotInPrototypeFormSharedSharedQuery {
  FunctionTypesNotInPrototypeFormObsoleteQuery() {
    this = Language4Package::functionTypesNotInPrototypeFormObsoleteQuery()
  }
}
