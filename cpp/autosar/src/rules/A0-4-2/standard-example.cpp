//% $Id: A0-4-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
void Fn() noexcept
{
    float f1{0.1F}; // Compliant 
    double f2{0.1}; // Compliant 
    long double f3{0.1L}; // Non-compliant
}