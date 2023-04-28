/**
 * @id c/misra/standard-header-file-used-setjmph
 * @name RULE-21-4: The standard header file shall not be used 'setjmp.h'
 * @description The use of features of 'setjmp.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-4
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

abstract class Jmp extends Locatable {
  string name;

  Jmp() {
    this.getFile().getAbsolutePath().matches("%setjmp.h") and
    name = [this.(Macro).getName(), this.(Function).getName()]
  }

  Locatable getAnInvocation() {
    result = this.(Macro).getAnInvocation() or
    result = this.(Function).getACallToThisFunction()
  }

  string getName() { result = name }
}

class SetJmp extends Jmp {
  SetJmp() {
    name = "setjmp" and
    this.(Macro).getName() = name
  }
}

class LongJmp extends Jmp {
  LongJmp() {
    name = "longjmp" and
    [this.(Macro).getName(), this.(Function).getName()] = name
  }
}

from Locatable use, string name
where
  not isExcluded(use, BannedPackage::standardHeaderFileUsedSetjmphQuery()) and
  exists(Jmp jmp |
    use = jmp.getAnInvocation() and
    name = jmp.getName()
  )
select use, "Use of " + name + "."
