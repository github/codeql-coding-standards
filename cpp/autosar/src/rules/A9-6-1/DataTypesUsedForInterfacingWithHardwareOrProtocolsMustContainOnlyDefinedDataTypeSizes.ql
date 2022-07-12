/**
 * @id cpp/autosar/data-types-used-for-interfacing-with-hardware-or-protocols-must-contain-only-defined-data-type-sizes
 * @name A9-6-1: Data types used for interfacing with hardware shall contain only members with types of defined sizes
 * @description To ensure reliable behavior, data types used for interfacing with hardware or
 *              conforming to communication protocols shall be trivial, standard-layout and only
 *              contain members of types with defined sizes.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a9-6-1
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.HardwareOrProtocolInterface
import codingstandards.cpp.ImplicitHardwareOrProtocolInterfaceClass

/*
 * For every class that is a hardware class:
 *
 * 1) the class or struct itself must be POD (Covered in `DataTypesUsedForInterfacingWithHardwareOrConformingToCommunicationProtocolsMustBeTrivialAndStandardLayout.ql`)
 *
 * 2) Furthermore, the class must consist of members that are a defined size. We report
 *   these issues on a field by field level.
 *
 * 3) A defined size is any type that:
 *    a) is a fixed size type
 *    b) it is enum BASED on a fixed size type
 *    c) is a POD type consisting of all fixed size types
 *
 * 4) Per this rule, if a class contains a Bit field, the class must be treated as a
 *   hardware interface class and thus subject to the same constraints. This is
 *   handled by `ImplicitHardwareInterfaceClass`, which pulls such classes into the
 *   parent abstract class `HardwareInterfaceClass`.
 */

from HardwareOrProtocolInterfaceClass c, Field f
where
  not isExcluded(c,
    ClassesPackage::dataTypesUsedForInterfacingWithHardwareOrProtocolsMustContainOnlyDefinedDataTypeSizesQuery()) and
  not isExcluded(f,
    ClassesPackage::dataTypesUsedForInterfacingWithHardwareOrProtocolsMustContainOnlyDefinedDataTypeSizesQuery()) and
  f = c.getAField() and
  not f.getType() instanceof DefinedSizeType
select f, "$@ Is a member of a hardware interface or protocol type but is not a fixed size.", f,
  f.getName()
