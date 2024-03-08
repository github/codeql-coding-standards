import cpp
import Standard

from UserType t
where
  // Restrict to declarations in `std` namespace as the global namespace in a real database
  // includes types outside the C/C++ standard library.
  declInStdNamespace(t) and
  // Do not report types from template instantiations - instead report the uninstantiated template
  not t.isFromTemplateInstantiation(_)
select getStandard(), t.getFile().getBaseName(), getVisibleNamespaceString(t.getNamespace()),
  t.getSimpleName()
