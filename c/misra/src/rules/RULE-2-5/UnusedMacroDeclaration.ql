/**
 * @id c/misra/unused-macro-declaration
 * @name RULE-2-5: A project should not contain unused macro declarations
 * @description Unused macro declarations are either redundant or indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-5
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Macro m
where
  not isExcluded(m, DeadCodePackage::unusedMacroDeclarationQuery()) and
  not exists(MacroAccess ma | ma.getMacro() = m) and
  // We consider a macro "used" if the name is undef-ed at some point in the same file, or a file
  // that includes the file defining the macro. This will over approximate use in the case of a
  // macro which is defined, then undefined, then re-defined but not used.
  not exists(PreprocessorUndef u |
    u.getName() = m.getName() and u.getFile().getAnIncludedFile*() = m.getFile()
  )
select m, "Macro " + m.getName() + " is unused."
