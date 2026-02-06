/**
 * @id cpp/misra/member-specifiers-not-used-appropriately
 * @name RULE-13-3-1: User-declared member functions shall use the virtual, override and final specifiers appropriately
 * @description Appropriate use of specifiers on member functions more clearly indicate the
 *              intention of the function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-13-3-1
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from MemberFunction f, string message
where
  not isExcluded(f, Classes2Package::memberSpecifiersNotUsedAppropriatelyQuery()) and
  (
    // Case 1: Specifiers incompatible with explicitly virtual
    f.isDeclaredVirtual() and
    exists(Specifier s |
      s = f.getASpecifier() and
      s.getName() = ["final", "override"] and
      message =
        "Member function '" + f.getName() + "' uses redundant 'virtual' and '" + s.getName() +
          "' specifiers together."
    )
    or
    // Case 2: Redundant 'virtual' specifier
    f.overrides(_) and
    f.isDeclaredVirtual() and
    message =
      "Member function '" + f.getName() +
        "' overrides a base function but uses 'virtual' specifier."
    or
    // Case 3: both 'override' and 'final' specifiers on an overridden virtual function
    f.isVirtual() and
    not f.isDeclaredVirtual() and
    f.isOverride() and
    f.isFinal() and
    message =
      "Member function '" + f.getName() +
        "' uses redundant 'override' and 'final' specifiers together."
    or
    // Case 5: overrides a virtual function but has no override or final specifier
    f.overrides(_) and
    not f.isDeclaredVirtual() and
    not f.isOverride() and
    not f.isFinal() and
    message =
      "Member function '" + f.getName() +
        "' overrides a base function but lacks 'override' or 'final' specifier."
  )
select f, message
