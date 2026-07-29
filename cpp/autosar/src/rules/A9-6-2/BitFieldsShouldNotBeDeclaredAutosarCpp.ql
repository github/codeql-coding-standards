/**
 * @id cpp/autosar/bit-fields-should-not-be-declared-autosar-cpp
 * @name A9-6-2: Bit-fields shall be used only when interfacing to hardware or conforming to communication protocols
 * @description The usage of bit-fields increases code complexity and certain aspects of bit-field
 *              manipulation can be error prone and implementation defined. Hence a bit-field usage
 *              is reserved only when interfacing to hardware or conformance to communication
 *              protocols.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a9-6-2
 *       maintainability
 *       portability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.bitfieldsshouldnotbedeclared.BitFieldsShouldNotBeDeclared

module BitFieldsShouldNotBeDeclaredAutosarCppConfig implements BitFieldsShouldNotBeDeclaredConfigSig
{
  Query getQuery() { result = RepresentationPackage::bitFieldsShouldNotBeDeclaredAutosarCppQuery() }
}

import BitFieldsShouldNotBeDeclared<BitFieldsShouldNotBeDeclaredAutosarCppConfig>
