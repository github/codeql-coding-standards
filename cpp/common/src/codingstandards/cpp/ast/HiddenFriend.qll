/**
 * The C++ extractor does not support hidden friends, which are friend functions defined within a
 * class, rather than declared:
 *
 * ```cpp
 * struct A {
 *   friend void hidden_friend(A) {} // Definition: this is a hidden friend
 *   friend void not_hidden_friend(A); // Declaration: this is not a hidden friend
 * };
 * ```
 *
 * In the database, a `FriendDecl` is not created for the hidden friend. The hidden friend function
 * is created as a `TopLevel` function with no enclosing element. However, we can identify it as a
 * hidden friend by its location.
 */

import cpp
import codingstandards.cpp.ast.Class

/**
 * A class that, by our best logic, appears to possibly be a hidden friend.
 *
 * Hidden friends are not directly represented in the database. Instances of this class have been
 * found to have a location "within" the "body" of a class, and to satisfy other criteria that
 * indicates it may be a hidden friend.
 */
class PossibleHiddenFriend extends HiddenFriendCandidate {
  ClassCandidate cls;

  PossibleHiddenFriend() { hidesFriend(cls, this) }

  Class getFriendClass() { result = cls }
}

/**
 * Begin by limiting the number of candidate functions to consider.
 *
 * Only inline top level functions can be hidden friends.
 */
private class HiddenFriendCandidate extends TopLevelFunction {
  HiddenFriendCandidate() { this.isInline() }
}

/**
 * Only consider files which contain hidden friend candidates.
 */
private class FileCandidate extends File {
  FileCandidate() { exists(HiddenFriendCandidate c | c.getFile() = this) }
}

/**
 * Only consider classes in candidate files, that include hidden friend candidates.
 */
private class ClassCandidate extends Class {
  ClassCandidate() { getFile() instanceof FileCandidate }

  /**
   * Find the next declaration after this class that shares an enclosing element.
   *
   * This may be the next declaration after this class, or `getNextOrphanedDeclaration` may find the
   * true next declaration after this class. These are split for performance reasons.
   */
  Declaration getNextSiblingDeclaration() {
    result =
      min(Declaration decl |
        decl.getEnclosingElement() = this.getEnclosingElement() and
        pragma[only_bind_out](decl.getFile()) = pragma[only_bind_out](this.getFile()) and
        decl.getLocation().getStartLine() > getLastLineOfClassDeclaration(this)
      |
        decl order by decl.getLocation().getStartLine(), decl.getLocation().getStartColumn()
      )
  }

  /**
   * Get the next declaration after this class that does not have an enclosing element.
   *
   * This may be the next declaration after this class, or `getNextSiblingDeclaration` may find the
   * true next declaration after this class. These are split for performance reasons.
   *
   * Note that `OrphanedDeclaration` excludes hidden friend candidates, so this will find the next
   * orphan that is definitely not a hidden friend.
   */
  Declaration getNextOrphanedDeclaration() {
    result =
      min(OrphanedDeclaration decl, int startLine, int startColumn | // Location locDecl | // Location locLast, Location locDecl |
        orphanHasLocation(decl, this.getFile(), startLine, startColumn) and
        startLine > getLastLineOfClassDeclaration(this)
      |
        decl order by startLine, startColumn
      )
  }

  /**
   * Get the first declaration definitely after this class, and not a hidden friend declaration, to
   * determine the "end" location of this class.
   */
  Declaration getFirstNonClassDeclaration() {
    result =
      min(Declaration decl |
        decl = getNextSiblingDeclaration() or decl = getNextOrphanedDeclaration()
      |
        decl order by decl.getLocation().getStartLine(), decl.getLocation().getStartColumn()
      )
  }
}

/**
 * Helper predicate to improve join performance.
 */
pragma[nomagic]
private predicate orphanHasLocation(
  OrphanedDeclaration orphan, FileCandidate file, int endLine, int endColumn
) {
  orphan.getFile() = file and
  orphan.getLocation().getEndLine() = endLine and
  orphan.getLocation().getEndColumn() = endColumn
}

/**
 * Orphaned declarations to be found by `getNextOrphanedDeclaration`.
 *
 * These are declarations with no enclosing element. Note that we exclude hidden friend candidates,
 * as this class is used to find the declarations that are definitely not part of some class. This
 * is done so we can detect if hidden friends may be within that class definition. Therefore we must
 * exclude hidden friend candidates, even though those are also orphaned.
 */
private class OrphanedDeclaration extends Declaration {
  OrphanedDeclaration() {
    not exists(getEnclosingElement()) and
    not this instanceof HiddenFriendCandidate and
    getFile() instanceof FileCandidate and
    not isFromTemplateInstantiation(_)
  }
}

/**
 * Helper predicate to improve join performance.
 */
pragma[nomagic]
private predicate classCandidateHasFile(ClassCandidate c, FileCandidate f) { c.getFile() = f }

/**
 * Helper predicate to improve join performance.
 */
pragma[nomagic]
private predicate hiddenFriendCandidateHasFile(HiddenFriendCandidate h, FileCandidate f) {
  h.getFile() = f
}

/**
 * Find the class locations that have declarations that could be hidden friend declarations, by
 * comparing the locations of the candidate hidden friend functions to the location of the first
 * declaration that clearly is outside that class.
 */
pragma[nomagic]
private predicate hidesFriend(ClassCandidate c, HiddenFriendCandidate f) {
  exists(FileCandidate file, Location cloc, Location floc |
    classCandidateHasFile(c, file) and
    hiddenFriendCandidateHasFile(f, file) and
    cloc = c.getLocation() and
    floc = f.getLocation() and
    cloc.getEndLine() < floc.getStartLine() and
    floc.getEndLine() < c.getFirstNonClassDeclaration().getLocation().getStartLine()
  )
}
