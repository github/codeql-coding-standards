/**
 * Provides a library with a `problems` predicate for the following issue:
 * A class shall only define an initializer-list constructor when it is the only
 * constructor.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class InitializerListConstructorIsTheOnlyConstructorSharedQuery extends Query { }

Query getQuery() { result instanceof InitializerListConstructorIsTheOnlyConstructorSharedQuery }

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

query predicate problems(
  Constructor c, string message, InitializerListConstructor stdInitializerConstructor,
  string stdInitializerConstructor_string
) {
  exists(string paramList |
    not isExcluded(c, getQuery()) and
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
      concat(string parameter | parameter = c.getAParameter().getType().getName() | parameter, ",") and
    message =
      "The constructor " + c.getQualifiedName() + "(" + paramList +
        ") may be ignored in favour of $@ when using braced initialization." and
    stdInitializerConstructor_string = "the constructor accepting std::initializer_list"
  )
}
