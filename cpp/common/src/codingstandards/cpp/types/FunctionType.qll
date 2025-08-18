import cpp

/**
 * Convenience class to reduce the awkwardness of how `RoutineType` and `FunctionPointerIshType`
 * don't have a common ancestor.
 */
class FunctionType extends Type {
  FunctionType() { this instanceof RoutineType or this instanceof FunctionPointerIshType }

  Type getReturnType() {
    result = this.(RoutineType).getReturnType() or
    result = this.(FunctionPointerIshType).getReturnType()
  }

  Type getParameterType(int i) {
    result = this.(RoutineType).getParameterType(i) or
    result = this.(FunctionPointerIshType).getParameterType(i)
  }
}
