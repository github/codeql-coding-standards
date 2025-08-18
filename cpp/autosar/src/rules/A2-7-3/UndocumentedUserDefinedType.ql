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

private predicate isInFunctionScope(Declaration d) {
  // Type declared in function
  exists(d.(UserType).getEnclosingFunction())
  or
  // Member declared in type which is in function scope
  isInFunctionScope(d.getDeclaringType())
}

private string doxygenCommentGroupStrings(boolean opening) {
  opening = true and result = ["///@{", "/**@{*/"]
  or
  opening = false and result = ["///@}%", "/**@}*/"]
}

pragma[inline]
private predicate isBetweenDoxygenCommentGroup(
  Location loc, Comment opening, Comment body, Comment closing
) {
  // All in the same file
  loc.getFile() = opening.getLocation().getFile() and
  loc.getFile() = closing.getLocation().getFile() and
  loc.getFile() = body.getLocation().getFile() and
  // The comments are doxygen comments
  opening.getContents().matches(doxygenCommentGroupStrings(true)) and
  closing.getContents().matches(doxygenCommentGroupStrings(false)) and
  // The closing comment is after the opening comment
  opening.getLocation().getStartLine() < closing.getLocation().getStartLine() and
  // The `body` comment directly precedes the opening comment
  body.getLocation().getEndLine() = opening.getLocation().getStartLine() - 1 and
  // There are no other opening/closing comment pairs between the opening and closing comments
  not exists(Comment c |
    c.getContents().matches(doxygenCommentGroupStrings(_)) and
    c.getLocation().getStartLine() > opening.getLocation().getStartLine() and
    c.getLocation().getStartLine() < closing.getLocation().getStartLine()
  ) and
  // `loc` is between the opening and closing comments and after the body comment
  loc.getStartLine() > opening.getLocation().getStartLine() and
  loc.getStartLine() < closing.getLocation().getStartLine() and
  loc.getStartLine() > body.getLocation().getEndLine()
}

/**
 * A declaration which is required to be preceded by documentation by AUTOSAR A2-7-3.
 */
class DocumentableDeclaration extends Declaration {
  string declarationType;

  DocumentableDeclaration() {
    // Within the users codebase, not a system header
    exists(this.getFile().getRelativePath()) and
    // Not required to be documented, as used within same scope
    not isInFunctionScope(this) and
    (
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
      not exists(LambdaExpression lc | lc.getLambdaFunction() = this) and
      //Exclude friend functions (because they have 2 entries in the database), and only one shows documented truly
      not exists(FriendDecl d |
        d.getFriend().(Function).getDefinition() = this.getADeclarationEntry()
      )
      or
      this instanceof MemberVariable and
      declarationType = "member variable" and
      // Exclude memeber variables in instantiated templates, which cannot reasonably be documented.
      not this.(MemberVariable).isFromTemplateInstantiation(_) and
      // Exclude compiler generated variables, such as those for anonymous lambda functions
      not this.(MemberVariable).isCompilerGenerated()
    )
  }

  private predicate hasDocumentedDefinition() {
    // Check if the declaration has a documented definition
    exists(DeclarationEntry de | de = getADeclarationEntry() and isDocumented(de))
  }

  private predicate hasOnlyDefinitions() {
    // Check if the declaration has only definitions, i.e., no non-definition entries
    not exists(DeclarationEntry de | de = getADeclarationEntry() and not de.isDefinition())
  }

  /** Gets a `DeclarationEntry` for this declaration that should be documented. */
  DeclarationEntry getAnUndocumentedDeclarationEntry() {
    // Find a declaration entry that is not documented
    result = getADeclarationEntry() and
    not isDocumented(result) and
    if result.isDefinition()
    then
      // Report the definition DeclarationEntry, only if there are no non-definition `DeclarationEntry`'s
      // The rationale here is that documenting both the non-definition and definition declaration entries
      // is redundant
      hasOnlyDefinitions()
    else
      // Report any non definition DeclarationEntry that is not documented
      // as long as there is no corresponding documented definition (which must be for a forward declaration)
      not hasDocumentedDefinition()
  }

  /** Gets a string describing the type of declaration. */
  string getDeclarationType() { result = declarationType }
}

/**
 * A `DeclarationEntry` is considered documented if it has an associated `Comment`, the `Comment`
 * precedes the `DeclarationEntry`, and the `Comment` is not a doxygen comment group prefix.
 */
cached
predicate isDocumented(DeclarationEntry de) {
  exists(Comment c | c.getCommentedElement() = de |
    not c.getContents() = doxygenCommentGroupStrings(true) and
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
  or
  // The declaration entry is between a doxygen comment group
  isBetweenDoxygenCommentGroup(de.getLocation(), _, _, _)
}

from DocumentableDeclaration d, DeclarationEntry de
where
  not isExcluded(de, CommentsPackage::undocumentedUserDefinedTypeQuery()) and
  not isExcluded(d, CommentsPackage::undocumentedUserDefinedTypeQuery()) and
  d.getAnUndocumentedDeclarationEntry() = de
select de,
  "Declaration entry for " + d.getDeclarationType() + " " + d.getName() +
    " is missing documentation."
