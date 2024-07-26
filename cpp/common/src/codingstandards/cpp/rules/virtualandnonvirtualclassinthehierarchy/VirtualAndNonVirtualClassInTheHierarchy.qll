/**
 * Provides a library with a `problems` predicate for the following issue:
 * An accessible base class shall not be both virtual and non-virtual in the same
 * hierarchy.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class VirtualAndNonVirtualClassInTheHierarchySharedQuery extends Query { }

Query getQuery() { result instanceof VirtualAndNonVirtualClassInTheHierarchySharedQuery }

query predicate problems(
  Class c3, string message, Class base, string base_string, ClassDerivation cd1, string cd1_string,
  Class c2, string c2_string
) {
  exists(Class c1, ClassDerivation cd2 |
    not isExcluded(c3, getQuery()) and
    // for each pair of classes, get all of their derivations
    cd1 = c1.getADerivation() and
    cd2 = c2.getADerivation() and
    // where they share the same base class
    base = cd1.getBaseClass() and
    base = cd2.getBaseClass() and
    // but one is virtual, and one is not, and the derivations are in different classes
    cd1.isVirtual() and
    not cd2.isVirtual() and
    // and there is some 'other class' that derives from both of these classes
    c3.derivesFrom*(c1) and
    c3.derivesFrom*(c2) and
    // and the base class is accessible from the 'other class'
    c3.getAMemberFunction().getEnclosingAccessHolder().canAccessClass(base, c3) and
    message = "Class inherits base class $@, which is derived virtual by $@ and non-virtual by $@." and
    base_string = base.getName() and
    cd1_string = cd1.getDerivedClass().toString() and
    c2_string = cd2.getDerivedClass().toString()
  )
}
