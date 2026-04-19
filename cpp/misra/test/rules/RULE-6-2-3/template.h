#ifndef TEMPLATE_H
#define TEMPLATE_H
#include "class.h"

namespace template_h {
class C1 {};
class C2 {};
} // namespace template_h

template <typename T> class Tpl1 {};
template <typename A, typename B> class Tpl2 {};
template <int> class Tpl3 {};
template <typename T, int> class Tpl4 {};

template <> class Tpl1<int> {};            // COMPLIANT
template <> class Tpl1<template_h::C1> {}; // COMPLIANT
template <> class Tpl1<class_h::C1> {};    // COMPLIANT

template <> class Tpl2<int, int> {};                       // COMPLIANT
template <> class Tpl2<template_h::C1, template_h::C1> {}; // COMPLIANT
template <> class Tpl2<class_h::C1, class_h::C1> {};       // COMPLIANT

template <typename T> class Tpl2<int, T> {}; // COMPLIANT

template<> class Tpl3<0> {}; // COMPLIANT
template<> class Tpl4<int, 0> {}; // COMPLIANT
template<> class Tpl4<template_h::C1, 0> {}; // COMPLIANT
template<> class Tpl4<class_h::C1, 0> {}; // COMPLIANT

#endif // TEMPLATE_H