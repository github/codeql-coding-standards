/**
 * @id c/misra/typedef-name-not-unique
 * @name RULE-5-6: A typedef name shall be a unique identifier
 * @description Reusing a typedef name compared to the name of any other identifier can cause
 *              confusion and make code harder to read.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-6
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

//exception cases additional to rule description
class InterestingIdentifiers extends Declaration {
  InterestingIdentifiers() {
    not this.isFromTemplateInstantiation(_) and
    not this.isFromUninstantiatedTemplate(_) and
    not this instanceof TemplateParameter and
    not this.hasDeclaringType() and
    not this instanceof Operator and
    not this.hasName("main") and
    exists(this.getADeclarationLocation())
  }
}

from TypedefType t, InterestingIdentifiers d
where
  not isExcluded(t, Declarations3Package::typedefNameNotUniqueQuery()) and
  not isExcluded(d, Declarations3Package::typedefNameNotUniqueQuery()) and
  not t.getADeclarationLocation() = d.getADeclarationLocation() and
  t.getName() = d.getName() and
  //exception cases
  not d.(Struct).getName() = t.getBaseType().toString() and
  not d.(Enum).getName() = t.getBaseType().toString()
select t, "Typedef name is nonunique compared to $@.", d, d.getName()
