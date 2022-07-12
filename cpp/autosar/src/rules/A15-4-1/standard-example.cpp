//% $Id: A15-4-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <stdexcept>
void F1() noexcept; // Compliant - note that noexcept is the same as
// noexcept(true)
void F2() throw(); // Non-compliant - dynamic exception-specification is
// deprecated
void F3() noexcept(false);           // Compliant
void F4() throw(std::runtime_error); // Non-compliant - dynamic
// exception-specification is deprecated
void F5() throw(
    ...); // Non-compliant - dynamic exception-specification is deprecated
template <class T> void F6() noexcept(noexcept(T())); // Compliant