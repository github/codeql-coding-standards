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
    (
      exists(Declaration d |
        this = d.getADeclarationEntry() and
        not d instanceof Parameter and
        not d instanceof TypeTemplateParameter and
        // TODO - Needs to be enhanced to solve issues with
        // templated inner classes.
        not d instanceof Function and
        not d.isFromTemplateInstantiation(_) and
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
    )
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
  //omit the cases where there is one struct identifier on a struct var line used with typedef
  not exists(Struct s | s.getADeclarationEntry() = e1 and e1 instanceof TypeDeclarationEntry) and
  not exists(Struct s | s.getATypeNameUse() = e1 and e1 instanceof TypeDeclarationEntry) and
  exists(string file, int startline |
    e1.getLocation().hasLocationInfo(file, startline, _, _, _) and
    e2.getLocation().hasLocationInfo(file, startline, _, _, _) and
    not e1.getLocation() = e2.getLocation()
  )
select e1, "Expression statement and identifier are on the same line."
