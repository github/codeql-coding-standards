/** A library which supports analysis of includes. */

import cpp
import codingstandards.cpp.PreprocessorDirective
import semmle.code.cpp.headers.MultipleInclusion

pragma[noinline]
private predicate hasIncludeLocation(Include include, string filepath, int startline) {
  include.getLocation().hasLocationInfo(filepath, startline, _, _, _)
}

/**
 * Holds if `include` is included conditionally based on the branch directive `b1`.
 */
pragma[noinline]
predicate isConditionallyIncluded(PreprocessorBranchDirective bd, Include include) {
  not bd = any(CorrectIncludeGuard c).getIfndef() and
  not bd.getHead().regexpMatch(".*_H(_.*)?") and
  exists(string filepath, int startline, int endline, int includeline |
    isBranchDirectiveRange(bd, filepath, startline, endline) and
    hasIncludeLocation(include, filepath, includeline) and
    startline < includeline and
    endline > includeline
  )
}

/**
 * Gets a file which is directly included from `fromFile` unconditionally.
 */
File getAnUnconditionallyIncludedFile(File fromFile) {
  // Find an include which isn't conditional
  exists(Include i |
    i.getFile() = fromFile and
    not isConditionallyIncluded(_, i) and
    result = i.getIncludedFile()
  )
}
