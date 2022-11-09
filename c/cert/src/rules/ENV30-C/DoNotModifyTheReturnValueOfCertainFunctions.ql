/**
 * @id c/cert/do-not-modify-the-return-value-of-certain-functions
 * @name ENV30-C: Do not modify the return value of certain functions
 * @description Modification of return values of getenv and similar functions results in undefined
 *              behaviour.
 * @kind path-problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/env30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.constlikereturnvalue.ConstLikeReturnValue

class DoNotModifyTheReturnValueOfCertainFunctionsQuery extends ConstLikeReturnValueSharedQuery {
  DoNotModifyTheReturnValueOfCertainFunctionsQuery() {
    this = Contracts1Package::doNotModifyTheReturnValueOfCertainFunctionsQuery()
  }
}
