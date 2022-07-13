/**
 * @id cpp/autosar/audit-possible-hardware-interface-due-to-bit-field-usage-in-data-type-definition
 * @name A9-6-2: (Audit) Possible hardware interface due to bit-field usage in data type definition
 * @description The usage of bit-fields increases code complexity and certain aspects of bit-field
 *              manipulation can be error prone and implementation defined. Hence a bit-field usage
 *              is reserved only when interfacing to hardware or conformance to communication
 *              protocols.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a9-6-2
 *       external/autosar/audit
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/*
 * The purpose of this query is strictly as an audit query for producing a list of all definitions use bit-fields.
 */

from BitField bf
where
  not isExcluded(bf,
    RepresentationPackage::auditPossibleHardwareInterfaceDueToBitFieldUsageInDataTypeDefinitionQuery())
select bf, "Usage of bit-field in data type definition."
