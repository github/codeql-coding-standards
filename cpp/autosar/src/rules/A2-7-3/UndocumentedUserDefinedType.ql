/**
 * @id cpp/autosar/undocumented-user-defined-type
 * @name A2-7-3: Declarations of 'user-defined' types, member variables and functions should be documented
 * @description All declarations of 'user-defined' types, static and non-static data members,
 *              functions and methods shall be preceded by documentation.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a2-7-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * A declaration which is required to be preceded by documentation by AUTOSAR A2-7-3.
 */
class DocumentableDeclaration extends Declaration {
  string declarationType;

  DocumentableDeclaration() {
    this instanceof UserType and
    declarationType = "user-defined type" and
    // Exclude template parameter types.
    not this.(UserType).involvesTemplateParameter()
    or
    this instanceof Function and
    declarationType = "function" and
    // Exclude compiler generated functions, which cannot reasonably be documented.
    not this.(Function).isCompilerGenerated() and
    // Exclude instantiated template functions, which cannot reasonably be documented.
    not this.(Function).isFromTemplateInstantiation(_) and
    // Exclude anonymous lambda functions.
    not exists(LambdaExpression lc | lc.getLambdaFunction() = this)
    or
    this instanceof MemberVariable and
    declarationType = "member variable" and
    // Exclude memeber variables in instantiated templates, which cannot reasonably be documented.
    not this.(MemberVariable).isFromTemplateInstantiation(_) and
    // Exclude anonymous lambda functions.
    // TODO: replace with the following when support is added.
    // not this.(MemberVariable).isCompilerGenerated()
    not exists(LambdaExpression lc | lc.getACapture().getField() = this)
  }

  /** Gets a `DeclarationEntry` for this declaration that should be documented. */
  DeclarationEntry getAnUndocumentedDeclarationEntry() {
    // Find a declaration entry that is not documented
    result = getADeclarationEntry() and
    not isDocumented(result) and
    (
      // Report any non definition DeclarationEntry that is not documented
      // as long as there is no corresponding documented definition (which must be for a forward declaration)
      not result.isDefinition() and
      not exists(DeclarationEntry de |
        de = getADeclarationEntry() and de.isDefinition() and isDocumented(de)
      )
      or
      // Report the definition DeclarationEntry, only if there are no non-definition `DeclarationEntry`'s
      // The rationale here is that documenting both the non-definition and definition declaration entries
      // is redundant
      result.isDefinition() and
      not exists(DeclarationEntry de | de = getADeclarationEntry() and not de.isDefinition())
    )
  }

  /** Gets a string describing the type of declaration. */
  string getDeclarationType() { result = declarationType }
}

/**
 * A `DeclarationEntry` is considered documented if it has an associated `Comment`, and the `Comment`
 * precedes the `DeclarationEntry`.
 */
predicate isDocumented(DeclarationEntry de) {
  exists(Comment c | c.getCommentedElement() = de |
    exists(Location commentLoc, Location deLoc |
      commentLoc = c.getLocation() and deLoc = de.getLocation()
    |
      // The comment precedes the declaration entry if it occurs on the previous line
      commentLoc.getStartLine() < deLoc.getStartLine()
      or
      // ...or if it occurs on the same line as the declaration entry, but with an earlier column
      commentLoc.getStartLine() = deLoc.getStartLine() and
      commentLoc.getStartColumn() < deLoc.getStartColumn()
    )
  )
}

from DocumentableDeclaration d, DeclarationEntry de
where
  not isExcluded(de, CommentsPackage::undocumentedUserDefinedTypeQuery()) and
  not isExcluded(d, CommentsPackage::undocumentedUserDefinedTypeQuery()) and
  d.getAnUndocumentedDeclarationEntry() = de
select de,
  "Declaration entry for " + d.getDeclarationType() + " " + d.getName() +
    " is missing documentation."
