//% $Id: A0-4-4.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $

#include <cmath>
#include <cfenv>

float Foo(float val)
{
    //non-compliant, domain error for negative values
    return std::sqrt(val);
}
float Bar(float val)
{
    //non-compliant
    //domain error for val < 0
    //pole error for val==0
    return std::log(val);
}
// \return true, if a range error occurred
bool DetectRangeErr()
{
    return ((math_errhandling & MATH_ERREXCEPT) &&
          (fetestexcept(FE_INEXACT | FE_OVERFLOW | FE_UNDERFLOW) != 0));
}