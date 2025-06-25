import codingstandards.cpp.Identifiers

from IdentifierIntroduction ident
where ident.getLocation().getFile().getBaseName() = "test.cpp"
select ident.getLocation().toString(), ident.getIdent(), ident
