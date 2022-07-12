// $Id: A18-5-3.cpp 316977 2018-04-20 12:37:31Z christof.meerwald $
#include <cstdint>

void Fn1()
{
  std::int32_t* array =
  new std::int32_t[10]; // new expression used to allocate an
                        // array object 
  // ...
  delete array; // Non-compliant - array delete expression supposed
                // to be used
}
void Fn2()
{
  std::int32_t* object = new std::int32_t{0}; // new operator used to
                                              // allocate the memory for an
                                              // integer type
  // ...
  delete[] object; // Non-compliant - non-array delete expression supposed
                   // to be used

}
void Fn3()
{
  std::int32_t* object = new std::int32_t{0};
  std::int32_t* array = new std::int32_t[10]; 
  // ...
  delete[] array; // Compliant
  delete object;  // Compliant
}