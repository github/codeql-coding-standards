import cpp
import Expr
import codingstandards.cpp.AccessPath

/**
 * A constructor initializer that initializes a base type.
 *
 * Note: this differs from the `ConstructorBaseInit` class in `import cpp` in that it holds for
 * initializers where the target constructors may not exist/may not have been generated. For
 * example, in:
 * ```
 * class Base {};
 * class Derived : public Base {
 * public:
 *  Derived() {}
 *  Derived(int i) : Base() {} // <---- this Base() call
 * ```
 * The highlighted `Base` init is not a `ConstructorBaseInit`, because it's not a constructor call,
 * because the `Base()` constructor is not represented in the database. It is, however, represented
 * by this class.
 *
 * It also differs in that it does not consider _delegating constructors_ to be initializers of
 * base classes.
 *
 * This class provides:
 *  - `getInitializedClass()` - to get the initialized class
 *  - `getParentConstructor()` - to get the constructor that is the parent of this initialization
 */
class ConstructorBaseClassInit extends ConstructorInit {
  ConstructorBaseClassInit() {
    this instanceof @ctordirectinit
    or
    this instanceof @ctorvirtualinit
  }

  /**
   * Gets the `Class` being initialized by this base initializer
   */
  Class getInitializedClass() {
    result = this.(ConstructorBaseInit).getTarget().getDeclaringType()
    or
    result = getType()
  }
}

/** An assignment to a field in the copy constructor where the assignment is a direct copy of the same field in the provided class instance. */
class CopyConstructorFieldCopyAssign extends AnyAssignExpr {
  CopyConstructorFieldCopyAssign() {
    exists(CopyConstructor cc | this = getAMemberCopyAssignment(cc))
  }
}

/** An assignment to a field in the move constructor where the assignment is a direct copy or move of the same field in the provided class instance. */
class MoveConstructorFieldCopyAssign extends AnyAssignExpr {
  MoveConstructorFieldCopyAssign() {
    exists(MoveConstructor mc | this = getAMemberMoveAssignment(mc))
  }
}

/** Re-itialization of a field of a class instance passed to a move constructor. */
class MoveConstructorFieldReset extends AnyAssignExpr {
  MoveConstructorFieldReset() {
    exists(MoveConstructor mc, Parameter other |
      mc.getAParameter() = other and
      other.getUnspecifiedType().(RValueReferenceType).getBaseType().getUnspecifiedType() =
        mc.getDeclaringType() and
      this.getEnclosingFunction() = mc and
      other = this.getLValue().(ReferenceFieldAccess).getQualifier().(VariableAccess).getTarget()
    )
  }

  VariableAccess getLAccess() { result = this.getLValue() }
}

/** A constructor field init in a copy constructor that initializes the field with the value of the same field from the passed class instance. */
class CopyConstructorFieldCopyInit extends ConstructorFieldInit {
  CopyConstructorFieldCopyInit() {
    exists(CopyConstructor cc, Parameter other |
      cc = this.getEnclosingFunction() and
      cc.getAParameter() = other and
      other.getUnspecifiedType().(LValueReferenceType).getBaseType().getUnspecifiedType() =
        cc.getDeclaringType() and
      (
        this.getExpr().(VariableAccess).getTarget() = this.getTarget()
        or
        this.getExpr().(ConstructorCall).getArgument(0).(VariableAccess).getTarget() =
          this.getTarget()
      )
    )
  }
}

/** A constructor field init in a move constructor that initializes the field with the value or moving of the same field from the passed class instance. */
class MoveConstructorFieldCopyInit extends ConstructorFieldInit {
  MoveConstructorFieldCopyInit() {
    exists(MoveConstructor mc, Parameter other |
      mc = this.getEnclosingFunction() and
      mc.getAParameter() = other and
      other.getUnspecifiedType().(RValueReferenceType).getBaseType().getUnspecifiedType() =
        mc.getDeclaringType() and
      (
        exists(VariableAccess va | this.getExpr() = va |
          va.getQualifier().(VariableAccess).getTarget() = other and
          this.getTarget() = va.getTarget()
        )
        or
        exists(FunctionCall move, VariableAccess va |
          // The initializer is either a direct move of a ptr or move constructor call for classes.
          (this.getExpr() = move or this.getExpr().(ConstructorCall).getArgument(0) = move) and
          move.getTarget().hasQualifiedName("std", "move") and
          va = move.getAnArgument()
        |
          va.getQualifier().(VariableAccess).getTarget() = other and
          this.getTarget() = va.getTarget()
        )
      )
    )
  }
}

class UserCopyConstructor extends CopyConstructor {
  UserCopyConstructor() { not this.isCompilerGenerated() }
}

class UserMoveConstructor extends MoveConstructor {
  UserMoveConstructor() { not this.isCompilerGenerated() }
}
