import cpp

predicate typeGraph(Type t, Type refersTo) {
  refersTo = t.(DerivedType).getBaseType()
  or
  refersTo = t.(RoutineType).getReturnType()
  or
  refersTo = t.(RoutineType).getAParameterType()
  or
  refersTo = t.(FunctionPointerIshType).getReturnType()
  or
  refersTo = t.(FunctionPointerIshType).getAParameterType()
  or
  refersTo = t.(TypedefType).getBaseType()
}
