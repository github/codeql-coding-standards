import cpp
import codingstandards.cpp.Linkage

from Element e
where hasExternalLinkage(e) and hasInternalLinkage(e)
select e, "Element has both external and internal linkage"
