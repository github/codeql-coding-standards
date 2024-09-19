/**
 * @id cpp/misra/initializer-list-constructor-is-the-only-constructor
 * @name RULE-15-1-5: A class shall only define an initializer-list constructor when it is the only constructor
 * @description A class shall only define an initializer-list constructor when it is the only
 *              constructor.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-1-5
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.initializerlistconstructoristheonlyconstructor.InitializerListConstructorIsTheOnlyConstructor

class InitializerListConstructorIsTheOnlyConstructorQuery extends InitializerListConstructorIsTheOnlyConstructorSharedQuery
{
  InitializerListConstructorIsTheOnlyConstructorQuery() {
    this = ImportMisra23Package::initializerListConstructorIsTheOnlyConstructorQuery()
  }
}
