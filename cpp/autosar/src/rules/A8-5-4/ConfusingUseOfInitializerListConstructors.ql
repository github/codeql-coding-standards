/**
 * @id cpp/autosar/confusing-use-of-initializer-list-constructors
 * @name A8-5-4: Constructor may be confused with a constructor that accepts std::initializer_list
 * @description If a class has a user-declared constructor that takes a parameter of type
 *              std::initializer_list, then it shall be the only constructor apart from special
 *              member function constructors.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-5-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

class StdInitializerList extends Class {
  StdInitializerList() { hasQualifiedName("std", "initializer_list") }
}

/**
 * An _initializer-list constructor_ according to `[dcl.init.list]`.
 *
 * A `Constructor` where the first parameter refers to `std::initializer_list`, and any remaining
 * parameters have default arguments.
 */
class InitializerListConstructor extends Constructor {
  InitializerListConstructor() {
    // The first parameter is a `std::intializer_list` parameter
    exists(Type firstParamType | firstParamType = getParameter(0).getType() |
      // Either directly `std::initializer_list`
      firstParamType instanceof StdInitializerList
      or
      //A reference to `std::initializer_list`
      firstParamType.(ReferenceType).getBaseType().getUnspecifiedType() instanceof
        StdInitializerList
    ) and
    // All parameters other than the fi
    forall(Parameter other | other = getParameter([1 .. (getNumberOfParameters() - 1)]) |
      exists(other.getInitializer())
    )
  }
}

from Constructor c, InitializerListConstructor stdInitializerConstructor, string paramList
where
  not isExcluded(c, InitializationPackage::confusingUseOfInitializerListConstructorsQuery()) and
  // Not an initializer-list constructor
  not c instanceof InitializerListConstructor and
  // Constructor is not a special member function constructor
  not c instanceof CopyConstructor and
  not c instanceof MoveConstructor and
  not c.getNumberOfParameters() = 0 and // default constructor
  // And there is an initalizer-list constructor
  stdInitializerConstructor = c.getDeclaringType().getAConstructor() and
  // Determine the parameter type list of the constructor
  paramList =
    concat(string parameter | parameter = c.getAParameter().getType().getName() | parameter, ",")
select c,
  "The constructor " + c.getQualifiedName() + "(" + paramList +
    ") may be ignored in favour of $@ when using braced initialization.", stdInitializerConstructor,
  "the constructor accepting std::initializer_list"
