import cpp
import codingstandards.cpp.Linkage

from Element e
where not hasExternalLinkage(e) and hasInternalLinkage(e)
select e, "Element has internal linkage"
