/**
 * Provides a library with a `problems` predicate for the following issue:
 * The basic numerical types of signed/unsigned char, int, short, long are not supposed
 * to be used. The specific-length types from <cstdint> header need be used instead.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.EncapsulatingFunctions
import codingstandards.cpp.BuiltInNumericTypes
import codingstandards.cpp.Type
import codingstandards.cpp.Operator

abstract class VariableWidthIntegerTypesUsedSharedQuery extends Query { }

Query getQuery() { result instanceof VariableWidthIntegerTypesUsedSharedQuery }

query predicate problems(Element e, string message) {
  not isExcluded(e, getQuery()) and
  exists(Type typeStrippedOfSpecifiers, Type rawType |
    typeStrippedOfSpecifiers = stripSpecifiers(rawType) and
    (
      typeStrippedOfSpecifiers instanceof BuiltInIntegerType or
      typeStrippedOfSpecifiers instanceof UnsignedCharType or
      typeStrippedOfSpecifiers instanceof SignedCharType
    )
  |
    exists(Variable v | v = e |
      v.getType() = rawType and
      not v instanceof ExcludedVariable and
      // Dont consider template instantiations because instantiations with
      // Fixed Width Types are recorded after stripping their typedef'd type,
      // thereby, causing false positives (#540).
      not v.isFromTemplateInstantiation(_) and
      //post-increment/post-decrement operators are required by the standard to have a dummy int parameter
      not v.(Parameter).getFunction() instanceof PostIncrementOperator and
      not v.(Parameter).getFunction() instanceof PostDecrementOperator and
      message = "Variable '" + v.getName() + "' has variable-width type."
    )
    or
    exists(Function f | f = e |
      f.getType() = rawType and
      not f instanceof ExcludedFunction and
      // Dont consider template instantiations because instantiations with
      // Fixed Width Types are recorded after stripping their typedef'd type,
      // thereby, causing false positives (#540).
      not f.isFromTemplateInstantiation(_) and
      message = "Function '" + f.getName() + "' has variable-width return type."
    )
  )
}
