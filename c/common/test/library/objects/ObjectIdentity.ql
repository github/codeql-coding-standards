import codingstandards.c.Objects

from ObjectIdentity obj
where obj.getFile().getBaseName() = "objectidentity.c"
select obj, obj.getStorageDuration(), obj.getType()
