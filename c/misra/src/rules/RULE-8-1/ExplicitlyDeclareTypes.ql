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
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.typeomitted.TypeOmitted

class ExplicitlyDeclareTypesQuery extends TypeOmittedSharedQuery {
  ExplicitlyDeclareTypesQuery() { this = Declarations3Package::explicitlyDeclareTypesQuery() }
}
