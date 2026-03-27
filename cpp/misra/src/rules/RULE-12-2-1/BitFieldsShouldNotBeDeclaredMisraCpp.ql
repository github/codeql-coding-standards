/**
 * @id cpp/misra/bit-fields-should-not-be-declared-misra-cpp
 * @name RULE-12-2-1: Bit-fields should not be declared
 * @description The exact layout and the order of bits resulting from bit-fields in a struct is
 *              implementation-defined and therefore not portable.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.bitfieldsshallbeusedonlywheninterfacingtohardwareorconformingtocommunicationprotocols.BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocols

module BitFieldsShouldNotBeDeclaredMisraCppConfig implements
  BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocolsConfigSig
{
  Query getQuery() { result = Banned5Package::bitFieldsShouldNotBeDeclaredMisraCppQuery() }
}

import BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocols<BitFieldsShouldNotBeDeclaredMisraCppConfig>
