import codingstandards.cpp.exceptions.ExceptionFlow

from CatchBlock cb, ThrowingExpr te, int tryDepth, int catchDepth
where cb = candidates(te, tryDepth, catchDepth)
select cb, te, tryDepth, catchDepth
