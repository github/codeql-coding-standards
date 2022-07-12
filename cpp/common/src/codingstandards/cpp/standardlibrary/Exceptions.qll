/** Provides a library for exceptions classes provided by the C++ standard library. */

import cpp

/** The `std::exception` class. */
class StdException extends Class {
  StdException() { hasQualifiedName("std", "exception") }
}

/** The `std::bad_cast` class. */
class StdBadCast extends Class {
  StdBadCast() { hasQualifiedName("std", "bad_cast") }
}

/** The `std::bad_typeid` class. */
class StdBadTypeId extends Class {
  StdBadTypeId() { hasQualifiedName("std", "bad_typeid") }
}

/** The `std::bad_array_new_length` class. */
class StdBadArrayNewLength extends Class {
  StdBadArrayNewLength() { hasQualifiedName("std", "bad_array_new_length") }
}

class StdBadAlloc extends Class {
  StdBadAlloc() { hasQualifiedName("std", "bad_alloc") }
}

/** The `std::nested_exception` class. */
module StdNestedException {
  class RethrowNestedCall extends FunctionCall {
    RethrowNestedCall() {
      getTarget().hasQualifiedName("std", "nested_exception", "rethrow_nested")
    }
  }
}

/** The `std::terminate` function. */
class StdTerminate extends Function {
  StdTerminate() { hasQualifiedName("std", "terminate") }
}
