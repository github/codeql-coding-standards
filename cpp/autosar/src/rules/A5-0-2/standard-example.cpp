// $Id: A5-0-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <memory>
extern std::int32_t* Fn();
extern std::int32_t Fn2();
extern bool Fn3();
void F() noexcept(false)
{
  std::int32_t* ptr = nullptr;
  while ((ptr = Fn()) != nullptr) // Compliant 
  {
    // Code
  }

  // The following is a cumbersome but compliant example
  do
  {
    std::int32_t* ptr = Fn();

    if (nullptr == ptr) 
    {
      break; 
    }

    // Code
  } while (true); // Compliant

  std::unique_ptr<std::int32_t> uptr;
  if (!uptr) // Compliant - std::unique_ptr defines an explicit conversion to
             // type bool. 
  {
    // Code
  }

  while (std::int32_t length = Fn2()) // Compliant by exception 
  {
    // Code
  }

  while (bool flag = Fn3()) // Compliant 
  {
    // Code
  }

  if (std::int32_t* ptr = Fn())
    ; // Compliant by exception 
    
  if (std::int32_t length = Fn2())
    ; // Compliant by exception

  if (bool flag = Fn3()) 
    ; // Compliant

  std::uint8_t u = 8; 
  
  if (u)
    ; // Non-compliant 

  bool boolean1 = false;
  bool boolean2 = true;

  if (u && (boolean1 <= boolean2))
    ; // Non-compliant

  for (std::int32_t x = 10; x; --x)
    ; // Non-compliant
}