import cpp
import codingstandards.cpp.StructuralEquivalence

from Function f, Function g
where getFunctionHashCons(f) = getFunctionHashCons(g)
select f, g
