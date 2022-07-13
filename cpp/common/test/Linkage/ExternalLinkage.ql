import cpp
import codingstandards.cpp.Linkage

from Element e
where hasExternalLinkage(e) and not hasInternalLinkage(e)
select e, "Element has external linkage"
