/**
 * @id cpp/autosar/auto-specifier-not-used-appropriately-in-function-definition
 * @name A7-1-5: Within a function definition the auto specifier may only be used to declare a function template using trailing return type syntax
 * @description The auto specifier shall not be used apart from following cases: (1) to declare that
 *              a variable has the same type as return type of a function call, (2) to declare that
 *              a variable has the same type as initializer of non-fundamental type, (3) to declare
 *              parameters of a generic lambda expression, (4) to declare a function template using
 *              trailing return type syntax.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-5
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/*
 * This query works because when the `decltype()` syntax is used for the type of the function
 * Function.getType/getUnspecifiedType is unknown, which automatically filters these queries out.
 *
 * At current, there are some limitations that prevent all cases from being caught. This is because the following
 * two definitions are different from an autosar standpoint, but parsed the same:
 *
 * ```auto f5(int a, int b) -> int { return a + b; }```
 *
 * and
 *
 * ```int f5(int a, int b) { return a + b; }```
 *
 * Because of this, the following example will fail to be caught:
 *
 * ```auto f5(int a, int b) -> int { return a + b; } // NON_COMPLIANT because not a template```
 */

class AutoFunction extends Function {
  AutoFunction() {
    // `AutoType` only appears on decl entries - the function has the "deduced" type
    getADeclarationEntry().getUnspecifiedType() instanceof AutoType
    or
    // Since functions defined like this:
    // ```int f6(int a, int b) -> decltype(a + b)``` are illegal (repeating int in the return type), we can deduce that if
    // `decltype` was used that it is in fact a use of auto. If the function does not also appear in a templated function
    // we can deduce that this is an invalid usage.
    getType() instanceof Decltype
  }
}

from AutoFunction f
where
  not isExcluded(f,
    DeclarationsPackage::autoSpecifierNotUsedAppropriatelyInFunctionDefinitionQuery()) and
  not f instanceof TemplateFunction and
  not f instanceof FunctionTemplateInstantiation and
  not f.isFromUninstantiatedTemplate(_)
select f,
  "Use of auto keyword in definition of function " + f.getName() +
    " that does not have a trailing return type."
