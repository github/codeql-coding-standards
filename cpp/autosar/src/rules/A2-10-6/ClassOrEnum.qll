/**
 * A module for representing a `ClassOrEnum` union.
 */

import cpp

class ClassOrEnum extends UserType {
  ClassOrEnum() {
    this instanceof Class
    or
    this instanceof Enum
  }

  /** Gets the name of the class or enum. */
  pragma[noinline]
  string getClassOrEnumName() {
    /*
     * This is factored out to avoid a bad join order for this particular case:
     * ```
     * exists(ClassOrEnum ec, Variable v |
     *   ec.getName() = v.getName()
     * )
     * ```
     * This was compiled to the following DIL:
     * ```
     * Variable::Variable#class#f(v),
     * Declaration::Declaration::getName_dispred#bf(v, call_result),
     * (
     *   (
     *     UserType::UserType::getName_dispred#ff(ut, call_result),
     *     UserType::UserType#class#f(ut)
     *   );
     *   (
     *     Declaration::Declaration::getName_dispred#bf(ut, call_result),
     *     UserType::UserType#class#f(ut)
     *   )
     * )
     * ```
     * Note the `UserType.getName()` call has been inlined, and because it is an overridden
     * predicate, the set of names is the union of the set of names produced by the
     * `UserType.getName()` predicate _and_ the the `Declaration.getName()`, for values of
     * `UserType`.
     *
     * It's this second part which is problematic, because it effectively becomes:
     * ```
     * Variable::Variable#class#f(v),
     * Declaration::Declaration::getName_dispred#bf(v, call_result),
     * Declaration::Declaration::getName_dispred#bf(ut, call_result),
     * ```
     * Causing a cross-product of variables with _all_ declarations which have the same name.
     */

    result = getName()
  }
}
