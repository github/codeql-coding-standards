/** A module providing predicates that support identifying single use non volatile POD variables. */

import cpp
import codingstandards.cpp.TrivialType
import codingstandards.cpp.deadcode.UnusedVariables

/** Gets a "use" count according to rule M0-1-4. */
int getUseCount(Variable v) {
  exists(int initializers |
    // We enforce that it's a POD type variable, so if it has an initializer it is explicit
    (if v.hasInitializer() then initializers = 1 else initializers = 0) and
    result =
      initializers +
        count(VariableAccess access | access = v.getAnAccess() and not access.isCompilerGenerated())
        + count(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v)
  )
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
