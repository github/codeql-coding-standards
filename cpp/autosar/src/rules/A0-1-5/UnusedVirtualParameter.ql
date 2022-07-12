/**
 * @id cpp/autosar/unused-virtual-parameter
 * @name A0-1-5: There shall be no unused named parameters in virtual functions
 * @description There shall be no unused named parameters in the set of parameters for a virtual
 *              function and all the functions that override it.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-5
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedParameters
import codingstandards.cpp.FunctionEquivalence

/**
 * A parameter in the program which is both named and in a virtual function.
 *
 * Due to dynamic linking and re-compilation of code (for example, for different platforms), we may
 * get multiple `Parameter` instances in the database for the same conceptual parameter. For a dead
 * code query, this means we could erroneously flag one `Parameter` as dead, if it is only used in
 * a dynamically loaded library.
 *
 * This class uses `ParameterEquivalenceClass` to identify equivalent parameters based on the function
 * signature. This could be a slight overapproximation, but for dead code that is preferable.
 */
class NamedVirtualParameterEquivalenceClass extends ParameterEquivalenceClass {
  NamedVirtualParameterEquivalenceClass() {
    exists(Parameter p |
      p = getAParameter() and
      p.isNamed() and
      p.getFunction() instanceof VirtualFunction
    )
  }

  /** Gets a named `ParameterDeclarationEntry` for a `Parameter` in this equivalence class. */
  private ParameterDeclarationEntry getADeclarationEntry() {
    // Copied from Parameter.getAnEffectiveDeclarationEntry, to workaround the lack of
    // ParameterDeclarationEntry's in template instantions
    exists(Parameter p | p = getAParameter() |
      if p.getFunction().isConstructedFrom(_)
      then
        exists(Function prototypeInstantiation |
          prototypeInstantiation.getParameter(p.getIndex()) = result.getVariable() and
          p.getFunction().isConstructedFrom(prototypeInstantiation)
        )
      else result = p.getADeclarationEntry()
    ) and
    exists(result.getName())
  }

  override Location getLocation() {
    // Overide the default location, to only report ParameterDeclarationEntries with named parameters.
    // This covers the case where the function declaration has named parameters, but the function
    // definition has unnamed parameters.
    exists(ParameterDeclarationEntry pde |
      pde = getADeclarationEntry() and
      result = pde.getLocation()
    |
      // Prefer the Parameter definition, if available and named
      pde.isDefinition()
      or
      not getADeclarationEntry().isDefinition()
    )
  }

  /** Gets a `Parameter` which overrides a `Parameter` in this equivalence class. */
  Parameter getAnOverridingParameter() { result = getAnOverridingParameter(getAParameter()) }
}

/** Gets a parameter that overrides the given parameter. */
Parameter getAnOverridingParameter(Parameter p) {
  exists(int paramIndex |
    paramIndex = p.getIndex() and
    exists(MemberFunction mf |
      mf = p.getFunction().(VirtualFunction).getAnOverridingFunction*() and
      result = mf.getParameter(paramIndex)
    )
  )
}

from
  NamedVirtualParameterEquivalenceClass namedVirtualParameter,
  ParameterEquivalenceClass unusedNamedOverridingParameter
where
  // None of the `Parameter` instances associated with this equivalence class are excluded
  not isExcluded(namedVirtualParameter.getAParameter(),
    DeadCodePackage::unusedVirtualParameterQuery()) and
  // Ignore parameters in uninstantiated templates, because the body of those functions are syntax
  // only, and virtual functions in uninstantiated templates do not have overriding links in the
  // database. However, this will not stop us analyzing instantiated templates.
  not namedVirtualParameter.getAParameter().getFunction().isFromUninstantiatedTemplate(_) and
  // And there does not exist an overriding parameter which is used
  not exists(UsedParameter used | used = namedVirtualParameter.getAnOverridingParameter()) and
  // We identify all possible overriding parameters, to provide additional supporting information
  // to help the user verify that the parameter is indeed unused.
  unusedNamedOverridingParameter.getAParameter() = namedVirtualParameter.getAnOverridingParameter()
select namedVirtualParameter,
  "Named parameter '" + namedVirtualParameter.getAName() + "' is unused in virtual function " +
    namedVirtualParameter.getFunctionQualifiedName() + " and all $@ present in the analyzed code.",
  unusedNamedOverridingParameter, "overrides"
