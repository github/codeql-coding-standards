/**
 * @id cpp/autosar/cv-qualifiers-not-placed-on-the-right-hand-side
 * @name A7-1-3: CV-qualifiers shall be placed on the right hand side of the type that is a typedef or a using name
 * @description Using `const`/`volatile` qualifiers on the left hand side of types that are
 *              `typedef`s or `using` names makes it harder to understand what the qualifier applies
 *              to.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a7-1-3
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * Holds if declaration `e` using a `TypedefType` is CV-qualified
 *
 * For example, given `using intconstptr = int * const`:
 * the predicate holds for `const/volatile intconstptr ptr1`, but not for `intconstptr ptr2`
 */
predicate containsExtraSpecifiers(VariableDeclarationEntry e) {
  e.getType().toString().matches("const %") or
  e.getType().toString().matches("volatile %")
}

// DeclStmts that have a TypedefType name use (ie TypeMention) in them
//AND TypeMention.getStartColumn() - DeclStmt.getStartColumn() > len(const)
//AND the declared thing contains one of these "extra" specifiers in the DeclarationEntry Location
from VariableDeclarationEntry e, TypedefType t, TypeMention tm
where
  not isExcluded(e, ConstPackage::cvQualifiersNotPlacedOnTheRightHandSideQuery()) and
  containsExtraSpecifiers(e) and
  exists(string filepath, int startline |
    e.getLocation().hasLocationInfo(filepath, startline, _, _, _) and
    tm.getLocation().hasLocationInfo(filepath, startline, _, _, _) and
    e = t.getATypeNameUse() and
    tm.getMentionedType() = t and
    exists(DeclStmt s |
      s.getDeclarationEntry(_) = e and
      //const could fit in there
      tm.getLocation().getStartColumn() - s.getLocation().getStartColumn() > 5
      //volatile could fit in there
      //but the above condition subsumes this one
      //l.getStartColumn() - tm.getLocation().getStartColumn() > 8
    )
  )
select e,
  "There is possibly a const or volatile specifier on the left hand side of typedef name $@.", t,
  t.getName()
