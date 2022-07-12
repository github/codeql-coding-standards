import cpp

predicate hasVirtualtable(Class cl1) {
  // virtual member in class
  exists(MemberFunction mf1 |
    mf1 = cl1.getAMemberFunction() and
    mf1.isVirtual()
  )
  or
  // virtual base class
  exists(Class base | cl1.hasVirtualBaseClass(base))
  or
  hasVirtualtable(cl1.getABaseClass+())
}
