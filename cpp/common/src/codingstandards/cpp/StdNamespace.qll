import cpp

/**
 * A class that models the `std` namespace and its inline children
 * (e.g. `std::_V2` `std::__cxx11` and `std::__1`)
 */
class StdNS extends Namespace {
  StdNS() {
    this instanceof StdNamespace
    or
    this.isInline() and
    this.getParentNamespace() instanceof StdNS
  }
}
