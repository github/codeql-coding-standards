import cpp

/**
 * An interface class as defined by AUTOSAR
 */
class AutosarInterfaceClass extends Class {
  AutosarInterfaceClass() {
    forall(MemberFunction mf | mf = this.getAMemberFunction() |
      mf.isCompilerGenerated()
      or
      mf instanceof PureVirtualFunction and mf.isPublic()
    ) and
    forall(MemberVariable mv | mv = this.getAMemberVariable() |
      mv.isConst() and mv.isStatic() and mv.isPublic()
    )
  }
}
