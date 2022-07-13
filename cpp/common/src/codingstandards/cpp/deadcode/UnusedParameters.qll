/**
 * A library for identifying parameters which may be unused.
 */

import cpp

/**
 * A `Parameter` which is "usable" within the function.
 *
 * For this to be the case, the `Function` must have a definition, and that definition must include
 * a body block, and the parameter must be a named parameter.
 */
class UsableParameter extends Parameter {
  UsableParameter() {
    // Find the function associated with the parameter
    exists(Function f | this = f.getAParameter() |
      // Must have the definition of the function, not just the declaration
      f.hasDefinition() and
      // There must be a body block associated with the function, otherwise the parameter cannot
      // possibly be used
      exists(f.getBlock())
    ) and
    // Must be a named parameter, because unnamed parameters cannot be referenced
    isNamed()
  }
}

/**
 * A `Parameter` which is usable but not directly used in the local context.
 */
class UnusedParameter extends UsableParameter {
  UnusedParameter() { not this instanceof UsedParameter }
}

/**
 * A `Parameter` which is used in the local context.
 */
class UsedParameter extends UsableParameter {
  UsedParameter() {
    // An access to the parameter exists in the function body
    exists(getAnAccess())
  }
}
