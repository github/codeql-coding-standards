#include "template.h"

template <> class Tpl1<long> {};           // NON_COMPLIANT
template <> class Tpl1<template_h::C2> {}; // NON_COMPLIANT
template <> class Tpl1<class_h::C2> {};    // NON_COMPLIANT

template <> class Tpl2<long, long> {};                     // NON_COMPLIANT
template <> class Tpl2<template_h::C2, template_h::C2> {}; // NON_COMPLIANT
template <> class Tpl2<class_h::C2, class_h::C2> {};       // NON_COMPLIANT

template <typename T> class Tpl2<long, T> {};        // NON_COMPLIANT
template <typename T> class Tpl2<class_h::C1, T> {}; // NON_COMPLIANT

template <> class Tpl3<1> {};                   // NON_COMPLIANT
template <> class Tpl4<long, 0> {};             // NON_COMPLIANT
template <> class Tpl4<template_h::C1, 1> {};   // NON_COMPLIANT
template <> class Tpl4<class_h::C1, 1> {};      // NON_COMPLIANT
template <int N> class Tpl4<class_h::C2, N> {}; // NON_COMPLIANT
template <typename T> class Tpl4<T, 2> {};      // NON_COMPLIANT