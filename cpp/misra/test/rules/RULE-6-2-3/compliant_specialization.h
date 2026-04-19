#include "class.h"
#include "template.h"

namespace compliant_h {
class C1 {};
} // namespace compliant_h

template <> class Tpl1<compliant_h::C1> {};                  // COMPLIANT
template <> class Tpl2<compliant_h::C1, compliant_h::C1> {}; // COMPLIANT
template <> class Tpl2<template_h::C1, compliant_h::C1> {};  // COMPLIANT
template <> class Tpl2<class_h::C1, compliant_h::C1> {};     // COMPLIANT
template <> class Tpl2<compliant_h::C1, long> {};            // COMPLIANT

template <typename T> class Tpl2<T, compliant_h::C1> {}; // COMPLIANT

template<> class Tpl4<compliant_h::C1, 0> {}; // COMPLIANT
template<int N> class Tpl4<compliant_h::C1, N> {}; // COMPLIANT