import cpp

newtype TTemplateElement =
  TTemplateClass(TemplateClass c) or
  TTemplateFunction(TemplateFunction f) or
  TTemplateVariable(TemplateVariable v)

/**
 * A templated element. These are either templated classes, templated functions,
 * or templated variables.
 */
class TemplateElement extends TTemplateElement {
  TemplateClass asTemplateClass() { this = TTemplateClass(result) }

  TemplateFunction asTemplateFunction() { this = TTemplateFunction(result) }

  TemplateVariable asTemplateVariable() { this = TTemplateVariable(result) }

  string toString() {
    result = this.asTemplateClass().toString() or
    result = this.asTemplateFunction().toString() or
    result = this.asTemplateVariable().toString()
  }

  Location getLocation() {
    result = this.asTemplateClass().getLocation() or
    result = this.asTemplateFunction().getLocation() or
    result = this.asTemplateVariable().getLocation()
  }

  string getName() {
    result = this.asTemplateClass().getName() or
    result = this.asTemplateFunction().getName() or
    result = this.asTemplateVariable().getName()
  }
}

newtype TTemplateInstantiation =
  TClassTemplateInstantiation(ClassTemplateInstantiation c) or
  TFunctionTemplateInstantiation(FunctionTemplateInstantiation f) or
  TVariableTemplateInstantiation(VariableTemplateInstantiation v)

/**
 * An instantiation of a templated element, either a templated class, templated
 * function, or templated variable.
 */
class TemplateInstantiation extends TTemplateInstantiation {
  ClassTemplateInstantiation asClassTemplateInstantiation() {
    this = TClassTemplateInstantiation(result)
  }

  FunctionTemplateInstantiation asFunctionTemplateInstantiation() {
    this = TFunctionTemplateInstantiation(result)
  }

  VariableTemplateInstantiation asVariableTemplateInstantiation() {
    this = TVariableTemplateInstantiation(result)
  }

  string toString() {
    result = this.asClassTemplateInstantiation().toString() or
    result = this.asFunctionTemplateInstantiation().toString() or
    result = this.asVariableTemplateInstantiation().toString()
  }

  Location getLocation() {
    result = this.asClassTemplateInstantiation().getLocation() or
    result = this.asFunctionTemplateInstantiation().getLocation() or
    result = this.asVariableTemplateInstantiation().getLocation()
  }

  Element asElement() {
    result = this.asClassTemplateInstantiation() or
    result = this.asFunctionTemplateInstantiation() or
    result = this.asVariableTemplateInstantiation()
  }

  /**
   * Gets the template this instantiation is from, depending on the kind of the element
   * this instantiation is for.
   */
  TemplateElement getTemplate() {
    result.asTemplateClass() = this.asClassTemplateInstantiation().getTemplate() or
    result.asTemplateFunction() = this.asFunctionTemplateInstantiation().getTemplate() or
    result.asTemplateVariable() = this.asVariableTemplateInstantiation().getTemplate()
  }

  /**
   * Gets a use of an instantiation of this template. i.e.
   * 1. For a class template, it's where the instantiated type is used by the name.
   * 2. For a function template, it's where the instantiated function is called.
   * 3. For a variable template, it's where the instantiated variable is initialized.
   */
  Element getAUse() {
    result = this.asClassTemplateInstantiation().getATypeNameUse() or
    result = this.asFunctionTemplateInstantiation().getACallToThisFunction() or
    result = this.asVariableTemplateInstantiation()
  }
}

/**
 * An implicit conversion from a plain char type to an explicitly signed or unsigned char
 * type. `std::uint8_t` and `std::int8_t` are also considered as these char types.
 *
 * Note that this class only includes implicit conversions and does not include explicit
 * type conversions, i.e. casts.
 */
class ImplicitConversionFromPlainCharType extends Conversion {
  ImplicitConversionFromPlainCharType() {
    this.isImplicit() and
    this.getExpr().getUnspecifiedType() instanceof PlainCharType and
    (
      this.getUnspecifiedType() instanceof SignedCharType or
      this.getUnspecifiedType() instanceof UnsignedCharType
    )
  }
}

newtype TImplicitConversionElement =
  TImplicitConversionOutsideTemplate(ImplicitConversionFromPlainCharType implicitConversion) {
    not exists(TemplateInstantiation instantiation |
      implicitConversion.isFromTemplateInstantiation(instantiation.asElement())
    )
  } or
  TInstantiationOfImplicitConversionTemplate(
    TemplateInstantiation templateInstantiation,
    ImplicitConversionFromPlainCharType implicitConversion
  ) {
    implicitConversion.getEnclosingElement+() = templateInstantiation.asElement()
  }

/**
 * The locations where the implicit conversion from a plain char to an explicitly signed / unsigned
 * char is taking place on a high level. It splits case on whether the conversion is caused by
 * instantiating a template:
 *
 * - For conversions not due to template usage (i.e. outside a templated element), this refers to
 * the same element as the one associated with the conversion.
 * - For conversions due to template usage, this refers to the element that uses the instantiation
 * of a template where an implicit char conversion happens.
 */
class ImplicitConversionLocation extends TImplicitConversionElement {
  ImplicitConversionFromPlainCharType asImplicitConversionOutsideTemplate() {
    this = TImplicitConversionOutsideTemplate(result)
  }

  TemplateInstantiation asInstantiationOfImplicitConversionTemplate(
    ImplicitConversionFromPlainCharType implicitConversion
  ) {
    this = TInstantiationOfImplicitConversionTemplate(result, implicitConversion)
  }

  /**
   * Holds if this is a location of a conversion happening outside of a template.
   */
  predicate isImplicitConversionOutsideTemplate() {
    exists(this.asImplicitConversionOutsideTemplate())
  }

  /**
   * Holds if this is a location of a conversion happening due to instantiating a
   * template.
   */
  predicate isInstantiationOfImplicitConversionTemplate() {
    exists(
      TemplateInstantiation templateInstantiation,
      ImplicitConversionFromPlainCharType implicitConversion
    |
      templateInstantiation = this.asInstantiationOfImplicitConversionTemplate(implicitConversion)
    )
  }

  /**
   * Gets the implicit conversion that this location is associated with.
   * - In cases of conversions not involving a template, this is the same as the
   * location associated with the conversion.
   * - In cases of conversions due to using a template, this is the conversion that
   * happens in the instantiated template.
   */
  ImplicitConversionFromPlainCharType getImplicitConversion() {
    result = this.asImplicitConversionOutsideTemplate() or
    exists(TemplateInstantiation templateInstantiation |
      this = TInstantiationOfImplicitConversionTemplate(templateInstantiation, result)
    )
  }

  string toString() {
    result = this.asImplicitConversionOutsideTemplate().toString() or
    exists(ImplicitConversionFromPlainCharType implicitConversion |
      result = this.asInstantiationOfImplicitConversionTemplate(implicitConversion).toString()
    )
  }

  Location getLocation() {
    result = this.asImplicitConversionOutsideTemplate().getLocation() or
    exists(ImplicitConversionFromPlainCharType implicitConversion |
      result = this.asInstantiationOfImplicitConversionTemplate(implicitConversion).getLocation()
    )
  }

  Element asElement() {
    result = this.asImplicitConversionOutsideTemplate() or
    exists(ImplicitConversionFromPlainCharType implicitConversion |
      result = this.asInstantiationOfImplicitConversionTemplate(implicitConversion).getAUse()
    )
  }
}
