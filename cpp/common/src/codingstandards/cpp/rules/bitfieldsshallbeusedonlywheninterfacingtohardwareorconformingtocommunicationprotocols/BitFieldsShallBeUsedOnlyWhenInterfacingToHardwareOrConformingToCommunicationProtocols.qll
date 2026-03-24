/**
 * Provides a configurable module BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocols with a `problems` predicate
 * for the following issue:
 * The exact layout and the order of bits resulting from bit-fields in a struct is
 * implementation-defined and therefore not portable.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

signature module BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocolsConfigSig
{
  Query getQuery();
}

module BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocols<
  BitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocolsConfigSig Config>
{
  query predicate problems(Element e, string message) {
    not isExcluded(e, Config::getQuery()) and message = "<replace with problem alert message for >"
  }
}
