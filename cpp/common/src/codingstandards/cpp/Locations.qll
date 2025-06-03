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

bindingset[a, b]
predicate shareEnding(Locatable a, Locatable b) {
  exists(Location la, Location lb |
    la = a.getLocation() and
    lb = b.getLocation() and
    la.getFile() = lb.getFile() and
    la.getEndLine() = lb.getEndLine() and
    la.getEndColumn() = lb.getEndColumn()
  )
}
