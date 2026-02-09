import codingstandards.cpp.Scope

from Element e, Element parent
where Internal::getParentScope(e) = parent
select e, parent
