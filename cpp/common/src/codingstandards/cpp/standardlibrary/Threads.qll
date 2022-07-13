/** Provides a library modeling `std::thread`. */

import cpp

/** The `std::thread` class. */
class StdThread extends Class {
  StdThread() { hasQualifiedName("std", "thread") }
}

/** A destructor call for a `std::thread` object. */
class StdThreadDestructorCall extends DestructorCall {
  StdThreadDestructorCall() { getTarget().hasQualifiedName("std", "thread", "~thread") }
}

/** A move assignment operation for `std:thread`. */
class StdThreadMoveAssignmentCall extends Call {
  StdThreadMoveAssignmentCall() {
    getTarget().(MoveAssignmentOperator).getDeclaringType().hasQualifiedName("std", "thread")
  }
}

/** A call to `std::thread::join` */
class StdThreadJoinCall extends FunctionCall {
  StdThreadJoinCall() { getTarget().hasQualifiedName("std", "thread", "join") }
}

/** A call to `std::thread::detach` */
class StdThreadDetachCall extends FunctionCall {
  StdThreadDetachCall() { getTarget().hasQualifiedName("std", "thread", "detach") }
}

/** A call to `std::thread::swap` */
class StdThreadSwapCall extends FunctionCall {
  StdThreadSwapCall() { getTarget().hasQualifiedName("std", "thread", "swap") }
}
