/**
 * Provides a library with a `problems` predicate for the following issue:
 * A declaration should not declare more than one variable or member variable.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MultipleGlobalOrMemberDeclaratorsSharedQuery extends Query { }

Query getQuery() { result instanceof MultipleGlobalOrMemberDeclaratorsSharedQuery }

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
      s.isAnonymous() and
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

query predicate problems(NonLocalUserDeclaration d1, string message) {
  not isExcluded(d1, getQuery()) and
  isFollowingDeclaration(d1, _) and
  not isFollowingDeclaration(_, d1) and
  message = "Multiple declarations after " + d1.getName() + " in this declaration sequence."
}
