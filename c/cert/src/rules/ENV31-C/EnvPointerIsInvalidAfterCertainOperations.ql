/**
 * @id c/cert/env-pointer-is-invalid-after-certain-operations
 * @name ENV31-C: Do not rely on an env pointer following an operation that may invalidate it
 * @description EnvironmentPointerIsInvalidAfterCertainOperations
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/env31-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/*
 * Call to functions that modify the environment.
 */

class EnvModifyingCall extends FunctionCall {
  EnvModifyingCall() { this.getTarget().hasGlobalOrStdName(["setenv", "_putenv_s"]) }
}

/*
 * Function main.
 */

class MainFunction extends Function {
  MainFunction() {
    hasGlobalName("main") and
    getType() instanceof IntType
  }
}

from VariableAccess va, MainFunction main, EnvModifyingCall call, Parameter envp
where
  not isExcluded(va, Contracts1Package::envPointerIsInvalidAfterCertainOperationsQuery()) and
  // param envp exists
  main.getNumberOfParameters() >= 3 and
  envp = main.getParameter(2) and
  va.getTarget() = envp and
  va = call.getASuccessor+()
select va,
  "Accessing " + va +
    " following a $@ is invalid because the optional $@ argument is present in main.", call,
  call.toString(), envp, envp.getName()
