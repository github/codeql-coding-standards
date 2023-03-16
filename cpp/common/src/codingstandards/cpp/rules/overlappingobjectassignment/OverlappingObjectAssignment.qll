/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

abstract class OverlappingObjectAssignmentSharedQuery extends Query { }

Query getQuery() { result instanceof OverlappingObjectAssignmentSharedQuery }

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
    startfa2 >= startfa1 and endfa2 <= endfa1
    or
    startfa2 <= startfa1 and endfa2 > startfa1
    or
    startfa2 < endfa1 and endfa2 >= startfa1
  )
}

query predicate problems(
  AssignExpr assignExpr, string message, ValueFieldAccess valuelhs, string valuelhsDesc,
  ValueFieldAccess valuerhs, string valuerhsDesc
) {
  not isExcluded(assignExpr, getQuery()) and
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
    valuelhsDesc = valuelhs.getTarget().getName() and
    valuerhsDesc = valuerhs.getTarget().getName()
  )
}
