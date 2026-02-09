/**
 * @id c/misra/unused-tag-declaration
 * @name RULE-2-4: A project should not contain unused tag declarations
 * @description Unused tag declarations are either redundant or indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-4
 *       readability
 *       maintainability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.Uses

from UserType s
where
  not isExcluded(s, DeadCodePackage::unusedTagDeclarationQuery()) and
  // ignore structs without a tag name
  not s.isAnonymous() and
  // typedefs do not have a "tag" name, so this rule does not apply to them
  not s instanceof TypedefType and
  // Not mentioned anywhere
  not exists(TypeMention tm | tm.getMentionedType() = s) and
  // Exclude any struct that is fully generated from a macro expansion, as it may be used in other
  // expansions of the same macro.
  // Note: due to a bug in the CodeQL CLI version 2.9.4, this will currently have no effect, because
  // `isInMacroExpansion` is broken for `UserType`s.
  not s.isInMacroExpansion() and
  // Exclude template parameters, in case this is run on C++ code.
  not s instanceof TypeTemplateParameter
select s, "struct " + s.getName() + " has an unused tag."
