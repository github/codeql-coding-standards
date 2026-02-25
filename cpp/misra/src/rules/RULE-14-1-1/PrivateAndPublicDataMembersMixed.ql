/**
 * @id cpp/misra/private-and-public-data-members-mixed
 * @name RULE-14-1-1: Non-static data members should be either all private or all public
 * @description Mixing public and private data members in a class obfuscates the range of valid
 *              states allowable for that class.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-14-1-1
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from Class c, Field f
where
  not isExcluded(f, Classes2Package::privateAndPublicDataMembersMixedQuery()) and
  f = c.getAMember() and
  not f.isStatic() and
  (
    // Protected data members is not allowed.
    f.isProtected()
    or
    // Public and private data members cannot be mixed.
    exists(Field other |
      // Allow manual exclusion of 'other' field.
      not isExcluded(other, Classes2Package::privateAndPublicDataMembersMixedQuery()) and
      other = c.getAMember() and
      not other.isStatic() and
      other != f and
      (
        f.isPublic() and other.isPrivate()
        or
        f.isPrivate() and other.isPublic()
        or
        f.isProtected() and
        (other.isPublic() or other.isPrivate())
        or
        (f.isPublic() or f.isPrivate()) and
        other.isProtected()
      )
    )
  )
select f,
  "Non-static data member '" + f.getName() +
    "' has mixed access level with other data members in class '" + c.getName() + "'."
