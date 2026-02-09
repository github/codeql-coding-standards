import cpp
import codingstandards.cpp.types.TrivialType

from Type t
where
  isTrivialType(t) and
  exists(t.getFile().getRelativePath())
select t
