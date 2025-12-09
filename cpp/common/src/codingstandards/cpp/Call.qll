import cpp
import codingstandards.cpp.types.Type
import codingstandards.cpp.types.FunctionType

/**
 * Gets the `FunctionType` of an expression call.
 */
FunctionType getExprCallFunctionType(ExprCall call) {
  // A standard expression call
  // Returns a FunctionPointerIshType
  result = call.(ExprCall).getExpr().getType()
  or
  // An expression call using the pointer to member operator (.* or ->*)
  // This special handling is required because we don't have a CodeQL class representing the call
  // to a pointer to member function, but the right hand side is extracted as the -1 child of the
  // call.
  // Returns a RoutineType
  result = call.(ExprCall).getChild(-1).getType().(PointerToMemberType).getBaseType()
}
