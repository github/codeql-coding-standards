import cpp

predicate isErrno(VariableAccess va) {
  va.getTarget().hasName("errno") or
  va.getTarget().hasName("__errno")
}
