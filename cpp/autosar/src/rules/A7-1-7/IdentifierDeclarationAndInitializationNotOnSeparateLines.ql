/**
 * @id cpp/autosar/identifier-declaration-and-initialization-not-on-separate-lines
 * @name A7-1-7: Each expression statement and identifier declaration shall be placed on a separate line
 * @description Declaring an identifier on a separate line makes the identifier declaration easier
 *              to find and the source code more readable.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-7
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class UniqueLineStmt extends Locatable {
  UniqueLineStmt() {
    not isAffectedByMacro() and
    exists(Declaration d |
      this = d.getADeclarationEntry() and
      not d instanceof Parameter and
      not d instanceof TemplateParameter and
      not d instanceof FunctionTemplateSpecialization and
      // TODO - Needs to be enhanced to solve issues with
      // templated inner classes.
      not d instanceof MemberFunction and
      not d.isFromTemplateInstantiation(_) and
      not d.(Function).isCompilerGenerated() and
      not d.(Variable).isCompilerGenerated() and
      not exists(RangeBasedForStmt f | f.getADeclaration() = d) and
      not exists(DeclStmt declStmt, ForStmt f |
        f.getInitialization() = declStmt and
        declStmt.getADeclaration() = d
      ) and
      not exists(LambdaCapture lc | lc.getField().getADeclarationEntry() = this)
    )
    or
    this instanceof ExprStmt and
    not exists(ForStmt f | f.getInitialization().getAChild*() = this) and
    not exists(LambdaExpression l | l.getLambdaFunction().getBlock().getAChild*() = this)
  }
}

from UniqueLineStmt e1, UniqueLineStmt e2
where
  not isExcluded(e1,
    DeclarationsPackage::identifierDeclarationAndInitializationNotOnSeparateLinesQuery()) and
  not isExcluded(e2,
    DeclarationsPackage::identifierDeclarationAndInitializationNotOnSeparateLinesQuery()) and
  not e1 = e2 and
  not e1.(DeclarationEntry) = e2 and
  exists(Location l1, Location l2 |
    e1.getLocation() = l1 and
    e2.getLocation() = l2 and
    not l1 = l2 and
    l1.getFile() = l2.getFile() and
    l1.getStartLine() = l2.getStartLine()
  )
select e1, "Expression statement and identifier are on the same line."
