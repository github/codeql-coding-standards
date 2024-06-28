/**
 * @id cpp/autosar/confusing-use-of-initializer-list-constructors
 * @name A8-5-4: Constructor may be confused with a constructor that accepts std::initializer_list
 * @description If a class has a user-declared constructor that takes a parameter of type
 *              std::initializer_list, then it shall be the only constructor apart from special
 *              member function constructors.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-5-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.initializerlistconstructoristheonlyconstructor_shared.InitializerListConstructorIsTheOnlyConstructor_shared

class ConfusingUseOfInitializerListConstructorsQuery extends InitializerListConstructorIsTheOnlyConstructor_sharedSharedQuery
{
  ConfusingUseOfInitializerListConstructorsQuery() {
    this = InitializationPackage::confusingUseOfInitializerListConstructorsQuery()
  }
}
