/**
 * A module including enhancements to the standard library predicates and classes for working with
 * `AggregateLiteral`s.
 *
 * This primarily provides predicates for working with aggregate literals which are only partially
 * initialized. For example:
 * ```
 * struct Foo {
 *   int m_i1;
 *   int m_i2;
 *   struct {
 *     int m_s1_i1;
 *     int m_s1_i2;
 *   } m_s1;
 * };
 *
 * Foo f { 1, 2 }; // Missing initializer for m_s1;
 * ```
 *
 * The `AggregateLiteral` class provides a predicate `isValueInitialized` to identify those
 * elements which are not explicitly initialized. Unfortunately, it is broken in some cases,
 * incorrectly reporting that implict value initialized fields are not value initialized.
 *
 * The fundamental problem is that when the extractor sometimes populates children for implicit
 * value initialized children of aggregate literals, and sometimes does not. It appears to be that
 * it generates children if there is at least one constructor call made.
 *
 * This module worksaround this limitation by using locations to determine which children are value
 * initialized.
 *
 * In addition, it provides predicates and classes for identifying certain special kinds of
 * aggregate literal:
 *  - Implicit (where the compiler added the braces)
 *  - Partially initialized
 *  - Leading "zero" initialized
 *  - Blank initialized.
 */

import cpp

/**
 * Gets the previous intializer expression for the given `AggregateLiteral`, at the given `index`.
 */
Expr getPreviousExpr(AggregateLiteral parent, int index) {
  parent.hasChild(_, index) and
  (
    // The previous expression is the previous sibling
    result = parent.getChild(index - 1)
    or
    // This is the first element in an `AggregateLiteral`, so look for the predecessor in the
    // parent, or use the parent itself if this is a top-level cal in an initializer.
    index = 0 and
    exists(Expr grandParent, int grandParentIndex |
      grandParent.getChild(grandParentIndex) = parent and
      result = grandParent.getChild(grandParentIndex - 1)
    )
    or
    // parent is the top-level aggregate literal
    not parent.getParent() instanceof AggregateLiteral and
    result = parent
  )
}

module ArrayAggregateLiterals {
  /** Holds if the array `index` on `cal` is value initialized. */
  bindingset[index]
  predicate isValueInitialized(ArrayAggregateLiteral cal, int index) {
    (
      // The extractor will identify whether an index is value initialized by whether it has a empty
      // element expression. If that's the case, it's definitely value intialized
      cal.isValueInitialized(index)
      or
      // Unfortunately, in some cases the extractor will still generate an initializer for an array,
      // even if it's value initialized (typically because at least one field, or nested field, of
      // this cal is value initialized to something not zero - usually a constructor call or similar).
      //
      // To address this case, we try to find a `compilerGeneratedVal`, which is a value which has the
      // same _location_ as the previous initializer expression in the aggregate.
      exists(Expr compilerGeneratedVal, Expr previousExpr |
        // Identify the candidate expression which may be compiler generated
        compilerGeneratedVal = cal.getChild(index) and
        // Find the previous expression for this aggregate literal
        previousExpr = getPreviousExpr(cal, index)
      |
        // The aggregate itself not be compiler generated, or in a macro expansion, otherwise our line numbers will be off
        not cal.isCompilerGenerated() and
        not cal.isInMacroExpansion() and
        // Ignore cases where the compilerGenerated value is a variable access targeting
        // a parameter, as these are generated from variadic templates
        not compilerGeneratedVal.(VariableAccess).getTarget() instanceof Parameter and
        exists(string filepath, int startline, int startcolumn, int endline, int endcolumn |
          compilerGeneratedVal.getLocation().hasLocationInfo(filepath, _, _, endline, endcolumn) and
          previousExpr
              .getLocation()
              .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
        )
      )
    )
  }
}

