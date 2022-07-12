/**
 * @id cpp/autosar/multiple-global-or-member-declarators
 * @name M8-0-1: Multiple declarations in the same global or member declaration sequence
 * @description An init-declarator-list or a member-declarator-list shall consist of a single
 *              init-declarator or member-declarator respectively.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-0-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/*
 * Unfortunately, we do not have an equivalent of `DeclStmt` for non-local declarations, so we
 * cannot determine whether a declaration was declared with another declaration.
 *
 * However, we can use location trickery to figure out if the declaration occurs close enough to
 * another declaration that it _must_ have been declared within the same declaration sequence.
 *
 * We do this by requiring that the end location of a previous declaration is within a certain
 * number of characters of the start location of the current declaration.
 */

/**
 * A `Declaration` which is not in a local scope, and is written directly by the user.
 *
 * These act as "candidates" for declarations that could plausibly occur in a declaration sequence
 * with other candidates.
 */
class NonLocalUserDeclaration extends Declaration {
  NonLocalUserDeclaration() {
    not this instanceof StackVariable and
    not this instanceof TemplateParameter and
    not this instanceof EnumConstant and
    not this instanceof TypedefType and
    not any(LambdaCapture lc).getField() = this and
    not this.(Function).isCompilerGenerated() and
    not this.(Variable).isCompilerGenerated() and
    not this.(Parameter).getFunction().isCompilerGenerated() and
    not this.isInMacroExpansion() and
    not exists(Struct s, TypedefType t |
      s.getName() = "struct <unnamed>" and
      t.getBaseType() = s and
      this = s.getAMemberVariable()
    )
  }
}

/**
 * Holds if `d1` is followed directly by `d2`.
 */
predicate isFollowingDeclaration(NonLocalUserDeclaration d1, NonLocalUserDeclaration d2) {
  exists(string filepath, int startline, int startcolumn, int endline, int endcolumn |
    d1.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
    d2.getLocation().hasLocationInfo(filepath, startline, endcolumn + [2 .. 3], endline, _)
  ) and
  not d1.(UserType).stripType() = d2.(Variable).getType().stripType()
}

from NonLocalUserDeclaration d1
where
  not isExcluded(d1, InitializationPackage::multipleGlobalOrMemberDeclaratorsQuery()) and
  isFollowingDeclaration(d1, _) and
  not isFollowingDeclaration(_, d1)
select d1, "Multiple declarations after " + d1.getName() + " in this declaration sequence."
