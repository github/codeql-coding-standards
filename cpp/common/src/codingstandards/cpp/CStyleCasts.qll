import cpp
import codingstandards.cpp.Macro

/**
 * A C-style cast that is explicitly user written and has a known target type.
 */
class ExplicitUserDefinedCStyleCast extends CStyleCast {
  ExplicitUserDefinedCStyleCast() {
    not this.isImplicit() and
    not this.getType() instanceof UnknownType and
    // For casts in templates that occur on types related to a template parameter, the copy of th
    // cast in the uninstantiated template is represented as a `CStyleCast` even if in practice all
    // the instantiations represent it as a `ConstructorCall`. To avoid the common false positive case
    // of using the functional cast notation to call a constructor we exclude all `CStyleCast`s on
    // uninstantiated templates, and instead rely on reporting results within instantiations.
    not this.isFromUninstantiatedTemplate(_)
  }
}
