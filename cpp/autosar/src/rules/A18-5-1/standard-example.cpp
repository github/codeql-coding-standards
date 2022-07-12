// $Id: A18-5-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <cstdlib>
void F1() noexcept(false)
{
  // Non-compliant
  std::int32_t* p1 = static_cast<std::int32_t*>(malloc(sizeof(std::int32_t))); 
  *p1 = 0;
  
  // Compliant
  std::int32_t* p2 = new std::int32_t(0);

  // Compliant
  delete p2;
  
  // Non-compliant
  free(p1);

  // Non-compliant
  std::int32_t* array1 = static_cast<std::int32_t*>(calloc(10, sizeof(std::int32_t)));

  // Non-compliant
  std::int32_t* array2 =
  static_cast<std::int32_t*>(realloc(array1, 10 * sizeof(std::int32_t)));

  // Compliant
  std::int32_t* array3 = new std::int32_t[10];

  // Compliant
  delete[] array3;

  // Non-compliant
  free(array2);

  // Non-compliant
  free(array1);
}
void F2() noexcept(false)
{
  // Non-compliant
  std::int32_t* p1 = static_cast<std::int32_t*>(malloc(sizeof(std::int32_t))); 
  // Non-compliant - undefined behavior
  delete p1;

  std::int32_t* p2 = new std::int32_t(0); // Compliant
  free(p2); // Non-compliant - undefined behavior
}
void operator delete(void* ptr) noexcept
{
    std::free(ptr); // Compliant by exception
}