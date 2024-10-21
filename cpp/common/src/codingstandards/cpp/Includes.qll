/** A library which supports analysis of includes. */

import cpp
import semmle.code.cpp.headers.MultipleInclusion

/**
 * Holds if `include` is included conditionally based on the branch directive `b1`.
 */
predicate conditionallyIncluded(PreprocessorBranchDirective b1, Include include) {
  exists(File f, int include1StartLine |
    not b1 = any(CorrectIncludeGuard c).getIfndef() and
    not b1.getHead().regexpMatch(".*_H(_.*)?") and
    include.getLocation().hasLocationInfo(f.getAbsolutePath(), include1StartLine, _, _, _) and
    f.getAbsolutePath() = b1.getFile().getAbsolutePath()
  |
    b1.getLocation().getStartLine() < include1StartLine and
    b1.getNext().getLocation().getStartLine() > include1StartLine
  )
}

/**
 * Gets a file which is directly included from `fromFile` unconditionally.
 */
File getAnUnconditionallyIncludedFile(File fromFile) {
  // Find an include which isn't conditional
  exists(Include i |
    i.getFile() = fromFile and
    not conditionallyIncluded(_, i) and
    result = i.getIncludedFile()
  )
}
