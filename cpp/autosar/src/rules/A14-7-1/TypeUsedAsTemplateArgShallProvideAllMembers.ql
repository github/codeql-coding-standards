/**
 * @id cpp/autosar/type-used-as-template-arg-shall-provide-all-members
 * @name A14-7-1: A type used as a template argument shall provide all members that are used by the template
 * @description Using template argument types that do not provide all members used can lead to
 *              compilation errors and can be difficult to diagnose.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a14-7-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * `Declaration` is declared in `Class` c or any of c's parents or templates.
 */
predicate belongsToClass(Declaration m, Class c) {
  m.getDeclaringType() = c
  or
  belongsToClass(m, c.getABaseClass())
  or
  exists(Class constructedFrom |
    c.isConstructedFrom(constructedFrom) and
    belongsToClass(m, constructedFrom)
  )
}

/**
 * `Literal` in `MemberFunction`
 * in uninstantiated `TemplateClass`
 * that represents a `Member` from the
 * `TemplateArg`
 */
class MemberNamedLiteral extends Literal {
  TemplateClass c;

  MemberNamedLiteral() {
    this.getEnclosingFunction() instanceof MemberFunction and
    this.getEnclosingFunction().isFromUninstantiatedTemplate(c) and
    this.getChild(_).(VariableAccess).getTarget().getType() = c.getATemplateArgument()
  }

  TemplateClass getTemplateClassThisIsFoundIn() { result = c }

  /**
   * used to check that `TemplateArgument` type
   * is in the matching position
   * (example if type is `D<T, X, Y...>`)
   */
  int getCalledMemberFunctionTypePosition() {
    exists(int i |
      result = i and
      this.getChild(_).(VariableAccess).getTarget().getType() = c.getTemplateArgument(i)
    )
  }
}

class Member extends Declaration {
  Member() {
    this instanceof MemberFunction or
    this instanceof MemberVariable
  }
}

from MemberNamedLiteral l, TemplateClass c, Class instArgType, Class instantiation
where
  not isExcluded(c, TemplatesPackage::typeUsedAsTemplateArgShallProvideAllMembersQuery()) and
  c = l.getTemplateClassThisIsFoundIn() and
  exists(int i |
    i = l.getCalledMemberFunctionTypePosition() and
    instantiation = c.getAnInstantiation() and
    instArgType = instantiation.getTemplateArgument(i) and
    not exists(Member m |
      belongsToClass(m, instArgType) and
      m.getName() = l.getValueText()
    )
  )
select instantiation,
  "Template instantiation " + instantiation.getName() +
    " uses template argument type $@ that does not declare required member $@.", instArgType,
  instArgType.getName(), l, l.getValueText()
