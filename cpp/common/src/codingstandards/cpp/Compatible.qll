import cpp

predicate typesCompatible(Type t1, Type t2) {
  t1 = t2
  or
  //signed int is same as int ect
  t1.(IntegralType).getCanonicalArithmeticType() = t2.(IntegralType).getCanonicalArithmeticType()
}
