/**
 * @id c/misra/disallowed-function-type-qualifier
 * @name RULE-17-13: A function type shall not include any type qualifiers (const, volatile, restrict, or _Atomic)
 * @description The behavior of type qualifiers on a function type is undefined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-13
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

//from DeclarationEntry decl, Type type //, Specifier specifier
//where
//  not isExcluded(decl, FunctionTypesPackage::disallowedFunctionTypeQualifierQuery()) and
//  //decl.getType() instanceof FunctionPointerType and
//  //decl.getType().(FunctionPointerType).hasSpecifier(specifier)
//  (type = decl.getType().getUnderlyingType*()
//  or type = decl.getType())
//   and
//  //specifier = type.getASpecifier()
//  any()
//select decl, type //, specifier // "The behavior of type qualifier " + specifier + " on a function type is undefined." 

newtype TDeclaredFunction =
  TFunctionDeclaration(Declaration declaration)

abstract class DeclaredFunction extends TDeclaredFunction {
  abstract string toString();
}

predicate isConstFunction(Type type) {
  (type.getASpecifier().getName() = "const"
  or type.isConst())
  and isFunctionType(type)
  or isConstFunction(type.getUnderlyingType())
}

predicate isFunctionType(Type type) {
  type instanceof FunctionPointerType
  or isFunctionType(type.getUnderlyingType())
}

predicate declaresConstFunction(DeclarationEntry entry) {
  (entry.getDeclaration().getASpecifier().getName() = "const"
  and isFunctionType(entry.getType()))
  or isConstFunction(entry.getType())
}

class QualifiableRoutineType extends RoutineType, QualifiableType {
  override string explainQualifiers() {
    result = "func{"
      + specifiersOf(this) + this.getReturnType().(QualifiableType).explainQualifiers()
      + " ("
      + paramString(0)
      + ")}"
  }

  string paramString(int i) {
    i = 0 and result = "" and not exists(this.getAParameterType())
    or
    (
      if i < max(int j | exists(this.getParameterType(j)))
      then
        // Not the last one
        result = this.getParameterType(i).(QualifiableType).explainQualifiers() + "," + this.paramString(i + 1)
      else
        // Last parameter
        result = this.getParameterType(i).(QualifiableType).explainQualifiers()
    )
  }
}

class QualifiableIntType extends IntType, QualifiableType {
  override string explainQualifiers() {
    result = specifiersOf(this) + " " + this.toString()
  }
}

class QualifiablePointerType extends PointerType, QualifiableType {
  override string explainQualifiers() {
    result = "{" 
      + specifiersOf(this)
      + " pointer to "
      + this.getBaseType().(QualifiableType).explainQualifiers()
      + "}"
  }
}

class QualifiableType extends Type {
  string explainQualifiers() {
    result = "Unimplemented explainQualifiers for type(s): " + concat(string s | s = getAQlClass() | s, ",")
  }
}

class QualifiableTypedefType extends TypedefType, QualifiableType {
  override string explainQualifiers() {
    result = "{ typedef "
      + specifiersOf(this)
      + " "
      + this.getBaseType().(QualifiableType).explainQualifiers()
      + "}"
  }
}

class QualifiableSpecifiedType extends SpecifiedType, QualifiableType {
  override string explainQualifiers() {
    result = "{"
      + specifiersOf(this)
      + " "
      + this.getBaseType().(QualifiableType).explainQualifiers()
      + "}"
  }
}

string typeString(Type t) {
  //if 
  //  t instanceof CTypedefType
  //  then result = t.(CTypedefType).explain() + "specs:" + specifiersOf(t.(CTypedefType).getBaseType()) + "/" + typeString(t.(CTypedefType).getBaseType())
  //  else
  //result = concat(string s | s = t.getAQlClass() | s, ",")
  result = t.(QualifiableType).explainQualifiers()
}

string specifiersOf(Type t) {
  result = concat(Specifier s | s = t.getASpecifier()| s.getName(), ", ")
}

string declSpecifiersOf(Declaration d) {
  result = concat(Specifier s | s = d.getASpecifier()| s.getName(), ", ")
}

string underlying(Type t) {
  exists(Type u | u = t.getUnderlyingType() | result = u.toString())
  or  result = "[no underlying]"

}

from DeclarationEntry entry
select entry, entry.getType(), typeString(entry.getType()), declSpecifiersOf(entry.getDeclaration()), specifiersOf(entry.getType())

//from Type t
//where any()//isFunctionType(t)
//select t, specifiersOf(t), underlying(t)