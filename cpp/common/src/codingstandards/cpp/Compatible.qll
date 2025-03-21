import cpp

pragma[noinline]
pragma[nomagic]
predicate typesCompatible(Type t1, Type t2) {
  t1 = t2
  or
  //signed int is same as int ect
  t1.(IntegralType).getCanonicalArithmeticType() = t2.(IntegralType).getCanonicalArithmeticType()
}

predicate parameterTypesIncompatible(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  f1.getDeclaration() = f2.getDeclaration() and
  exists(ParameterDeclarationEntry p1, ParameterDeclarationEntry p2, int i |
    p1 = f1.getParameterDeclarationEntry(i) and
    p2 = f2.getParameterDeclarationEntry(i)
  |
    not typesCompatible(p1.getType(), p2.getType())
  )
}

predicate parameterNamesIncompatible(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  f1.getDeclaration() = f2.getDeclaration() and
  exists(string p1Name, string p2Name, int i |
    p1Name = f1.getParameterDeclarationEntry(i).getName() and
    p2Name = f2.getParameterDeclarationEntry(i).getName()
  |
    not p1Name = p2Name
  )
}
