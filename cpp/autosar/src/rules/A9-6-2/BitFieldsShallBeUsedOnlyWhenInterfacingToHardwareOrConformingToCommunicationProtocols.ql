/**
 * @id cpp/autosar/bit-fields-shall-be-used-only-when-interfacing-to-hardware-or-conforming-to-communication-protocols
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
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.HardwareOrProtocolInterface

/*
 * The condition that is allowed that is IF this is a bit-field, then it should be part of a class
 * that is flagged as a hardware or protocol class. To detect this we look for violations of that form.
 */

from BitField bf, Class c
where
  not isExcluded(bf,
    RepresentationPackage::bitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocolsQuery()) and
  not isExcluded(c,
    RepresentationPackage::bitFieldsShallBeUsedOnlyWhenInterfacingToHardwareOrConformingToCommunicationProtocolsQuery()) and
  bf = c.getAField() and
  not c instanceof HardwareOrProtocolInterfaceClass
select bf, "Bit-field used within a class that is not a hardware or protocol class."
