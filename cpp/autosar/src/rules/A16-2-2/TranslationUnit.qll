import semmle.code.cpp.File
import semmle.code.cpp.commons.Dependency

/**
 * Holds if `file` is the `index`th file transitively included by `tu`.
 * Indexes start at 1, and follow a preorder traversal of the
 * include tree.
 */
private predicate include(TranslationUnit tu, int index, File file) {
  exists(string i, string f |
    fileannotations(unresolveElement(tu), 98, f, i) and
    index = i.toInt() and
    file.getAbsolutePath() = f
  )
}

/**
 * A file which was the primary file in a translation unit.
 *
 * In most normal build processes, this corresponds to files whose
 * filename appeared in the command line of a compiler invocation.
 */
class TranslationUnit extends File {
  TranslationUnit() { this.compiledAsC() or this.compiledAsCpp() }

  /**
   * Gets the `index`th file which was part of this translation unit.
   *
   * A translation unit has a corresponding include tree, which is
   * linearized into a zero-based list of files by a preorder traversal.
   *
   * Note that unlike Include::provides(File), this predicate yields the
   * actual compile-time linearization rather than an approximation to
   * it.
   */
  File getFileInTranslationUnit(int index) {
    include(this, index, result)
    or
    index = 0 and result = this
  }

  /*
   * Gets a file which was part of this translation unit.
   * Equivalent to `getFileInTranslationUnit(_)`, but more efficient.
   */

  File getAFileInTranslationUnit() {
    fileannotations(underlyingElement(this), 98, result.getAbsolutePath(), _) or
    result = this
  }

  /*
   * DEPRECATED: use `getAnyFileInTranslationUnit` instead.
   * Gets a file which was part of this translation unit.
   * Equivalent to `getFileInTranslationUnit(_)`, but more efficient.
   */

  deprecated File getAnyFile() { result = this.getAFileInTranslationUnit() }
}
