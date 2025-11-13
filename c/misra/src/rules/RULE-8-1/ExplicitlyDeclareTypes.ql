/**
 * @id c/misra/explicitly-declare-types
 * @name RULE-8-1: Declare identifiers before using them
 * @description Omission of type specifiers may not be supported by some compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-1
 *       correctness
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.typeomitted.TypeOmitted

class ExplicitlyDeclareTypesQuery extends TypeOmittedSharedQuery {
  ExplicitlyDeclareTypesQuery() { this = Declarations3Package::explicitlyDeclareTypesQuery() }
}
