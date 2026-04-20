/**
 * @id cpp/misra/duplicate-type-definitions
 * @name RULE-6-2-3: RULE-6-2-3: Duplicate type definitions across files
 * @description Defining a type with the same fully qualified name in multiple files increases the
 *              risk of ODR violations and undefined behavior.
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
import codingstandards.cpp.Linkage

class UserTypeDefinition extends TypeDeclarationEntry {
  UserTypeDefinition() {
    (isDefinition() or getDeclaration() instanceof TypedefType) and
    not getDeclaration().(Class).isAnonymous() and
    not getDeclaration().(Union).isAnonymous() and
    not getDeclaration().(Enum).isAnonymous() and
    not getDeclaration() instanceof ClassTemplateSpecialization and
    not getDeclaration().getNamespace() instanceof WithinAnonymousNamespace
  }

  UserType getUserType() { result = getDeclaration() }
}

from UserTypeDefinition t1, UserTypeDefinition t2
where
  not isExcluded(t1, Declarations8Package::duplicateTypeDefinitionsQuery()) and
  t1.getUserType().getQualifiedName() = t2.getUserType().getQualifiedName() and
  t1.getFile() != t2.getFile() and
  t1.getFile().getAbsolutePath() < t2.getFile().getAbsolutePath() // Report only once per pair
select t1, "Type '" + t1.getUserType().getQualifiedName() + "' is defined in files $@ and $@.", t1,
  t1.getFile().getBaseName(), t2, t2.getFile().getBaseName()
