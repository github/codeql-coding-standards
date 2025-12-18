import cpp
import utils.test.InlineExpectationsTest
import codingstandards.cpp.types.Resolve

class FooType extends Class {
  FooType() { this.hasName("Foo") }
}

class TDFoo extends TypedefType {
  TDFoo() { this.hasName("TDFoo") }
}

class DeclFoo extends Decltype {
  DeclFoo() { this.getBaseType() instanceof FooType }
}

class ExactFoo = ResolvesTo<FooType>::Exactly;

class ConstFoo = ResolvesTo<FooType>::CvConst;

class SpecFoo = ResolvesTo<FooType>::Specified;

class MaybeSpecFoo = ResolvesTo<FooType>::IgnoringSpecifiers;

class RefFoo = ResolvesTo<FooType>::Ref;

class ConstRefFoo = ResolvesTo<FooType>::CvConstRef;

class ExactTDFoo = ResolvesTo<TDFoo>::Exactly;

class ExactDeclFoo = ResolvesTo<DeclFoo>::Exactly;

predicate hasRelevantType(Type type, string s) {
  type instanceof ExactFoo and s = "Foo"
  or
  type instanceof ConstFoo and s = "ConstFoo"
  or
  type instanceof SpecFoo and s = "SpecFoo"
  or
  type instanceof MaybeSpecFoo and s = "MaybeSpecFoo"
  or
  type instanceof RefFoo and s = "RefFoo"
  or
  type instanceof ConstRefFoo and s = "ConstRefFoo"
  or
  type instanceof ExactTDFoo and s = "TDFoo"
  or
  type instanceof ExactDeclFoo and s = "DeclFoo"
}

module MyTest implements TestSig {
  string getARelevantTag() { result = "type" }

  predicate hasActualResult(Location l, string element, string tag, string value) {
    exists(Variable var, Type type |
      var.getLocation().getFile().getBaseName() = "test.cpp" and
      not var.isFromTemplateInstantiation(_) and
      not var.isFromUninstantiatedTemplate(_) and
      var.getLocation() = l and
      element = var.toString() and
      tag = getARelevantTag() and
      type = var.getType() and
      value = concat(string typestr | hasRelevantType(type, typestr) | typestr, ",")
    )
  }
}

import MakeTest<MyTest>
