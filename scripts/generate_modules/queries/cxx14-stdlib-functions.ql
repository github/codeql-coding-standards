import cpp

from TopLevelFunction f
where
  not exists(f.getAFile().getRelativePath()) and
  not f.isCompilerGenerated() and
  not f instanceof Operator and // exclude user defined operators
  not f.getName().matches("\\_%") and // exclude internal functions starting with '_' or '__'
  not f.getName().matches("operator \"%") and // exclude user defined literals
  f.hasGlobalOrStdName(_)
select f.getName(), f.getQualifiedName()
