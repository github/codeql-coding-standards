/**
 * A module for reasoning about the equivalence of `Function`s and `Parameter`s.
 *
 * There are a number of reasons why we might have multiple `Function` instances for the same
 * conceptual function:
 *  - The build process did not link together separate object files, either due to an incomplete
 *    build command, linker interception being disable or linker interception failing.
 *  - The build process compiled multiple separate binaries which are intended to be dynamically
 *    linked together (so were not statically linked during the build).
 *  - The build process compiled multiple versions of the code, for example for different platforms.
 *
 * This library creates equivalence classes for `Function`s and `Parameter`s to help identify such
 * cases. The equivalence classes are based purely on the function signature - the qualified name,
 * and a string representing the types of the parameters. This is an overapproximation: if two
 * completely separate binaries are compiled in the same database, we may conflate functions or
 * parameters with the same signature but which are intended to be separate functions. Consider
 * whether this over approximation is suitable for your particular use case.
 */

import cpp

/**
 * Gets the type signature for the functions parameters.
 */
string typeSig(Function f) {
  result =
    concat(int i, Type pt |
      pt = f.getParameter(i).getType()
    |
      pt.getUnspecifiedType().toString(), "," order by i
    )
}

/**
 * Holds where `qualifiedName` and `typeSig` make up the signature for the function.
 */
private predicate functionSignature(Function f, string qualifiedName, string typeSig) {
  qualifiedName = f.getQualifiedName() and
  typeSig = typeSig(f)
}

/**
 * Gets another `Function` which notionally represents the same function as the provided `Function` `f`.
 */
Function getAnEquivalentFunction(Function f) {
  exists(string qn, string typeSig |
    functionSignature(f, qn, typeSig) and functionSignature(result, qn, typeSig)
  )
  or
  // We are always equivalent to ourselves. This is required because functions declared in other
  // functions do not have a qualified name, so we add this condition to enforce reflexivity.
  result = f
}

private newtype TParameterEquivalenceClass =
  TParameter(string qualifiedName, string typeSig, int index) {
    exists(Parameter p |
      functionSignature(p.getFunction(), qualifiedName, typeSig) and
      index = p.getIndex()
    )
  }

/**
 * An equivalence class for `Parameter`s which conceptually represent the same parameter across
 * translation units and different compilations (for example, for different platforms).
 */
class ParameterEquivalenceClass extends TParameterEquivalenceClass {
  /** Gets a `Function` whose `Parameter` at `index` is part of the equivalence class. */
  pragma[nomagic]
  private Function getAFunction(int index) {
    exists(string qualifiedName, string typeSig |
      functionSignature(result, qualifiedName, typeSig) and
      this = TParameter(qualifiedName, typeSig, index)
    )
  }

  /** Gets a `Parameter` in this equivalence class. */
  Parameter getAParameter() { result.getFunction() = getAFunction(result.getIndex()) }

  /** Gets a location of at least one of the parameters. */
  Location getLocation() { result = getAParameter().getLocation() }

  /** Gets a name for this parameter. */
  string getAName() { result = getAParameter().getName() }

  /** Gets the qualified name of the function associated with the parameter. */
  string getFunctionQualifiedName() { this = TParameter(result, _, _) }

  string toString() { result = getAName() }
}
