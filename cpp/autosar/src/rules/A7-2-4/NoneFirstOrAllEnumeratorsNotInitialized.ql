/**
 * @id cpp/autosar/none-first-or-all-enumerators-not-initialized
 * @name A7-2-4: In an enumeration, either (1) none, (2) the first or (3) all enumerators shall be initialized
 * @description Explicit initialization of only some enumerators in an enumeration, and relying on
 *              compiler to initialize the remaining ones, may lead to developer‘s confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-2-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

// Note that the queries below make use of `fromSource` -- this tells us that
// the initializer in fact was set by the user, and not the compiler, which is
// the requirement in this case.
predicate eachElementHasInitializer(Enum e) {
  forall(EnumConstant ec | ec = e.getAnEnumConstant() | ec.getInitializer().fromSource())
}

predicate noElementsHaveAnInitializer(Enum e) {
  not exists(EnumConstant ec |
    ec = e.getAnEnumConstant() and
    ec.getInitializer().fromSource()
  )
}

predicate onlyTheFirstElementHasAnInitializer(Enum e) {
  // the first one has an initializer
  e.getEnumConstant(0).getInitializer().fromSource() and
  // and there are no other enums (other than the first one)
  // that have an initializer
  forall(EnumConstant ec |
    ec = e.getAnEnumConstant() and
    not ec = e.getEnumConstant(0)
  |
    not ec.getInitializer().fromSource()
  )
}

from Enum e
where
  not isExcluded(e, DeclarationsPackage::noneFirstOrAllEnumeratorsNotInitializedQuery()) and
  not (
    eachElementHasInitializer(e)
    or
    noElementsHaveAnInitializer(e)
    or
    onlyTheFirstElementHasAnInitializer(e)
  )
select e,
  "Neither none, the first, or all enumerated constants are initialized in this enumeration."