module ClassAggregateLiterals {
  predicate isValueInitialized(ClassAggregateLiteral cal, Field f) {
    cal.getUnspecifiedType().(Class).getAField() = f and
    (
      // The extractor will identify whether a field is value initialized by whether it has a empty
      // field expression. If that's the case, it's definitely value intialized
      cal.isValueInitialized(f)
      or
      // Unfortunately, in some cases the extractor will still generate an initializer for a field,
      // even if it's value initialized (typically because at least one field, or nested field, of
      // this cal is value initialized to something not zero - usually a constructor call or similar).
      //
      // To address this case, we try to find a `compilerGeneratedVal`, which is a value which has the
      // same _location_ as the previous initializer expression in the aggregate.
      not cal.isValueInitialized(f) and
      exists(Expr compilerGeneratedVal, int index, Expr previousExpr |
        // Identify the candidate expression which may be compiler generated
        compilerGeneratedVal = cal.getChild(index) and
        compilerGeneratedVal = cal.getAFieldExpr(f) and
        // Find the previous expression for this aggregate literal
        previousExpr = getPreviousExpr(cal, index)
      |
        // Must not be compiler generated, or in a macro expansion, otherwise our line numbers will be off
        not cal.isCompilerGenerated() and
        not cal.isInMacroExpansion() and
        // In some cases, explicitly initialized entries can be associated with an incorrect
        // location - that of a variable being initialized. We want to ignore these for the purposes of
        // identifying if they are value initialized
        not exists(
          Variable v, string filepath, int startline, int startcolumn, int endline, int endcolumn
        |
          v.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
          compilerGeneratedVal
              .getLocation()
              .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
        ) and
        exists(string filepath, int startline, int startcolumn, int endline, int endcolumn |
          compilerGeneratedVal.getLocation().hasLocationInfo(filepath, startline, _, _, endcolumn) and
          previousExpr
              .getLocation()
              .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
        )
      )
    )
  }
}

/**
 * An `AggregateLiteral` which is has been generated by the compiler to represent an "inferred" set
 * of braces, not explicitly written by the user.
 *
 * For example, in:
 * ```
 * int a[2][2] = { 1, 2, 3, 4 };
 * ```
 * the compiler infers the following additional braces, based on the object structure:
 * ```
 * int a[2][2] = { { 1, 2 }, { 3, 4 } };
 * ```
 * These extra braces are represented in our model as aggregate literals.
 */
class InferredAggregateLiteral extends AggregateLiteral {
  InferredAggregateLiteral() {
    getParent() instanceof AggregateLiteral and
    // Must not be compiler generated, or in a macro expansion, otherwise our line numbers will be off
    not isCompilerGenerated() and
    not isInMacroExpansion() and
    // The location of the first child is the same as the location of this aggregate,
    // indicating that the brackets were not added
    exists(string filepath, int startline, int startcolumn, int endline, int endcolumn |
      getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
      getChild(0)
          .getLocation()
          .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    ) and
    not isExprValueInitialized(this, getChild(0))
  }

  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // The default location of an InferredAggregateLieral is the location of the first element
    // For reporting purposes, we would prefer to report the whole "width" of the inferred literal
    exists(Expr firstChild | firstChild = getChild(0) |
      // The child of this element is an inferred aggregate literal, so look recursively
      if firstChild instanceof InferredAggregateLiteral
      then
        firstChild
            .(InferredAggregateLiteral)
            .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
      else (
        // Otherwise, we span between the first element and last element in the inferred literal
        firstChild.getLocation().hasLocationInfo(filepath, startline, startcolumn, _, _) and
        getChild(getNumChild() - 1)
            .getLocation()
            .hasLocationInfo(filepath, _, _, endline, endcolumn)
      )
    )
  }
}

/** Holds if the expression `e` is value initialized. */
predicate isExprValueInitialized(AggregateLiteral al, Expr e) {
  // This expression is a value initialized field
  exists(Field f |
    e = al.(ClassAggregateLiteral).getAFieldExpr(f) and
    ClassAggregateLiterals::isValueInitialized(al, f)
  )
  or
  // This expression is a value initialized array entry
  exists(int index |
    e = al.getChild(index) and
    ArrayAggregateLiterals::isValueInitialized(al, index)
  )
}

