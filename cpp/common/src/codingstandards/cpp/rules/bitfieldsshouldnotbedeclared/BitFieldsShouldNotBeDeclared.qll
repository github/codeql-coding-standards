/**
 * Provides a configurable module BitFieldsShouldNotBeDeclared with a `problems` predicate
 * for the following issue:
 * The usage of bit-fields increases code complexity and certain aspects of bit-field
 * manipulation can be error prone and implementation defined. Hence a bit-field usage
 * is reserved only when interfacing to hardware or conformance to communication
 * protocols.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.HardwareOrProtocolInterface

signature module BitFieldsShouldNotBeDeclaredConfigSig {
  Query getQuery();
}

module BitFieldsShouldNotBeDeclared<BitFieldsShouldNotBeDeclaredConfigSig Config> {
  query predicate problems(BitField bf, Class c, string message) {
    /*
     * The condition that is allowed that is IF this is a bit-field, then it should be part of a class
     * that is flagged as a hardware or protocol class. To detect this we look for violations of that form.
     */

    not isExcluded(bf, Config::getQuery()) and
    not isExcluded(c, Config::getQuery()) and
    bf = c.getAField() and
    not c instanceof HardwareOrProtocolInterfaceClass and
    message = "Bit-field used within a class that is not a hardware or protocol class."
  }
}
