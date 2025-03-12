/** A module providing predicates that support identifying single use non volatile POD variables. */

import cpp
import codingstandards.cpp.types.TrivialType
import codingstandards.cpp.deadcode.UnusedVariables

/**
 * Gets the number of uses of variable `v` in an opaque assignment, where an opaque assignment is a cast from one type to the other, and `v` is assumed to be a member of the resulting type.
 * e.g.,
 * struct foo {
 *  int bar;
 * }
 *
 * struct foo * v = (struct foo*)buffer;
 */
Expr getIndirectSubObjectAssignedValue(MemberVariable subobject) {
  // struct foo * ptr = (struct foo*)buffer;
  exists(Struct someStruct, Variable instanceOfSomeStruct | someStruct.getAMember() = subobject |
    instanceOfSomeStruct.getType().(PointerType).getBaseType() = someStruct and
    exists(Cast assignedValue |
      // Exclude cases like struct foo * v = nullptr;
      not assignedValue.isImplicit() and
      // `v` is a subobject of another type that reinterprets another object. We count that as a use of `v`.
      assignedValue.getExpr() = instanceOfSomeStruct.getAnAssignedValue() and
      result = assignedValue
    )
    or
    // struct foo; read(..., (char *)&foo);
    instanceOfSomeStruct.getType() = someStruct and
    exists(Call externalInitializerCall, Cast castToCharPointer, int n |
      externalInitializerCall.getArgument(n).(AddressOfExpr).getOperand() =
        instanceOfSomeStruct.getAnAccess() and
      externalInitializerCall.getArgument(n) = castToCharPointer.getExpr() and
      castToCharPointer.getType().(PointerType).getBaseType().getUnspecifiedType() instanceof
        CharType and
      result = externalInitializerCall
    )
    or
    // the object this subject is part of is initialized and we assume this initializes the subobject.
    instanceOfSomeStruct.getType() = someStruct and
    result = instanceOfSomeStruct.getInitializer().getExpr()
  )
}

/** Gets a "use" count according to rule M0-1-4. */
int getUseCount(Variable v) {
  // We enforce that it's a POD type variable, so if it has an initializer it is explicit
  result =
    count(getAUserInitializedValue(v)) +
      count(VariableAccess access | access = v.getAnAccess() and not access.isCompilerGenerated()) +
      // For constexpr variables used as template arguments, we don't see accesses (just the
      // appropriate literals). We therefore take a conservative approach and count the number of
      // template instantiations that use the given constant, and consider each one to be a use
      // of the variable
      count(ClassTemplateInstantiation cti |
        cti.getTemplateArgument(_).(Expr).getValue() = getConstExprValue(v)
      ) + count(getIndirectSubObjectAssignedValue(v))
}

Expr getAUserInitializedValue(Variable v) {
  (
    result = v.getInitializer().getExpr()
    or
    exists(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v and result = cfi.getExpr())
    or
    exists(ClassAggregateLiteral l | not l.isCompilerGenerated() | result = l.getAFieldExpr(v))
  ) and
  not result.isCompilerGenerated()
}

/** Gets a single use of `v`, if `isSingleUseNonVolatilePODVariable` holds. */
Element getSingleUse(Variable v) {
  isSingleUseNonVolatilePODVariable(v) and
  (
    result = v.getInitializer()
    or
    result = any(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v)
    or
    exists(VariableAccess access |
      access = v.getAnAccess() and not access.isCompilerGenerated() and result = access
    )
  )
}

/** Holds if the given variable is non-volatile POD type variable with a single use. */
predicate isSingleUseNonVolatilePODVariable(Variable v) {
  // Not volatile
  not v.isVolatile() and
  // This is a POD type
  v.getType() instanceof PODType and
  getUseCount(v) = 1
}
