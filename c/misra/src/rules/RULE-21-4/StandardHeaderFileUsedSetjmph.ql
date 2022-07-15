/**
 * @id c/misra/standard-header-file-used-setjmph
 * @name RULE-21-4: The standard header file shall not be used <setjmp.h>
 * @description The use of features of '<setjmp.h>' may result in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-4
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class SetJmp extends Macro {
  SetJmp() {
    this.hasName("setjmp") and
    this.getFile().getAbsolutePath().matches("%setjmp.h")
  }
}

class LongJmp extends Function {
  LongJmp() {
    this.hasName("longjmp") and
    this.getFile().getAbsolutePath().matches("%setjmp.h")
  }
}

from Locatable use, Locatable feature, string name
where
  not isExcluded(use, BannedPackage::standardHeaderFileUsedSetjmphQuery()) and
  (
    exists(SetJmp setjmp |
      feature = setjmp and
      use = setjmp.getAnInvocation() and
      name = "setjmp"
    )
    or
    exists(LongJmp longjmp |
      feature = longjmp and
      use = longjmp.getACallToThisFunction() and
      name = "longjmp"
    )
  )
select use, "Use of $@.", feature, name
