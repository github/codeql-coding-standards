/**
 * Provides a library with a `problems` predicate for the following issue:
 * An object shall not be copied or assigned to an overlapping object.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.c.misra
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

abstract class ObjectAssignedToAnOverlappingObjectSharedQuery extends Query { }

Query getQuery() { result instanceof ObjectAssignedToAnOverlappingObjectSharedQuery }

VariableAccess getAQualifier(VariableAccess va) { result = va.getQualifier+() }

int getAccessByteOffset(FieldAccess fa) {
  not fa.getQualifier() instanceof FieldAccess and result = fa.getTarget().getByteOffset()
  or
  result = fa.getTarget().getByteOffset() + getAccessByteOffset(fa.getQualifier())
}

predicate overlaps(FieldAccess fa1, FieldAccess fa2) {
  exists(int startfa1, int endfa1, int startfa2, int endfa2 |
    startfa1 = getAccessByteOffset(fa1) and
    endfa1 = startfa1 + fa1.getTarget().getType().getSize() - 1 and
    startfa2 = getAccessByteOffset(fa2) and
    endfa2 = startfa2 + fa2.getTarget().getType().getSize() - 1
  |
    startfa1 = startfa2 and endfa1 = endfa2
    or
    startfa1 > startfa2 and endfa1 < endfa2
    or
    startfa1 < startfa2 and endfa1 < endfa2 and endfa1 > startfa2
    or
    startfa1 > startfa2 and endfa1 > endfa2 and startfa1 < endfa2
  )
}

query predicate problems(
  AssignExpr assignExpr, string message, ValueFieldAccess valuelhs, string valuelhsTargetName,
  ValueFieldAccess valuerhs, string valuerhsTargetName
) {
  /*
   * from AssignExpr assignExpr, Expr lhs, Expr rhs, ValueFieldAccess valuelhs, ValueFieldAccess valuerhs
   * where
   *  not isExcluded(assignExpr, Contracts7Package::objectAssignedToAnOverlappingObjectQuery()) and
   *  lhs.getType() instanceof Union and
   *  rhs.getType() instanceof Union and
   *  lhs = getAQualifier(assignExpr.getLValue()) and
   *  rhs = getAQualifier(assignExpr.getRValue()) and
   *  globalValueNumber(lhs) = globalValueNumber(rhs) and
   *  valuerhs = assignExpr.getRValue() and
   *  valuelhs = assignExpr.getLValue() and // a.b.c == ((a.b).c)
   *  overlaps(valuelhs, valuerhs)
   * select assignExpr, "An object $@ assigned to overlapping object $@.", valuelhs,
   *  valuelhs.getTarget().getName(), valuerhs, valuerhs.getTarget().getName()
   */

  exists(Expr lhs, Expr rhs |
    lhs.getType() instanceof Union and
    rhs.getType() instanceof Union and
    lhs = getAQualifier(assignExpr.getLValue()) and
    rhs = getAQualifier(assignExpr.getRValue()) and
    globalValueNumber(lhs) = globalValueNumber(rhs) and
    valuerhs = assignExpr.getRValue() and
    valuelhs = assignExpr.getLValue() and // a.b.c == ((a.b).c)
    overlaps(valuelhs, valuerhs) and
    message = "An object $@ assigned to overlapping object $@." and
    valuelhsTargetName = valuelhs.getTarget().getName() and
    valuerhsTargetName = valuerhs.getTarget().getName()
  )
}
