import cpp
import codingstandards.cpp.autosar

/**
 * A helper class describing macros wrapping defined operator
 */
class DefinedMacro extends Macro {
  DefinedMacro() {
    this.getBody().regexpMatch("defined\\s*\\(.*")
    or
    this.getBody().regexpMatch("defined[\\s]+|defined$")
  }

  Macro getAUse() {
    result = this or
    anyAliasing(result, this)
  }
}

predicate directAlias(Macro alias, Macro aliased) {
  not alias.getBody() = alias.getBody().replaceAll(aliased.getHead(), "")
}

predicate anyAliasing(Macro alias, Macro inQ) {
  directAlias(alias, inQ)
  or
  exists(Macro intermediate | anyAliasing(intermediate, inQ) and anyAliasing(alias, intermediate))
}
