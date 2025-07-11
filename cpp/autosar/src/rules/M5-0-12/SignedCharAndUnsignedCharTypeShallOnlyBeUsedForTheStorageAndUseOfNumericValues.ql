/**
 * @id cpp/autosar/signed-char-and-unsigned-char-type-shall-only-be-used-for-the-storage-and-use-of-numeric-values
 * @name M5-0-12: Signed char and unsigned char type shall only be used for the storage and use of numeric values
 * @description The signedness of the plain char type is implementation defined and thus signed char
 *              and unsigned char should only be used for numeric data and the plain char type may
 *              only be used for character data.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-12
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

newtype TTemplatedElement =
  TClassTemplate(TemplateClass c) or
  TFunctionTemplate(TemplateFunction f) or
  TVariableTemplate(TemplateVariable v)

class TemplatedElement extends TTemplatedElement {
  TemplateClass asTemplateClass() { this = TClassTemplate(result) }

  TemplateFunction asTemplateFunction() { this = TFunctionTemplate(result) }

  TemplateVariable asTemplateVariable() { this = TVariableTemplate(result) }

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

  TemplatedElement getTemplate() {
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

class ImplicitConversionLocation extends TImplicitConversionElement {
  ImplicitConversionFromPlainCharType asImplicitConversionOutsideTemplate() {
    this = TImplicitConversionOutsideTemplate(result)
  }

  TemplateInstantiation asInstantiationOfImplicitConversionTemplate(
    ImplicitConversionFromPlainCharType implicitConversion
  ) {
    this = TInstantiationOfImplicitConversionTemplate(result, implicitConversion)
  }

  predicate isImplicitConversionOutsideTemplate() {
    exists(this.asImplicitConversionOutsideTemplate())
  }

  predicate isInstantiationOfImplicitConversionTemplate() {
    exists(
      TemplateInstantiation templateInstantiation,
      ImplicitConversionFromPlainCharType implicitConversion
    |
      templateInstantiation = this.asInstantiationOfImplicitConversionTemplate(implicitConversion)
    )
  }

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

string getMessageTemplate(ImplicitConversionLocation implicitConversionLocation) {
  exists(ImplicitConversionFromPlainCharType implicitConversion |
    implicitConversion = implicitConversionLocation.getImplicitConversion()
  |
    implicitConversionLocation.isImplicitConversionOutsideTemplate() and
    result =
      "Implicit conversion of plain char $@ to " + implicitConversion.getType().getName() + "."
    or
    implicitConversionLocation.isInstantiationOfImplicitConversionTemplate() and
    result =
      "Implicit conversion of plain char $@ to " + implicitConversion.getType().getName() +
        " from instantiating template '" +
        implicitConversionLocation
            .asInstantiationOfImplicitConversionTemplate(implicitConversion)
            .getTemplate()
            .getName() + "'."
  )
}

from
  ImplicitConversionLocation implicitConversionLocation,
  ImplicitConversionFromPlainCharType implicitConversion
where
  not isExcluded(implicitConversionLocation.asElement(),
    StringsPackage::signedCharAndUnsignedCharTypeShallOnlyBeUsedForTheStorageAndUseOfNumericValuesQuery()) and
  implicitConversion = implicitConversionLocation.getImplicitConversion()
select implicitConversionLocation.asElement(), getMessageTemplate(implicitConversionLocation),
  implicitConversion.getExpr(), "expression"
