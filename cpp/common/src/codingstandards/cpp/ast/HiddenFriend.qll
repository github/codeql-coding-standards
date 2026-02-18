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

  Declaration getNextSiblingDeclaration() {
    exists(LastClassDeclaration last |
      last.getDeclaringType() = this and
      result =
        min(Declaration decl |
          decl.getEnclosingElement() = this.getEnclosingElement() and
          pragma[only_bind_out](decl.getFile()) = pragma[only_bind_out](this.getFile()) and
          decl.getLocation().getStartLine() > last.getLocation().getEndLine()
        |
          decl order by decl.getLocation().getStartLine(), decl.getLocation().getStartColumn()
        )
    )
  }

  Declaration getNextOrphanedDeclaration() {
    exists(LastClassDeclaration last |
      last.getDeclaringType() = this and
      result =
        min(OrphanedDeclaration decl, Location locLast, Location locDecl |
          orphanHasFile(decl, this.getFile()) and
          locDecl = decl.getLocation() and
          locLast = last.getLocation() and
          locLast.getStartLine() < locDecl.getEndLine()
        |
          decl order by locDecl.getStartLine(), locDecl.getStartColumn()
        )
    )
  }

  Declaration getFirstNonClassDeclaration() {
    exists(LastClassDeclaration last |
      last.getDeclaringType() = this and
      result =
        min(Declaration decl |
          decl = getNextSiblingDeclaration() or decl = getNextOrphanedDeclaration()
        |
          decl order by decl.getLocation().getStartLine(), decl.getLocation().getStartColumn()
        )
    )
  }
}

pragma[nomagic]
private predicate orphanHasFile(OrphanedDeclaration orphan, FileCandidate file) {
  orphan.getFile() = file
}

private class OrphanedDeclaration extends Declaration {
  OrphanedDeclaration() {
    not exists(getEnclosingElement()) and
    not this instanceof HiddenFriendCandidate and
    getFile() instanceof FileCandidate and
    not isFromTemplateInstantiation(_)
  }
}

pragma[nomagic]
private predicate classCandidateHasFile(ClassCandidate c, FileCandidate f) { c.getFile() = f }

pragma[nomagic]
private predicate hiddenFriendCandidateHasFile(HiddenFriendCandidate h, FileCandidate f) {
  h.getFile() = f
}

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
