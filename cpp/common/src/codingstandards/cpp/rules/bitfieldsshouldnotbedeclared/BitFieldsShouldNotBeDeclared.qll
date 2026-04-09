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

signature module BitFieldsShouldNotBeDeclaredConfigSig {
  Query getQuery();
}

module BitFieldsShouldNotBeDeclared<BitFieldsShouldNotBeDeclaredConfigSig Config> {
  query predicate problems(Element e, string message) {
    not isExcluded(e, Config::getQuery()) and message = "<replace with problem alert message for >"
  }
}
