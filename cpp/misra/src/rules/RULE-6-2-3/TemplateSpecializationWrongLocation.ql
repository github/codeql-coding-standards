/**
 * @id cpp/misra/template-specialization-wrong-location
 * @name RULE-6-2-3: RULE-6-2-3: Template specializations in wrong location
 * @description Template specializations must be defined in the same file as the primary template or
 *              where a specialized type is defined to ensure visibility and avoid ODR violations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2-3
 *       correctness
 *       maintainability
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

predicate specializedWithFileDeclaredType(ClassTemplateSpecialization spec) {
  exists(Type argType |
    spec.getTemplateArgument(_).(Type).getUnderlyingType() = argType and
    spec.getFile() = argType.getFile() and
    not argType instanceof TypeTemplateParameter
  )
}

from ClassTemplateSpecialization spec, Class primaryTemplate, File primaryFile
where
  not isExcluded(spec, Declarations8Package::templateSpecializationWrongLocationQuery()) and
  spec.getPrimaryTemplate() = primaryTemplate and
  primaryFile = primaryTemplate.getFile() and
  // The specialization is in a different file than the primary template
  spec.getFile() != primaryFile and
  // And it's not in the same file as any of its template arguments
  not specializedWithFileDeclaredType(spec)
select spec,
  "Template specialization '" + spec.getName() +
    "' is declared in a different file than $@ and all specialized template arguments.",
  primaryTemplate, primaryTemplate.getName()
