// $Id: A8-5-0.cpp 307536 2018-02-14 12:35:11Z jan.babst $
#include <cstdint> 
#include <string>
static std::int32_t zero; // Compliant - Variable with static storage duration 
                                         // is zero-initialized.

void local()
{
  std::int32_t a; // No initialization 
  std::int32_t b{}; // Compliant - zero initialization
  
  b = a; // Non-compliant - uninitialized memory read 
  a = zero; // Compliant - a is zero now
  b = a; // Compliant - read from initialized memory

  std::string s; // Compliant - default constructor is a called
  // read from s
}

void dynamic() 
{
  // Note: These examples violate A18-5-2
  auto const a = new std::int32_t;
  auto const b = new std::int32_t{}; // Compliant - zero initialization
  
  *b = *a; // Non-compliant - uninitialized memory read 
  *a = zero; // Compliant - a is zero now
  *b = *a; 
  
  delete b;
  delete a;

  // Compliant - read from initialized memory
  auto const s =
       new std::string; // Compliant - default constructor is a called
                        // read from *s
  delete s; 
}

// Members of Bad are default-initialized by the (implicitly generated) default 
// constructor. Note that this violates A12-1-1.
struct Bad
{
  std::int32_t a;
  std::int32_t b; 
};

// Compliant - Members of Good are explicitly initialized. 
// This also complies to A12-1-1.
struct Good
{
  std::int32_t a{0};
  std::int32_t b{0}; 
};

void members() 
{
  Bad bad; // Default constructor is called, but members a not initialized
  
  bad.b = bad.a; // Non-compliant - uninitialized memory read 
  bad.a = zero;  // Compliant - bad.a is zero now
  bad.b = bad.a; // Compliant - read from initialized memory

  Good good; // Default constructor is called and initializes members 
  
  std::int32_t x = good.a; // Compliant
  std::int32_t y = good.b; // Compliant
}