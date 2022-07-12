import cpp
import codingstandards.cpp.TrivialType

from Type t
where
  isTrivialType(t) and
  exists(t.getFile().getRelativePath())
select t
