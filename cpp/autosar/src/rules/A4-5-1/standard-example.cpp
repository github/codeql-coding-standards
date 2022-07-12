// $Id: A4-5-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
enum Colour : std::uint8_t
{
  Red,
  Green,
  Blue, 
  ColoursCount
};
void F1() noexcept(false) 
{
  Colour colour = Red;
  if (colour == Green) // Compliant 
  {
  }
  if (colour == (Red + Blue)) // Non-compliant 
  {
  }
  if (colour < ColoursCount) // Compliant 
  {
  }
}
enum class Car : std::uint8_t
{
  Model1,
  Model2,
  Model3,
  ModelsCount
};
void F2() noexcept(false)
{
  Car car = Car::Model1;
  if (car != Car::Model2) // Compliant
  {
  }

  if (car == Car::Model3) // Compliant
  {
  }

  // if (car == (Car::Model1 + Car::Model2)) // Non-compliant -
  // operator+ not provided for Car enum class, compilation error
  //{
  //}
  if (car < Car::ModelsCount) // Compliant
  {
  }
}
Car operator+(Car lhs, Car rhs)
{
  return Car::Model3;
}
void F3() noexcept(false)
{
  Car car = Car::Model3;
  if (car == (Car::Model1 + Car::Model2)) // Non-compliant - overloaded
                                          // operator+ provided, no
                                          // compilation error
  {
  }
}
enum Team : std::uint8_t
{
  TeamMember1 = 0,
  TeamMember2 = 1,
  TeamMember3 = 2,
  TeamMember4 = 3,
  TeamMembersStart = TeamMember1,
  TeamMembersEnd = TeamMember2,
  TeamMembersCount = 4
};
void F4(const char* teamMember)
{
  // Implementation
}
void F5()
{
  const char* team[TeamMembersCount]; //Compliant
  // ...
  F4(team[TeamMember2]); // Compliant
}