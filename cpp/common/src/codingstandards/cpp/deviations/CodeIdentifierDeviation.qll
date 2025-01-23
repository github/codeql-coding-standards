/**
 * A module for identifying comment markers in code that trigger deviations.
 *
 * Each comment marker consists of a `code-identifier` with some optional annotations. A deviation will be applied to
 * some range of lines in the file containing the comment based on the annotation. The supported marker annotation
 * formats are:
 *  - `<code-identifier>` - the deviation applies to results on the current line.
 *  - `[[codingstandards::deviation(<code-identifier>)]]` - same as above.
 *  - `[[codingstandards::deviation_next_line(<code-identifier>)]]` - this deviation applies to results on the next line.
 *  - `[[codingstandards::deviation_begin(<code-identifier>)]]` - marks the beginning of a range of lines where the deviation applies.
 *  - `[[codingstandards::deviation_end(<code-identifier>)]]` - marks the end of a range of lines where the deviation applies.
 *
 * The valid `code-identifier`s are specified in deviation records, which also specify the query whose results are
 * suppressed by the deviation.
 *
 * For begin/end, we maintain a stack of begin markers. When we encounter an end marker, we pop the stack to determine
 * the range of that begin/end marker. If the stack is empty, the end marker is considered unmatched and invalid. If
 * the stack is non-empty at the end of the file, all the begin markers are considered unmatched and invalid.
 *
 * Begin/end markers are not valid across include boundaries, as the stack is not maintained across files.
 */

import cpp
import Deviations

/**
 * Holds if the given comment contains the code identifier.
 */
bindingset[codeIdentifier]
private predicate commentMatches(Comment comment, string codeIdentifier) {
  exists(string text |
    comment instanceof CppStyleComment and
    // strip the beginning slashes
    text = comment.getContents().suffix(2).trim()
    or
    comment instanceof CStyleComment and
    // strip both the beginning /* and the end */ the comment
    exists(string text0 |
      text0 = comment.getContents().suffix(2) and
      text = text0.prefix(text0.length() - 2).trim()
    ) and
    // The /* */ comment must be a single-line comment
    not text.matches("%\n%")
  |
    // Code identifier appears at the start of the comment (modulo whitespace)
    text.prefix(codeIdentifier.length()) = codeIdentifier
    or
    // Code identifier appears at the end of the comment (modulo whitespace)
    text.suffix(text.length() - codeIdentifier.length()) = codeIdentifier
  )
}

/**
 * A deviation marker in the code.
 */
abstract class CommentDeviationMarker extends Comment {
  DeviationRecord record;

  /**
   * Gets the deviation record associated with this deviation marker.
   */
  DeviationRecord getRecord() { result = record }
}

/**
 * A deviation marker for a deviation that applies to the current line.
 */
class DeviationEndOfLineMarker extends CommentDeviationMarker {
  DeviationEndOfLineMarker() {
    commentMatches(this, "[[codingstandards::deviation(" + record.getCodeIdentifier() + ")]]")
  }
}

/**
 * A deviation marker for a deviation that applies to the next line.
 */
class DeviationNextLineMarker extends CommentDeviationMarker {
  DeviationNextLineMarker() {
    commentMatches(this,
      "[[codingstandards::deviation_next_line(" + record.getCodeIdentifier() + ")]]")
  }
}

/**
 * A deviation marker for a deviation that applies to a range of lines
 */
abstract class CommentDeviationRangeMarker extends CommentDeviationMarker { }

/**
 * A deviation marker for a deviation that begins on this line.
 */
class DeviationBegin extends CommentDeviationRangeMarker {
  DeviationBegin() {
    commentMatches(this, "[[codingstandards::deviation_begin(" + record.getCodeIdentifier() + ")]]")
  }
}

/**
 * A deviation marker for a deviation that ends on this line.
 */
class DeviationEnd extends CommentDeviationRangeMarker {
  DeviationEnd() {
    commentMatches(this, "[[codingstandards::deviation_end(" + record.getCodeIdentifier() + ")]]")
  }
}

private predicate hasDeviationCommentFileOrdering(
  DeviationRecord record, CommentDeviationRangeMarker comment, File file, int index
) {
  comment =
    rank[index](CommentDeviationRangeMarker c |
      c.getRecord() = record and
      file = c.getFile()
    |
      c order by c.getLocation().getStartLine(), c.getLocation().getStartColumn()
    )
}

