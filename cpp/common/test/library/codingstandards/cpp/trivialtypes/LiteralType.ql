import cpp
import codingstandards.cpp.TrivialType

from Type t
where
  isLiteralType(t) and
  exists(t.getFile().getRelativePath())
select t
