/**
 * A library for addressing issues in bitwise operator modelling in our database schema.
 */

import cpp

/**
 * A binary bitwise assign operation, excluding += and -= on pointers, which seem to be erroneously
 * included.
 */
class AssignBitwiseOperationFixed extends AssignBitwiseOperation {
  AssignBitwiseOperationFixed() {
    // exclude += and -= on pointers, which seem to be erroneously included
    // in the database schema
    not this instanceof AssignPointerAddExpr and
    not this instanceof AssignPointerSubExpr
  }
}
