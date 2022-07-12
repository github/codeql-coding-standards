import codingstandards.cpp.HardwareOrProtocolInterface

/**
 * Per A9-6-1, any class that uses bit fields should implicitly be considered
 * to be a hardware interface class since A9-6-2 permits usage of `BitField`
 * only for such classes.
 */
class ImplicitHardwareOrProtocolInterfaceClass extends HardwareOrProtocolInterfaceClass {
  ImplicitHardwareOrProtocolInterfaceClass() {
    exists(Field f | f = this.getAField() and f instanceof BitField)
  }
}
