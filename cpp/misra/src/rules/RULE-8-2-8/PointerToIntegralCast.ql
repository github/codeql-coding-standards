/**
 * @id cpp/misra/pointer-to-integral-cast
 * @name RULE-8-2-8: An object pointer type shall not be cast to an integral type other than std::uintptr_t or
 * @description Casting object pointers to integral types other than std::uintptr_t or std::intptr_t
 *              can lead to implementation-defined behavior and potential loss of pointer
 *              information.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-8
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Type

class InvalidReinterpretCast extends ReinterpretCast {
  InvalidReinterpretCast() {
    this.getExpr().getType().stripTopLevelSpecifiers() instanceof PointerType and
    this.getType().getUnspecifiedType() instanceof IntegralType and
    not stripSpecifiers(this.getType()).(UserType).hasGlobalOrStdName(["uintptr_t", "intptr_t"])
  }
}

from
  InvalidReinterpretCast cast, string message, Element optionalTemplateUseSite,
  string optionalTemplateUseSiteString
where
  not isExcluded(cast, Conversions2Package::pointerToIntegralCastQuery()) and
  // Where a result occurs in both the instantiated and uninstantiated template,
  // prefer the uninstantiated version.
  not exists(InvalidReinterpretCast otherCast |
    otherCast.getLocation() = cast.getLocation() and
    not otherCast = cast and
    otherCast.isFromUninstantiatedTemplate(_)
  ) and
  if not cast.isFromTemplateInstantiation(_)
  then
    // Either not in a template, or appears in the uninstantiated template and is
    // therefore not argument dependent.
    message =
      "Cast of object pointer type to integral type '" + cast.getType() +
        "' instead of 'std::uintptr_t' or 'std::intptr_t'." and
    optionalTemplateUseSite = cast and
    optionalTemplateUseSiteString = ""
  else
    // This is from a template instantiation and is dependent on a template argument,
    // so attempt to identify the locations which instantiate the template.
    exists(Element instantiation |
      cast.isFromTemplateInstantiation(instantiation) and
      message = "Cast of object pointer type to integral type inside $@."
    |
      optionalTemplateUseSite = instantiation.(ClassTemplateInstantiation).getATypeNameUse() and
      optionalTemplateUseSiteString =
        "instantiation of class " + instantiation.(ClassTemplateInstantiation).getName()
      or
      optionalTemplateUseSite =
        instantiation.(FunctionTemplateInstantiation).getACallToThisFunction() and
      optionalTemplateUseSiteString =
        "call to instantiated template f of " +
          instantiation.(FunctionTemplateInstantiation).getName()
      or
      optionalTemplateUseSite = instantiation.(VariableTemplateInstantiation).getAnAccess() and
      optionalTemplateUseSiteString =
        "reference to instantiated template variable " +
          instantiation.(VariableTemplateInstantiation).getName()
    )
select cast, message, optionalTemplateUseSite, optionalTemplateUseSiteString
