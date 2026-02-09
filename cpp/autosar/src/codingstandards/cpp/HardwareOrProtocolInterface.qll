import codingstandards.cpp.autosar
import codingstandards.cpp.CommonTypes as CommonTypes

abstract class HardwareOrProtocolInterfaceClass extends Class { }

class HardwareOrProtocolInterfaceComment extends Comment {
  HardwareOrProtocolInterfaceComment() {
    exists(getContents().regexpFind("(?m)^\\s*(//|\\*)\\s*@HardwareOrProtocolInterface\\s*$", _, _))
  }
}

class AnnotatedHardwareOrProtocolInterfaceClass extends HardwareOrProtocolInterfaceClass {
  AnnotatedHardwareOrProtocolInterfaceClass() {
    exists(HardwareOrProtocolInterfaceComment c |
      c.getCommentedElement() = this.getADeclarationEntry()
    )
  }
}

/*
 * A defined size type is one which it is either:
 *
 * a) is a fixed size type
 * b) is enum based on a fixed size type
 * c) is a POD type consisting of all DefinedSizeType types
 */

class DefinedSizeType extends Type {
  DefinedSizeType() {
    this.(TypedefType).getBaseType() instanceof DefinedSizeType
    or
    this.(SpecifiedType).getBaseType() instanceof DefinedSizeType
    or
    this instanceof CommonTypes::FixedWidthIntegralType
    or
    this instanceof CommonTypes::FixedWidthEnumType
    or
    this instanceof DefinedSizeClass
  }
}

class DefinedSizeClass extends Class {
  DefinedSizeClass() {
    this.isPod() and
    forall(Field f | f = this.getAField() | f.getType() instanceof DefinedSizeType)
  }
}
