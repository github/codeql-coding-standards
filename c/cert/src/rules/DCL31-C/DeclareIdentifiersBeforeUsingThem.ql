/**
 * @id c/cert/declare-identifiers-before-using-them
 * @name DCL31-C: Declare identifiers before using them
 * @description Omission of type specifiers may not be supported by some compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl31-c
 *       correctness
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.typeomitted.TypeOmitted

class DeclareIdentifiersBeforeUsingThem extends TypeOmittedSharedQuery {
  DeclareIdentifiersBeforeUsingThem() {
    this = Declarations1Package::declareIdentifiersBeforeUsingThemQuery()
  }
}
