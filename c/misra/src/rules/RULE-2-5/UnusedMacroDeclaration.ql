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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra

from Macro m
where
  not isExcluded(m, DeadCodePackage::unusedMacroDeclarationQuery()) and
  // We consider a macro "used" if there is a macro access
  not exists(MacroAccess ma | ma.getMacro() = m) and
  // Or if there exists a check whether the macro is defined which the extractor
  // hasn't been able to tie to a macro (usually because this use came before
  // the macro was defined e.g. a header guard)
  not exists(PreprocessorBranchDirective bd |
    // Covers the #ifdef and #ifndef cases
    bd.getHead() = m.getName()
    or
    // Covers the use of defined() to check if a macro is defined
    m.getName() = bd.getHead().regexpCapture(".*defined *\\(? *([^\\s()]+) *\\)?\\.*", 1)
  ) and
  // We consider a macro "used" if the name is undef-ed at some point in the same file, or a file
  // that includes the file defining the macro. This will over approximate use in the case of a
  // macro which is defined, then undefined, then re-defined but not used.
  not exists(PreprocessorUndef u |
    u.getName() = m.getName() and u.getFile().getAnIncludedFile*() = m.getFile()
  )
select m, "Macro " + m.getName() + " is unused."
