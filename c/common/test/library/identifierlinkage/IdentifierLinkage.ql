import codingstandards.c.IdentifierLinkage

from Variable v
where not v.getLocation().toString() = "file://:0:0:0:0"
select v, linkageOfVariable(v)
