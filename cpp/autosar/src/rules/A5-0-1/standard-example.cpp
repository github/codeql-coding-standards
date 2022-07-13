// $Id: A5-0-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <stack>
// The following notes give some guidance on how dependence on order of
// evaluation may occur, and therefore may assist in adopting the rule.

// 1) Increment or decrement operators
// As an example of what can go wrong, consider
void F1(std::uint8_t (&arr)[10], std::uint8_t idx) noexcept(false)
{
  std::uint16_t x = arr[idx] + idx++;
}
// This will give different results depending on whether arr[idx] is evaluated
// before idx++ or vice versa. The problem could be avoided by putting the
// increment operation in a separate statement. For example:
void F2(std::uint8_t (&arr)[10], std::uint8_t idx) noexcept(false)
{
  std::uint8_t x = arr[idx] + idx;
  idx++;
}

// 2) Function arguments
// The order of evaluation of function arguments is unspecified.
extern std::uint8_t Func(std::uint8_t x, std::uint8_t y);
void F3() noexcept(false)
{
  std::uint8_t i = 0;
  std::uint8_t x = Func(i++, i);
}
// This will give different results depending on which of the functions two
// parameters is evaluated first.

// 3) Function pointers
// If a function is called via a function pointer there shall be no
// dependence
// on the order in which function-designator and function arguments are
// evaluated.
struct S
{
  void TaskStartFn(S* obj) noexcept(false);
};
void F4(S* p) noexcept(false)
{
  p->TaskStartFn(p++);
}

// 4) Function calls
// Functions may have additional effects when they are called (e.g. modifying
// some global data). Dependence on order of evaluation could be avoided by
// invoking the function prior to the expression that uses it, making use of a
// temporary variable for the value. For example:
extern std::uint16_t G(std::uint8_t) noexcept(false);
extern std::uint16_t Z(std::uint8_t) noexcept(false);
void F5(std::uint8_t a) noexcept(false)
{
  std::uint16_t x = G(a) + Z(a);
}
// could be written as
void F6(std::uint8_t a) noexcept(false)
{
  std::uint16_t x = G(a);
  x += Z(a);
}
// As an example of what can go wrong, consider an expression to take two values
// off a stack, subtract the second from the first, and push the result back on
// the stack:
std::int32_t Pop(std::stack<std::int32_t>& s)
{
  std::int32_t ret = s.top();
  s.pop();
  return ret;
}
void F7(std::stack<std::int32_t>& s)
{
  s.push(Pop(s) - Pop(s));
}
// This will give different results depending on which of the pop() function
// calls is evaluated first (because pop() has side effects).

// 5) Nested assignment statements
// Assignments nested within expressions cause additional side effects. The best
// way to avoid any possibility of this leading to a dependence on order of
// evaluation is not to embed assignments within expressions. For example, the
// following is not recommended:
void F8(std::int32_t& x) noexcept(false)
{
  std::int32_t y = 4;
  x = y = y++; // It is undefined whether the final value of y is 4 or 5
}
// 6) Accessing a volatile
// The volatile type qualifier is provided in C++ to denote objects whose value
// can change independently of the execution of the program (for example an
// input register). If an object of volatile qualified type is accessed this may
// change its value. C++ compilers will not optimize out reads of a volatile. In
// addition, as far as a C++ program is concerned, a read of a volatile has a
// side effect (changing the value of the volatile). It will usually be
// necessary to access volatile data as part of an expression, which then means
// there may be dependence on order of evaluation. Where possible, though, it is
// recommended that volatiles only be accessed in simple assignment statements,
// such as the following:
void F9(std::uint16_t& x) noexcept(false)
{
  volatile std::uint16_t v;
  // ...
  x = v;
}

// The rule addresses the order of evaluation problem with side effects. Note
// that there may also be an issue with the number of times a sub-expression is
// evaluated, which is not covered by this rule. This can be a problem with
// function invocations where the function is implemented as a macro. For
// example, consider the following function-like macro and its invocation:
#define MAX(a, b) (((a) > (b)) ? (a) : (b))
// ...
void F10(std::uint32_t& i, std::uint32_t j)
{
  std::uint32_t z = MAX(i++, j);
}
// The definition evaluates the first parameter twice if a > b but only once if
// a = b. The macro invocation may thus increment i either once or twice,
// depending on the values of i and j.
// It should be noted that magnitude-dependent effects, such as those due to
// floating-point rounding, are also not addressed by this rule. Although
// the
// order in which side effects occur is undefined, the result of an operation is
// otherwise well-defined and is controlled by the structure of the expression.
// In the following example, f1 and f2 are floating-point variables; F3, F4
// and
// F5 denote expressions with floating-point types.

// f1 = F3 + ( F4 + F5 );
// f2 = ( F3 + F4 ) + F5;

// The addition operations are, or at least appear to be, performed in the order
// determined by the position of the parentheses, i.e. firstly F4 is added to F5
// then secondly F3 is added to give the value of f1. Provided that F3, F4 and
// F5 contain no side effects, their values are independent of the order in
// which they are evaluated. However, the values assigned to f1 and f2 are not
// guaranteed to be the same because floating-point rounding following the
// addition operations are dependent on the values being added.