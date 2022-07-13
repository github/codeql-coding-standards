/**
 * @id cpp/autosar/template-constructor-overload-resolution
 * @name A14-5-1: A template constructor shall not participate in overload resolution for a single argument of the enclosing class type
 * @description Using a template constructor that participates in overload resolution against copy
 *              or move constructors makes the code more difficult to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a14-5-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * a `Constructor` with copy like signature and either as:
 * 1) a `TemplateFunction` where first param is the first template arg and rest are default
 * or
 * 2) a `Constructor` declared in a `TemplateClass` where first param is first template arg to the class
 * (and rest are default)
 */
class TemplateCopyLikeConstructor extends Constructor {
  string type;

  TemplateCopyLikeConstructor() {
    //can have many parameters but must be default value
    forall(int i | i > 0 and exists(getParameter(i)) | getParameter(i).hasInitializer()) and
    (
      this instanceof TemplateFunction and
      hasTemplatedCopySignature(this)
      or
      getDeclaringType() instanceof TemplateClass and
      this.getParameter(0).getUnspecifiedType().(LValueReferenceType).getBaseType() =
        getDeclaringType().getTemplateArgument(0)
    ) and
    type = "copy"
  }

  string getCond() { result = type }
}

/**
 * a `Constructor` with move like signature and either as:
 * 1) a `TemplateFunction` where first param is the first template arg and rest are default
 * or
 * 2) a `Constructor` declared in a `TemplateClass` where first param is first template arg to the class
 * (and rest are default)
 */
class TemplateMoveLikeConstructor extends Constructor {
  string type;

  TemplateMoveLikeConstructor() {
    //can have many parameters but must be default value
    forall(int i | i > 0 and exists(getParameter(i)) | getParameter(i).hasInitializer()) and
    (
      this instanceof TemplateFunction and
      hasTemplatedMoveSignature(this)
      or
      getDeclaringType() instanceof TemplateClass and
      this.getParameter(0).getUnspecifiedType().(RValueReferenceType).getBaseType() =
        getDeclaringType().getTemplateArgument(0)
    ) and
    type = "move"
  }

  string getCond() { result = type }
}

/**
 * checks for signature like: template <typename T> fun(T&)
 */
private predicate hasTemplatedCopySignature(MemberFunction f) {
  f.getParameter(0).getUnspecifiedType().(LValueReferenceType).getBaseType() =
    f.getTemplateArgument(0)
}

/**
 * checks for signature like: template <typename T> fun(T&&)
 */
private predicate hasTemplatedMoveSignature(MemberFunction f) {
  f.getParameter(0).getUnspecifiedType().(RValueReferenceType).getBaseType() =
    f.getTemplateArgument(0)
}

from Constructor c, string str
where
  not isExcluded(c, TemplatesPackage::templateConstructorOverloadResolutionQuery()) and
  (
    c instanceof TemplateMoveLikeConstructor and
    str = c.(TemplateMoveLikeConstructor).getCond()
    or
    c instanceof TemplateCopyLikeConstructor and
    str = c.(TemplateCopyLikeConstructor).getCond()
  ) and
  c.isFromUninstantiatedTemplate(_)
select c, "Template constructor looks like a " + str + " constructor."
