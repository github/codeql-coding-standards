// $Id: A12-0-1.cpp 309769 2018-03-01 17:40:29Z jan.babst $
#include <string>

namespace v1
{
// Class is copyable and moveable via the compiler generated funtions.
// Compliant - rule of zero.
class A
{
  private:
    // Member data ...
};
} // namespace v1

namespace v2
{
// New requirement: Destructor needs to be added.
// Now the class is no longer moveable, but still copyable. The program 
// still compiles, but may perform worse.
// Non-compliant - Unclear if this was the developers intent.
class A
{
  public: 
    ~A()
    {
      // ... 
    }
  private:
    // Member data ...
};
} // namespace v2

namespace v3 {
// Move operations are brought back by defaulting them.
// Copy operations are defaulted since they are no longer generated
// (complies to A12-0-1 but will also be a compiler error if they are needed). 
// Default constructor is defaulted since it is no longer generated
// (not required by A12-0-1 but will be a compiler error if it is needed).
// Compliant - rule of five. Programmer’s intent is clear, class behaves the 
// same as v1::A.
class A
{
  public:
    A() = default;
    A(A const&) = default; 
    A(A&&) = default; 
    ~A()
    {
      // ... 
    }
    A& operator=(A const&) = default; 
    A& operator=(A&&) = default;

  private:
    // Member data ...
};
} // namespace v3

// A class with regular (value) semantics. 
// Compliant - rule of zero.
class Simple
{
  public:
  // User defined constructor, also acts as default constructor. 
  explicit Simple(double d = 0.0, std::string s = "Hello")
            : d_(d), s_(std::move(s))
  { 
  }

  // Compiler generated copy c’tor, move c’tor, d’tor, copy assignment, move 
  // assignment.

  private:
    double d_; 
    std::string s_;
};

// A base class.
// Compliant - rule of five. 
class Base
{
  public:
    Base(Base const&) = delete; // see also A12-8-6
    Base(Base&&) = delete;      // see also A12-8-6
    virtual ~Base() = default;  // see also A12-4-1 
    Base& operator=(Base const&) = delete; // see also A12-8-6
    Base& operator=(Base&&) = delete;      // see also A12-8-6

    // Declarations of pure virtual functions ...

  protected:
    Base() = default; // in order to allow construction of derived objects
};

// A move-only class.
// Compliant - rule of five. 
class MoveOnly
{
  public:
    MoveOnly();
    MoveOnly(MoveOnly const&) = delete; 
    MoveOnly(MoveOnly&&) noexcept;
    ~MoveOnly();
    MoveOnly& operator=(MoveOnly const&) = delete; 
    MoveOnly& operator=(MoveOnly&&) noexcept;

  private: 
    // ...
};