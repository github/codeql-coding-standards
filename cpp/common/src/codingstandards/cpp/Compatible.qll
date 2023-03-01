import cpp

predicate typesCompatible(Type t1, Type t2) {
  t1 = t2
  or
  //signed int is same as int ect
  t1.(IntegralType).getCanonicalArithmeticType() = t2.(IntegralType).getCanonicalArithmeticType()
}

predicate parameterTypesIncompatible(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  exists(ParameterDeclarationEntry p1, ParameterDeclarationEntry p2, int i |
    p1 = f1.getParameterDeclarationEntry(i) and
    p2 = f2.getParameterDeclarationEntry(i)
  |
    not typesCompatible(p1.getType(), p2.getType())
  )
}

predicate parameterNamesIncompatible(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  exists(ParameterDeclarationEntry p1, ParameterDeclarationEntry p2, int i |
    p1 = f1.getParameterDeclarationEntry(i) and
    p2 = f2.getParameterDeclarationEntry(i)
  |
    not p1.getName() = p2.getName()
  )
}
