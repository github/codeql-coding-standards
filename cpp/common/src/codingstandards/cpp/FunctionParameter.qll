import cpp
import codingstandards.cpp.EncapsulatingFunctions

/**
 * `Parameter`s that belong to `Function`s only
 * not catch try blocks
 */
class FunctionParameter extends Parameter {
  FunctionParameter() {
    exists(this.getFunction()) and
    //ignore uninstantiated templates where we dont even have accesses necessarily visible
    not this.getFunction().isFromUninstantiatedTemplate(_) and
    //ignore functions without definitions, of course those are unmodified (ie not interesting)
    this.getFunction().hasDefinition()
  }
}

/**
 * A parameter that is accessed.
 */
class AccessedParameter extends Parameter {
  AccessedParameter() { exists(this.getAnAccess()) }
}
