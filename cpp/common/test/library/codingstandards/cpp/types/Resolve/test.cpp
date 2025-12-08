#include <utility>

class Foo {};

Foo l1;                      // $ type=Foo,MaybeSpecFoo
Foo &l2 = l1;                // $ type=RefFoo
const Foo l3;                // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
const Foo &l4 = l3;          // $ type=ConstRefFoo
volatile Foo l5;             // $ type=MaybeSpecFoo,SpecFoo
volatile Foo &l6 = l5;       // $ type=
const volatile Foo l7;       // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
const volatile Foo &l8 = l7; // $ type=ConstRefFoo

typedef Foo TDFoo;
typedef Foo &TDFooRef;
typedef const Foo TDFooConst;
typedef const Foo &TDFooConstRef;
typedef volatile Foo TDFooVol;
typedef const volatile Foo TDFooVolConst;

// Plain typedefs
TDFoo l9;           // $ type=Foo,MaybeSpecFoo,TDFoo
TDFooConst l10;     // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
TDFooVol l11;       // $ type=MaybeSpecFoo,SpecFoo
TDFooVolConst l12;  // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
const TDFoo l13;    // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
volatile TDFoo l15; // $ type=MaybeSpecFoo,SpecFoo

// Ref types
TDFoo &l17 = l1;        // $ type=RefFoo
TDFooRef l18 = l1;      // $ type=RefFoo
TDFooConstRef l19 = l3; // $ type=ConstRefFoo

// const collapse
const TDFooConstRef l21 = l3; // $ type=ConstRefFoo
const TDFooConst l14;         // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
const volatile TDFoo l16;     // $ type=ConstFoo,MaybeSpecFoo,SpecFoo

// Ref collapse
TDFooRef &l22 = l1;       // $ type=RefFoo
const TDFooRef &l23 = l1; // $ type=RefFoo
TDFooConstRef &l24 = l3;  // $ type=ConstRefFoo

// Cannot const qualify a ref type, const is ignored [8.3.2/1]
TDFooRef const l20 = l1; // $ type=RefFoo

template <typename T> class Declval {
public:
  T type;
};

decltype(l1) l25 = l1;                   // $ type=DeclFoo,Foo,MaybeSpecFoo
decltype(Declval<Foo>::type) l26;        // $ type=DeclFoo,Foo,MaybeSpecFoo
decltype(Declval<Foo &>::type) l27 = l1; // $ type=RefFoo
decltype(Declval<const Foo>::type) l28;  // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
decltype(Declval<const Foo &>::type) l29 = l1; // $ type=ConstRefFoo
decltype(l25) l30;                          // $ type=DeclFoo,Foo,MaybeSpecFoo
decltype(Declval<TDFoo>::type) l31;         // $ type=DeclFoo,Foo,MaybeSpecFoo
decltype(Declval<TDFooRef>::type) l32 = l1; // $ type=RefFoo
decltype(Declval<TDFooConstRef>::type) l33 = l1; // $ type=ConstRefFoo
decltype(Declval<TDFooConst>::type) l34; // $ type=ConstFoo,MaybeSpecFoo,SpecFoo

const decltype(Declval<Foo>::type) l35; // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
volatile decltype(Declval<Foo>::type) l36; // $ type=MaybeSpecFoo,SpecFoo
const volatile decltype(Declval<Foo>::type)
    l37;                                // $ type=ConstFoo,MaybeSpecFoo,SpecFoo
decltype(Declval<Foo>::type) &l38 = l1; // $ type=RefFoo
decltype(Declval<Foo &>::type) &l39 = l1;       // $ type=RefFoo
decltype(Declval<const Foo>::type) &l40 = l1;   // $ type=ConstRefFoo
decltype(Declval<const Foo &>::type) &l41 = l1; // $ type=ConstRefFoo
const decltype(Declval<volatile Foo>::type)
    l42; // $ type=ConstFoo,MaybeSpecFoo,SpecFoo