import cpp

from Macro m
where not m.getName().matches("\\_%") // exclude internal macro's that start with a '_' or '__'
select m.getName()
