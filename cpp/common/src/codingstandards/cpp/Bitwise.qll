/**
 * A library for addressing issues in bitwise operator modelling in our database schema.
 */

private import cpp as cpp

module Bitwise {
  /**
   * A binary bitwise assign operation, excluding += and -= on pointers, which seem to be erroneously
   * included.
   */
  class AssignBitwiseOperation extends cpp::AssignBitwiseOperation {
    AssignBitwiseOperation() {
      // exclude += and -= on pointers, which seem to be erroneously included
      // in the database schema
      not this instanceof cpp::AssignPointerAddExpr and
      not this instanceof cpp::AssignPointerSubExpr
    }
  }
}