/**
 * Holds if the `AggregateLiteral` `a` is initialized by a leading zero, for example `{0}`.
 */
predicate isLeadingZeroInitialized(AggregateLiteral a) {
  (
    // The first child is a `0` literal
    a.getChild(0).(Literal).getValue() = "0"
    or
    // Or an inferred aggregate literal which is zero initialized
    isLeadingZeroInitialized(a.getChild(0).(InferredAggregateLiteral))
  ) and
  // The expression has been explicitly written by the user - i.e. not value initialized
  not isExprValueInitialized(a, a.getChild(0)) and
  // This is the only explicit child
  (
    // Either because the aggregate literal has no more child attached
    a.getNumChild() = 1
    or
    // Or because it's an array aggregate, and the next index is value initialized
    ArrayAggregateLiterals::isValueInitialized(a, 1)
    or
    // Or because it's a class aggregate, and all other fields are value initialized
    forall(Field f |
      f = a.getType().(Class).getAField() and
      not a.(ClassAggregateLiteral).getAFieldExpr(f) = a.getChild(0)
    |
      ClassAggregateLiterals::isValueInitialized(a, f)
    )
  )
}

/**
 * Holds if there is at least on explicitly initialized child and at least one value initialized
 * child of the aggregate literal.
 */
predicate isPartiallyValueInitialized(AggregateLiteral al) {
  exists(Expr explicitlyInitializedElement |
    // There is an element which is not value initialized
    explicitlyInitializedElement = al.getAChild() and
    not isExprValueInitialized(al, explicitlyInitializedElement)
  |
    // There is at least one value initialized field
    exists(Field f | ClassAggregateLiterals::isValueInitialized(al, f))
    or
    // If we are missing at least some initializers for an array, we can infer that at least some
    // of the array is value initialized
    al.getNumChild() < al.getType().(ArrayType).getArraySize()
    or
    // If we have initializers for the whole array, then we can check individual items to see if
    // they are value initialized
    al.getNumChild() = al.getType().(ArrayType).getArraySize() and
    exists(int index |
      index = [0 .. (al.getNumChild() - 1)] and
      ArrayAggregateLiterals::isValueInitialized(al, index)
    )
  )
}

/**
 * Holds if this aggregate literal itself if value initialized.
 */
predicate isBlankInitialized(AggregateLiteral al) {
  not isPartiallyValueInitialized(al) and
  (
    exists(Field f | ClassAggregateLiterals::isValueInitialized(al, f))
    or
    exists(int index |
      index = [0 .. (al.getType().(ArrayType).getArraySize() - 1)] and
      ArrayAggregateLiterals::isValueInitialized(al, index)
    )
  )
}

/** Gets the ancestor aggregate literal at the top of the aggregate literal tree. */
AggregateLiteral getRootAggregate(AggregateLiteral al) {
  not al.getParent() instanceof AggregateLiteral and
  result = al
  or
  result = getRootAggregate(al.getParent())
}

/**
 * Gets a string suitable for printing an aggregate type in an alert message, that includes an `$@`
 * formatting string.
 *
 * This is necessary because some common aggregate types (e.g. int[4]) do not have meaningful
 * locations in the database, which this works around by ensuring the type name is always included
 */
string getAggregateTypeDescription(AggregateLiteral al, Type aggType) {
  aggType = al.getType() and
  // If the aggregate type does not have a location in the database (for example, if it is an
  // array type such as int[4]), then the $@ link will not be created - instead it will be
  // replaced with an empty string. To give good reporting
  if aggType.getLocation().hasLocationInfo("", 0, 0, 0, 0)
  then result = "type " + aggType.getName() + "$@"
  else result = "type $@"
}
