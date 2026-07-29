import cpp
import codingstandards.cpp.ast.ValueCategory

predicate isRelevant(Expr e) {
  e.(VariableAccess).getTarget().hasName(["val", "ref", "rref"])
  or
  e.(FunctionCall).getTarget().hasName(["get_val", "get_ref", "get_rref", "move"])
}

from Expr e, ValueCategory cat
where
  e.getEnclosingFunction().hasName("main") and
  isRelevant(e) and
  cat = getValueCategory(e)
select e, cat
