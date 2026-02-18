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
    this =
      max(Declaration decl, Location l |
        decl = cls.getADeclaration() and
        l = decl.getLocation()
      |
        decl order by l.getEndLine(), l.getEndColumn()
      )
  }
}
