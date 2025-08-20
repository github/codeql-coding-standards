#include <type_traits>
#include <utility>

// Test cases for Rule 15.0.2: User-provided copy and move member functions
// should have appropriate signatures

// Compliant examples
class CompliantClass {
public:
  CompliantClass() = default;
  CompliantClass(CompliantClass const &);                  // COMPLIANT
  CompliantClass(CompliantClass &&) noexcept;              // COMPLIANT
  CompliantClass &operator=(CompliantClass const &) &;     // COMPLIANT
  CompliantClass &operator=(CompliantClass &&) & noexcept; // COMPLIANT
};

class CompliantWithAlternatives {
public:
  CompliantWithAlternatives() = default;
  constexpr CompliantWithAlternatives(
      const CompliantWithAlternatives &); // COMPLIANT
  explicit constexpr CompliantWithAlternatives(
      CompliantWithAlternatives &&) noexcept; // COMPLIANT
  constexpr CompliantWithAlternatives &
  operator=(const CompliantWithAlternatives &) & noexcept; // COMPLIANT
  constexpr CompliantWithAlternatives &
  operator=(CompliantWithAlternatives &&) & noexcept; // COMPLIANT
};

class CompliantVoidReturn {
public:
  CompliantVoidReturn() = default;
  CompliantVoidReturn(CompliantVoidReturn const &);
  CompliantVoidReturn(CompliantVoidReturn &&) noexcept;
  void
  operator=(CompliantVoidReturn const &) &; // COMPLIANT - void return allowed
  void operator=(
      CompliantVoidReturn &&) & noexcept; // COMPLIANT - void return allowed
};

// Non-compliant examples
class NonCompliantCopyConstructor {
public:
  NonCompliantCopyConstructor() = default;
  NonCompliantCopyConstructor(
      NonCompliantCopyConstructor &); // NON_COMPLIANT - non-const reference
};

class NonCompliantMoveConstructorNoExcept {
public:
  NonCompliantMoveConstructorNoExcept() = default;
  NonCompliantMoveConstructorNoExcept(
      NonCompliantMoveConstructorNoExcept
          &&); // NON_COMPLIANT - missing noexcept
};

class NonCompliantCopyAssignmentNoRefQualifier {
public:
  NonCompliantCopyAssignmentNoRefQualifier() = default;
  NonCompliantCopyAssignmentNoRefQualifier &
  operator=(NonCompliantCopyAssignmentNoRefQualifier const
                &); // NON_COMPLIANT - missing & qualifier
};

class NonCompliantMoveAssignmentNoRefQualifier {
public:
  NonCompliantMoveAssignmentNoRefQualifier() = default;
  NonCompliantMoveAssignmentNoRefQualifier &
  operator=(NonCompliantMoveAssignmentNoRefQualifier
                &&) noexcept; // NON_COMPLIANT - missing & qualifier
};

class NonCompliantMoveAssignmentNoExcept {
public:
  NonCompliantMoveAssignmentNoExcept() = default;
  NonCompliantMoveAssignmentNoExcept &
  operator=(NonCompliantMoveAssignmentNoExcept &&)
      &; // NON_COMPLIANT - missing noexcept
};

class NonCompliantCopyAssignmentNonConstRef {
public:
  NonCompliantCopyAssignmentNonConstRef() = default;
  NonCompliantCopyAssignmentNonConstRef &
  operator=(NonCompliantCopyAssignmentNonConstRef &)
      &; // NON_COMPLIANT - non-const reference
};

class NonCompliantVolatile {
public:
  NonCompliantVolatile() = default;
  NonCompliantVolatile(NonCompliantVolatile volatile const
                           &); // NON_COMPLIANT - volatile qualifier
};

class NonCompliantVirtual {
public:
  NonCompliantVirtual() = default;
  virtual NonCompliantVirtual &
  operator=(NonCompliantVirtual const &) &; // NON_COMPLIANT - virtual
};

class NonCompliantCopyByValue {
public:
  NonCompliantCopyByValue() = default;
  NonCompliantCopyByValue &
  operator=(NonCompliantCopyByValue) &; // NON_COMPLIANT - pass by value
};

class NonCompliantDefaultArguments {
public:
  NonCompliantDefaultArguments() = default;
  NonCompliantDefaultArguments(
      NonCompliantDefaultArguments &&,
      char c =
          'x') noexcept; // NON_COMPLIANT - default argument in move constructor
};

// Edge cases that are not copy/move constructors/operators
class NotCopyMoveOperations {
public:
  NotCopyMoveOperations() = default;
  NotCopyMoveOperations(
      NotCopyMoveOperations const &,
      char c); // COMPLIANT - not a copy constructor due to additional parameter
  NotCopyMoveOperations(
      NotCopyMoveOperations &&,
      int i); // COMPLIANT - not a move constructor due to additional parameter
};

// Deleted operations - rule does not apply
class DeletedOperations {
public:
  DeletedOperations() = default;
  DeletedOperations(DeletedOperations const &) =
      delete; // COMPLIANT - rule does not apply to deleted
  DeletedOperations(DeletedOperations &&) =
      delete; // COMPLIANT - rule does not apply to deleted
  DeletedOperations &operator=(DeletedOperations const &) =
      delete; // COMPLIANT - rule does not apply to deleted
  DeletedOperations &operator=(DeletedOperations &&) =
      delete; // COMPLIANT - rule does not apply to deleted
};

// Structs
struct CompliantStruct {
public:
  CompliantStruct() = default;
  CompliantStruct(CompliantStruct const &);                  // COMPLIANT
  CompliantStruct(CompliantStruct &&) noexcept;              // COMPLIANT
  CompliantStruct &operator=(CompliantStruct const &) &;     // COMPLIANT
  CompliantStruct &operator=(CompliantStruct &&) & noexcept; // COMPLIANT
};

struct NonCompliantStruct {
public:
  NonCompliantStruct() = default;
  NonCompliantStruct(
      NonCompliantStruct &); // NON_COMPLIANT - non-const reference
};