/**
 * @id cpp/misra/invalid-special-member-functions-on-class
 * @name RULE-15-0-1: Special member functions shall be provided appropriately
 * @description Correct overrides of special member functions ensure proper resource management, and
 *              prevents incorrect compiler-generated functions from being used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Class
import qtil.Qtil

newtype TCategory = TCategoryImpl(string name, boolean moveConstructible, boolean copyConstructible, boolean moveAssignable, boolean copyAssignable) {
  name = "unmovable" and moveConstructible = false and copyConstructible = false and moveAssignable = false and copyAssignable = false
  or
  name = "move-only and unassignable" and moveConstructible = true and moveAssignable = false and copyConstructible = false and copyAssignable = false
  or
  name = "move-only and assignable" and moveConstructible = true and moveAssignable = true and copyConstructible = false and copyAssignable = false
  or
  name = "copy-enabled and unassignable" and moveConstructible = true and moveAssignable = false and copyConstructible = true and copyAssignable = moveAssignable
  or
  name = "copy-enabled and assignable" and moveConstructible = true and moveAssignable = true and copyConstructible = true and copyAssignable = moveAssignable
}


signature predicate boolClassProp(Class c);
module ToBoolean<boolClassProp/1 prop> {
  boolean get(Class c) {
    prop(c) and
    result = true
    or
    not prop(c) and
    result = false
  }
}

class Category extends TCategory {
  string getName() { this = TCategoryImpl(result, _, _, _, _) }

  string toString() { result = getName() }

  boolean moveConstructible() { this = TCategoryImpl(_, result, _, _, _) }

  boolean copyConstructible() { this = TCategoryImpl(_, _, result, _, _) }

  boolean moveAssignable() { this = TCategoryImpl(_, _, _, result, _) }

  boolean copyAssignable() { this = TCategoryImpl(_, _, _, _, result) }

  predicate apparentMatch(Class c) {
    this = rank[1](Category cat | any() | cat order by count(string err | err = cat.mismatchError(c)))
    //if isCopyConstructible(c) then getName().matches("copy-enabled%")
    //else if not isMoveConstructible(c) then getName() = "unmovable"
    //else getName().matches("move-only%")
  }

  predicate match(Class c) {
    moveConstructible() = ToBoolean<isMoveConstructible/1>::get(c) and
    copyConstructible() = ToBoolean<isCopyConstructible/1>::get(c) and
    moveAssignable() = ToBoolean<isMoveAssignable/1>::get(c) and
    copyAssignable() = ToBoolean<isCopyAssignable/1>::get(c)
  }

  bindingset[a, b, name]
  private string compatibleString(boolean a, boolean b, string name) {
    a = true and b = false and result = "is not " + name
    or
    a = false and b = true and result = "is " + name
  }

  string mismatchError(Class c) {
    result = compatibleString(moveConstructible(), ToBoolean<isMoveConstructible/1>::get(c), "move constructible")
    or
    result = compatibleString(copyConstructible(), ToBoolean<isCopyConstructible/1>::get(c), "copy constructible")
    or
    result = compatibleString(moveAssignable(), ToBoolean<isMoveAssignable/1>::get(c), "move assignable")
    or
    result = compatibleString(copyAssignable(), ToBoolean<isCopyAssignable/1>::get(c), "copy assignable")
  }
}

string describe(SpecialMemberFunction f) {
  f instanceof CopyConstructor and result = "copy constructor"
  or
  f instanceof MoveConstructor and result = "move constructor"
  or
  f instanceof CopyAssignmentOperator and result = "copy assignment operator"
  or
  f instanceof MoveAssignmentOperator and result = "move assignment operator"
}

query predicate specials(SpecialMemberFunction f, string x, boolean deleted) { x = describe(f) and (if f.isDeleted() then deleted = true else deleted = false) }

query predicate ctors(Constructor c, int params, boolean deleted) { params = c.getNumberOfParameters() and (if c.isDeleted() then deleted = true else deleted = false) }

query predicate calls(Call c, Function f) { f = c.getTarget() }

from Class cls, Category cat
where
  not isExcluded(cls, Classes2Package::invalidSpecialMemberFunctionsOnClassQuery()) and
  cat.apparentMatch(cls) and
  not any(Category c).match(cls)
select cls, "Class " + cls.getName() + " appears to be " + cat.getName() + ", but " + cat.mismatchError(cls)
