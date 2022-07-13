/**
 * @id cpp/autosar/operation-may-not-null-terminate-c-style-string-autosar
 * @name A27-0-2: A C-style string shall guarantee sufficient space for data and the null terminator
 * @description Certain operations may not null terminate CStyle strings which may cause
 *              unpredictable behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a27-0-2
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.operationmaynotnullterminatecstylestring.OperationMayNotNullTerminateCStyleString

class OperationMayNotNullTerminateCStyleStringAutosarQuery extends OperationMayNotNullTerminateCStyleStringSharedQuery {
  OperationMayNotNullTerminateCStyleStringAutosarQuery() {
    this = StringsPackage::operationMayNotNullTerminateCStyleStringAutosarQuery()
  }
}
