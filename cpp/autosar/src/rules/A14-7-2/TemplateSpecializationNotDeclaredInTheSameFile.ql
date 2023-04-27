/**
 * @id cpp/autosar/template-specialization-not-declared-in-the-same-file
 * @name A14-7-2: Template specialization shall be declared in the same file as the primary template or as a user-defined type
 * @description Template specialization shall be declared in the same file (1) as the primary
 *              template (2) as a user-defined type, for which the specialization is declared,
 *              otherwise the behaviour is undefined.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a14-7-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * Either a `ClassTemplateSpecialization` or
 * `FunctionTemplateSpecialization`
 */
class Specialization extends Declaration {
  Declaration tm;

  Specialization() {
    this instanceof ClassTemplateSpecialization and
    tm = this.(ClassTemplateSpecialization).getPrimaryTemplate()
    or
    this instanceof FunctionTemplateSpecialization and
    tm = this.(FunctionTemplateSpecialization).getPrimaryTemplate()
  }

  Declaration getPrimary() { result = tm }
}

predicate allTemplateArgsInSameFile(Specialization spec) {
  forall(UserType type | type = spec.getATemplateArgument() | spec.getFile() = type.getFile())
}

predicate allTemplateArgsUserType(Specialization spec) {
  forall(Type type | type = spec.getATemplateArgument() | type instanceof UserType)
}

predicate extraExclude(Specialization spec) {
  //if all template args are user types
  allTemplateArgsUserType(spec) and
  //and all of those user types are declared in same file
  allTemplateArgsInSameFile(spec)
  //then exclude this case
}

from Specialization spec
where
  not isExcluded(spec, TemplatesPackage::templateSpecializationNotDeclaredInTheSameFileQuery()) and
  not spec.getFile() = spec.getPrimary().getFile() and
  not extraExclude(spec)
select spec, "Specialization found in file $@ where primary template is outside that file.",
  spec.getFile(), spec.getFile().getBaseName()
