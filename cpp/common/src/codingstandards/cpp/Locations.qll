import cpp

/** Holds if `lineNumber` is an indexed line number in file `f`. */
predicate isLineNumber(File f, int lineNumber) {
  exists(Location l | l.getFile() = f |
    l.getStartLine() = lineNumber
    or
    l.getEndLine() = lineNumber
  )
}

/** Gets the last line number in `f`. */
int getLastLineNumber(File f) { result = max(int lineNumber | isLineNumber(f, lineNumber)) }

/** Gets the last column number on the last line of `f`. */
int getLastColumnNumber(File f) {
  result =
    max(Location l |
      l.getFile() = f and
      l.getEndLine() = getLastLineNumber(f)
    |
      l.getEndColumn()
    )
}

/** Gets the last column number on the given line of `filepath`. */
bindingset[filepath, lineNumber]
int getLastColumnNumber(string filepath, int lineNumber) {
  result = max(Location l | l.hasLocationInfo(filepath, _, _, lineNumber, _) | l.getEndColumn())
}
