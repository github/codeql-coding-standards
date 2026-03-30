import cpp
import codingstandards.cpp.ast.Catch
import codingstandards.cpp.exceptions.ExceptionFlow

/**
 * A catch block which is shadowed by an earlier catch block for a base type.
 *
 * For example:
 *
 * ```cpp
 * class Base { };
 * class Derived : public Base { };
 *
 * try {
 *   // ...
 * } catch (const Base& b) { // This catch block shadows the next one
 *   // Handle Base
 * } catch (const Derived& d) { // This catch block is shadowed
 *   // Handle Derived
 * }
 * ```
 */
class ShadowedCatchBlock extends CatchBlock {
  CatchBlock cbBase;
  Class baseType;
  Class derivedType;

  ShadowedCatchBlock() {
    cbBase = getEarlierCatchBlock(this) and
    baseType = simplifyHandlerType(cbBase.getParameter().getType()) and
    derivedType = simplifyHandlerType(this.getParameter().getType()) and
    baseType.getADerivedClass*() = derivedType
  }

  /**
   * Get the earlier catch block which shadows this catch block.
   */
  CatchBlock getShadowingBlock() { result = cbBase }

  /**
   * Get the type of this catch block's derived class whose catch block is shadowed by an earlier
   * catch block.
   */
  Class getShadowedType() { result = derivedType }

  /**
   * Get the type of the base class whose catch block precedes, and thus shadows, this catch block.
   */
  Class getShadowingType() { result = baseType }
}
