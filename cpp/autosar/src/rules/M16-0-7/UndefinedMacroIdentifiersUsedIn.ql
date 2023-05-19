/**
 * @id cpp/autosar/undefined-macro-identifiers-used-in
 * @name M16-0-7: Undefined macro identifiers shall not be used in #if or #elif pre-processor directives, except as operands to the defined operator
 * @description Using undefined macro identifiers in #if or #elif pre-processor directives, except
 *              as operands to the defined operator, can cause the code to be hard to understand
 *              because the preprocessor will just treat the value as 0 and no warning is given.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-7
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.undefinedmacroidentifiers.UndefinedMacroIdentifiers

class UndefinedMacroIdentifiersUsedInQuery extends UndefinedMacroIdentifiersSharedQuery {
  UndefinedMacroIdentifiersUsedInQuery() {
    this = MacrosPackage::charactersOccurInHeaderFileNameOrInIncludeDirectiveQuery()
  }
}
