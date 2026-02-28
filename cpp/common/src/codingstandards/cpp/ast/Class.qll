import cpp

/**
 * The last declaration in a class by location order.
 *
 * This may fail to capture certain cases such as hidden friends (see HiddenFriend.qll).
 */
class LastClassDeclaration extends Declaration {
  Class cls;

  pragma[nomagic]
  LastClassDeclaration() {
    cls.getADeclaration() = this and
    getLocation().getEndLine() = getLastLineOfClassDeclaration(cls)
  }
}

/**
 * Gets the line number of the last line of the declaration of `cls`.
 *
 * This is often more performant to use than `LastClassDeclaration.getLocation().getEndLine()`.
 */
int getLastLineOfClassDeclaration(Class cls) {
  result =
    max(int endLine |
      endLine = pragma[only_bind_out](cls).getADeclaration().getLocation().getEndLine()
    )
}
