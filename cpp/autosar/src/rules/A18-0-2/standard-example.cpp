// $Id: A18-0-2.cpp 312092 2018-03-16 15:47:01Z jan.babst $
#include <cstdint> 
#include <cstdlib> 
#include <iostream> 
#include <string>

std::int32_t F1(const char* str) noexcept
{
return atoi(str); // Non-compliant - undefined behavior if str can not
                                  // be converted
}
std::int32_t F2(std::string const& str) noexcept(false) 
{
return std::stoi(str); // Compliant - throws a std::invalid_argument
                                            // exception if str can not be converted
}
std::uint16_t ReadFromStdin1() // non-compliant
{
std::uint16_t a;
std::cin >> a; // no error detection
return a;
}
std::uint16_t ReadFromStdin2() // compliant
{
std::uint16_t a;
std::cin.clear(); // clear all flags
std::cin >> a;
if (std::cin.fail())
{
throw std::runtime_error{"unable to read an integer"};
}
std::cin.clear(); // clear all flags for subsequent operations
return a;
}