private predicate mkBeginStack(DeviationRecord record, File file, BeginStack stack, int index) {
  // Stack is empty at the start
  index = 0 and
  stack = TEmptyBeginStack() and
  exists(CommentDeviationRangeMarker marker |
    marker.getRecord() = record and marker.getLocation().getFile() = file
  )
  or
  // Next token is begin, so push it to the stack
  exists(DeviationBegin begin, BeginStack prev |
    record = begin.getRecord() and
    hasDeviationCommentFileOrdering(record, begin, file, index) and
    mkBeginStack(record, file, prev, index - 1) and
    stack = TConsBeginStack(begin, prev)
  )
  or
  // Next token is end
  exists(DeviationEnd end, BeginStack prevStack |
    record = end.getRecord() and
    hasDeviationCommentFileOrdering(record, end, file, index) and
    mkBeginStack(record, file, prevStack, index - 1)
  |
    // There is, so pop the most recent begin off the stack
    prevStack = TConsBeginStack(_, stack)
    or
    // Error, no begin on the stack, ignore and continue
    prevStack = TEmptyBeginStack() and
    stack = TEmptyBeginStack()
  )
}

newtype TBeginStack =
  TConsBeginStack(DeviationBegin begin, TBeginStack prev) {
    exists(File file, int index |
      hasDeviationCommentFileOrdering(begin.getRecord(), begin, file, index) and
      mkBeginStack(begin.getRecord(), file, prev, index - 1)
    )
  } or
  TEmptyBeginStack()

private class BeginStack extends TBeginStack {
  string toString() {
    exists(DeviationBegin begin, BeginStack prev | this = TConsBeginStack(begin, prev) |
      result = "(" + begin + ", " + prev.toString() + ")"
    )
    or
    this = TEmptyBeginStack() and
    result = "()"
  }
}

private predicate isDeviationRangePaired(
  DeviationRecord record, DeviationBegin begin, DeviationEnd end
) {
  exists(File file, int index |
    record = end.getRecord() and
    hasDeviationCommentFileOrdering(record, end, file, index) and
    mkBeginStack(record, file, TConsBeginStack(begin, _), index - 1)
  )
}

newtype TCodeIndentifierDeviation =
  TSingleLineDeviation(DeviationRecord record, Comment comment, string filepath, int suppressedLine) {
    (
      commentMatches(comment, record.getCodeIdentifier()) or
      comment.(DeviationEndOfLineMarker).getRecord() = record
    ) and
    comment.getLocation().hasLocationInfo(filepath, suppressedLine, _, _, _)
    or
    comment.(DeviationNextLineMarker).getRecord() = record and
    comment.getLocation().hasLocationInfo(filepath, suppressedLine - 1, _, _, _)
  } or
  TMultiLineDeviation(
    DeviationRecord record, DeviationBegin beginComment, DeviationEnd endComment, string filepath,
    int suppressedStartLine, int suppressedEndLine
  ) {
    isDeviationRangePaired(record, beginComment, endComment) and
    beginComment.getLocation().hasLocationInfo(filepath, suppressedStartLine, _, _, _) and
    endComment.getLocation().hasLocationInfo(filepath, suppressedEndLine, _, _, _)
  }

class CodeIdentifierDeviation extends TCodeIndentifierDeviation {
  /** The deviation record associated with the deviation comment. */
  DeviationRecord getDeviationRecord() {
    this = TSingleLineDeviation(result, _, _, _)
    or
    this = TMultiLineDeviation(result, _, _, _, _, _)
  }

  /**
   * Holds if the given element is matched by this code identifier deviation.
   */
  bindingset[e]
  pragma[inline_late]
  predicate isElementMatching(Element e) {
    exists(string filepath, int elementLocationStart |
      e.getLocation().hasLocationInfo(filepath, elementLocationStart, _, _, _)
    |
      exists(int suppressedLine |
        this = TSingleLineDeviation(_, _, filepath, suppressedLine) and
        suppressedLine = elementLocationStart
      )
      or
      exists(int suppressedStartLine, int suppressedEndLine |
        this = TMultiLineDeviation(_, _, _, filepath, suppressedStartLine, suppressedEndLine) and
        suppressedStartLine < elementLocationStart and
        suppressedEndLine > elementLocationStart
      )
    )
  }

  string toString() {
    exists(string filepath |
      exists(int suppressedLine |
        this = TSingleLineDeviation(_, _, filepath, suppressedLine) and
        result =
          "Deviation record " + getDeviationRecord() + " applied to " + filepath + " Line " +
            suppressedLine
      )
      or
      exists(int suppressedStartLine, int suppressedEndLine |
        this = TMultiLineDeviation(_, _, _, filepath, suppressedStartLine, suppressedEndLine) and
        result =
          "Deviation record " + getDeviationRecord() + " applied to " + filepath + " Line" +
            suppressedStartLine + ":" + suppressedEndLine
      )
    )
  }
}
