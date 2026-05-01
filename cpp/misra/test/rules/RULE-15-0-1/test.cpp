#include <utility>

namespace helpers {
void f();
}

// A macro to generate `T(const T&)` that may be followed by `= default;` or `=
// delete;` etc.
#define COPY_CTOR(NAME) NAME(const NAME &)

// A macro to generate `T(T&&)` that may be followed by `= default;` or `=
// delete;` etc.
#define MOVE_CTOR(NAME) NAME(NAME &&)

// A macro to generate `T& operator=(const T&)` that may be followed by `=
// default;` or `= delete;` etc.
#define COPY_ASSIGN(NAME) NAME &operator=(const NAME &)

// A macro to generate `T& operator=(T&&)` that may be followed by `= default;`
// or `= delete;` etc.
#define MOVE_ASSIGN(NAME) NAME &operator=(NAME &&)

// A macro to generate `~T()` that may be followed by `= default;` or `=
// delete;` etc.
#define DTOR(NAME) ~NAME()

// clang-format off
// A macro to generate all five special member functions for a class `NAME`
// with the ability to specify for each whether it is `= default;`, `= delete;`,
// or a non-trivial definition via the corresponding `_SPEC` parameter.
#define DEFINE_ALL_SPECIAL_MEMBERS(NAME,                                           \
    COPY_CTOR_SPEC, MOVE_CTOR_SPEC, COPY_ASSIGN_SPEC, MOVE_ASSIGN_SPEC, DTOR_SPEC) \
  COPY_CTOR(NAME) COPY_CTOR_SPEC     /* T(const T&) = default; */                  \
  MOVE_CTOR(NAME) MOVE_CTOR_SPEC     /* T(T&&) = default; */                       \
  COPY_ASSIGN(NAME) COPY_ASSIGN_SPEC /* T& operator=(const T&) = default; */       \
  MOVE_ASSIGN(NAME) MOVE_ASSIGN_SPEC /* T& operator=(T&&) = default; */            \
  DTOR(NAME) DTOR_SPEC               /* ~T() = default; */

// Macros to generate `= default;`, `= delete;`, or a non-trivial definition for a
// special member function.
#define DEFAULTED = default;
#define DELETED = delete;
#define CUSTOMIZED { helpers::f(); }
// clang-format on

namespace fully_specified {
/**
 * Go through all combinations of defaulted and deleted copy/move
 * ctor/assignment.
 */
namespace combinations {

// NOTE: THIS USES THE MISRA SPECIFICATION TABLE ORDER (move ctor, move assign,
// copy ctor, copy assign) AND NOT THE ORDER OF `DEFINE_ALL_SPECIAL_MEMBERS`
// (copy ctor, move ctor, copy assign, move assign) !!!!!!!
#define TABLE_ROW(NAME, MOVE_CTOR_SPEC, MOVE_ASSIGN_SPEC, COPY_CTOR_SPEC,      \
                  COPY_ASSIGN_SPEC)                                            \
  class NAME {                                                                 \
    int x;                                                                     \
                                                                               \
  public:                                                                      \
    DEFINE_ALL_SPECIAL_MEMBERS(NAME, COPY_CTOR_SPEC, MOVE_CTOR_SPEC,           \
                               COPY_ASSIGN_SPEC, MOVE_ASSIGN_SPEC, DEFAULTED)  \
  };

// clang-format off
#define YES DEFAULTED
#define NO  DELETED
// See `TABLE_ROW` for ordering notes!! This matches the table from the spec.
TABLE_ROW(C1,  YES, YES, YES, YES) // COMPLIANT - Copy-enabled
TABLE_ROW(C2,  YES, YES, YES, NO ) // NON_COMPLIANT
TABLE_ROW(C3,  YES, YES, NO,  YES) // NON_COMPLIANT
TABLE_ROW(C4,  YES, YES, NO,  NO ) // COMPLIANT - Move-only
TABLE_ROW(C5,  YES, NO,  YES, YES) // NON_COMPLIANT
TABLE_ROW(C6,  YES, NO,  YES, NO ) // COMPLIANT - Copy-enabled
TABLE_ROW(C7,  YES, NO,  NO,  YES) // NON_COMPLIANT
TABLE_ROW(C8,  YES, NO,  NO,  NO ) // COMPLIANT - Move-only
TABLE_ROW(C9,  NO,  YES, YES, YES) // NON_COMPLIANT
TABLE_ROW(C10, NO,  YES, YES, NO ) // NON_COMPLIANT
TABLE_ROW(C11, NO,  YES, NO,  YES) // NON_COMPLIANT
TABLE_ROW(C12, NO,  YES, NO,  NO ) // NON_COMPLIANT
TABLE_ROW(C13, NO,  NO,  YES, YES) // NON_COMPLIANT
TABLE_ROW(C14, NO,  NO,  YES, NO ) // NON_COMPLIANT
TABLE_ROW(C15, NO,  NO,  NO,  YES) // NON_COMPLIANT
TABLE_ROW(C16, NO,  NO,  NO,  NO ) // COMPLIANT - Unmovable
// clang-format on

#undef YES
#undef NO
#undef TABLE_ROW
} // namespace combinations

class AllPrivate { // COMPLIANT -- unmovable
private:
  int x;

public:
  DEFINE_ALL_SPECIAL_MEMBERS(AllPrivate, DEFAULTED, DEFAULTED, DEFAULTED,
                             DEFAULTED, DEFAULTED)
};

class PrivateCopyCtor { // NON_COMPLIANT
  int x;

private:
  COPY_CTOR(PrivateCopyCtor) = default;

public:
  MOVE_CTOR(PrivateCopyCtor) = default;
  COPY_ASSIGN(PrivateCopyCtor) = default;
  MOVE_ASSIGN(PrivateCopyCtor) = default;
  DTOR(PrivateCopyCtor) = default;
};

class PrivateMoveCtor { // NON_COMPLIANT
  int x;

private:
  MOVE_CTOR(PrivateMoveCtor) = default;

public:
  COPY_CTOR(PrivateMoveCtor) = default;
  COPY_ASSIGN(PrivateMoveCtor) = default;
  MOVE_ASSIGN(PrivateMoveCtor) = default;
  DTOR(PrivateMoveCtor) = default;
};

class PrivateCopyAssign { // NON_COMPLIANT
  int x;

private:
  COPY_ASSIGN(PrivateCopyAssign) = default;

public:
  COPY_CTOR(PrivateCopyAssign) = default;
  MOVE_CTOR(PrivateCopyAssign) = default;
  MOVE_ASSIGN(PrivateCopyAssign) = default;
  DTOR(PrivateCopyAssign) = default;
};

class PrivateMoveAssign { // NON_COMPLIANT
  int x;

private:
  MOVE_ASSIGN(PrivateMoveAssign) = default;

public:
  COPY_CTOR(PrivateMoveAssign) = default;
  MOVE_CTOR(PrivateMoveAssign) = default;
  COPY_ASSIGN(PrivateMoveAssign) = default;
  DTOR(PrivateMoveAssign) = default;
};

namespace additional_requirements {

// A class with a customized copy constructor requires a customized destructor
class CustomizedMoveCtorCompliant { // COMPLIANT: move-only (1)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveCtorCompliant, DELETED, CUSTOMIZED,
                             DELETED, DELETED, CUSTOMIZED)
};

class CustomizedCtorsCompliant { // COMPLIANT: copy-enabled (1)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCtorsCompliant, CUSTOMIZED, CUSTOMIZED,
                             DELETED, DELETED, CUSTOMIZED)
};

class CustomizedMoveAssignCompliant { // COMPLIANT: move-only (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveAssignCompliant, DELETED, CUSTOMIZED,
                             DELETED, CUSTOMIZED, CUSTOMIZED)
};

class CustomizedAssignsCompliant { // COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedAssignsCompliant, CUSTOMIZED, CUSTOMIZED,
                             CUSTOMIZED, CUSTOMIZED, CUSTOMIZED)
};

// copy-enabled (2)
class CustomizedCopyCtorDefaultedNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyCtorDefaultedNonCompliant,
                             CUSTOMIZED, DEFAULTED, DEFAULTED, DEFAULTED,
                             DEFAULTED)
};

class CustomizedCopyCtorDeletedNonCompliant { // NON_COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyCtorDeletedNonCompliant, CUSTOMIZED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DELETED)
};

class CustomizedMoveCtorNonCompliant { // NON_COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveCtorNonCompliant, DEFAULTED,
                             CUSTOMIZED, DEFAULTED, DEFAULTED, DEFAULTED)
};

class CustomizedCopyAssignNonCompliant { // NON_COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyAssignNonCompliant, DEFAULTED,
                             DEFAULTED, CUSTOMIZED, DEFAULTED, DEFAULTED)
};

class CustomizedMoveAssignNonCompliant { // NON_COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveAssignNonCompliant, CUSTOMIZED,
                             CUSTOMIZED, DEFAULTED, CUSTOMIZED, DEFAULTED)
};

// Move-only with a customized dtor requires customized move constructor.
class MoveOnlyNotCustomizedNonCompliant { // NON_COMPLIANT: move-only (1)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyNotCustomizedNonCompliant, DELETED,
                             DEFAULTED, DELETED, DELETED, CUSTOMIZED)
};

// Move-only with a customized dtor requires customized move assignment
// operator.
// move-only (2)
class MoveOnlyAssignableNotCustomizedNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableNotCustomizedNonCompliant,
                             DELETED, DEFAULTED, DELETED, DEFAULTED, CUSTOMIZED)
};

// customized move: move-only (1)
class MoveOnlyCustomizedCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyCustomizedCompliant, DELETED, CUSTOMIZED,
                             DELETED, DELETED, CUSTOMIZED)
};

// customized move: move-only (2)
class MoveOnlyAssignableCustomizedCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableCustomizedCompliant, DELETED,
                             CUSTOMIZED, DELETED, CUSTOMIZED, CUSTOMIZED)
};

// default dtor: move-only (1)
class MoveOnlyNotCustomizedCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyNotCustomizedCompliant, DELETED, DEFAULTED,
                             DELETED, DELETED, DEFAULTED)
};

// default dtor: move-only (2)
class MoveOnlyAssignableNotCustomizedCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableNotCustomizedCompliant, DELETED,
                             DEFAULTED, DELETED, DEFAULTED, DEFAULTED)
};

// Copy-enabled with customized dtor requires customized copy and move
class CopyEnabledCustomizedDtorNonCompliant { // NON_COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledCustomizedDtorNonCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, DEFAULTED, CUSTOMIZED)
};

class CopyEnabledNonCustomizedDtorCompliant { // COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledNonCustomizedDtorCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DEFAULTED)
};

class CopyEnabledCustomizedDtorCompliant1 { // COMPLIANT: copy-enabled (2)
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledCustomizedDtorCompliant1, CUSTOMIZED,
                             CUSTOMIZED, CUSTOMIZED, CUSTOMIZED, CUSTOMIZED)
};

class CopyEnabledCustomizedDtorCompliant2 { // COMPLIANT: copy-enabled (2)
public:
  COPY_CTOR(CopyEnabledCustomizedDtorCompliant2) CUSTOMIZED;
  // No move constructor declared
  COPY_ASSIGN(CopyEnabledCustomizedDtorCompliant2) DELETED;
  MOVE_ASSIGN(CopyEnabledCustomizedDtorCompliant2) DELETED;
  ~CopyEnabledCustomizedDtorCompliant2() CUSTOMIZED;
};

// copy-assignable class with both move operations not declared
class CopyAssignableCustomizedDtorCompliant1 { // COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorCompliant1) CUSTOMIZED;
  // Move constructor is not declared
  COPY_ASSIGN(CopyAssignableCustomizedDtorCompliant1) CUSTOMIZED;
  // Move assignment operator is not declared
  DTOR(CopyAssignableCustomizedDtorCompliant1) CUSTOMIZED
};

// copy-assignable class with only one of move operations not declared
class CopyAssignableCustomizedDtorNonCompliant1 { // NON_COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorNonCompliant1) CUSTOMIZED;
  MOVE_CTOR(CopyAssignableCustomizedDtorNonCompliant1) CUSTOMIZED;
  COPY_ASSIGN(CopyAssignableCustomizedDtorNonCompliant1) CUSTOMIZED;
  // Move assignment operator is not declared
  DTOR(CopyAssignableCustomizedDtorNonCompliant1) CUSTOMIZED;
};

// copy-assignable class with only one of move operations not declared
class CopyAssignableCustomizedDtorNonCompliant2 { // NON_COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorNonCompliant2) CUSTOMIZED;
  // Move constructor is not declared
  COPY_ASSIGN(CopyAssignableCustomizedDtorNonCompliant2) CUSTOMIZED;
  MOVE_ASSIGN(CopyAssignableCustomizedDtorNonCompliant2) CUSTOMIZED;
  DTOR(CopyAssignableCustomizedDtorNonCompliant2) CUSTOMIZED;
};

// copy-assignable class with only a copy operation not declared
class CopyAssignableCustomizedDtorNonCompliant3 { // NON_COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorNonCompliant3) CUSTOMIZED;
  MOVE_CTOR(CopyAssignableCustomizedDtorNonCompliant3) CUSTOMIZED;
  // Copy assignment operator is not declared
  MOVE_ASSIGN(CopyAssignableCustomizedDtorNonCompliant3) CUSTOMIZED;
  DTOR(CopyAssignableCustomizedDtorNonCompliant3) CUSTOMIZED;
};

// copy-assignable class with only one of move operations not declared
class CopyAssignableCustomizedDtorNonCompliant4 { // NON_COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorNonCompliant4) CUSTOMIZED;
  MOVE_CTOR(CopyAssignableCustomizedDtorNonCompliant4) DEFAULTED;
  COPY_ASSIGN(CopyAssignableCustomizedDtorNonCompliant4) CUSTOMIZED;
  // Move assignment operator is not declared
  DTOR(CopyAssignableCustomizedDtorNonCompliant4) CUSTOMIZED;
};

// copy-assignable class with only one of move operations not declared
class CopyAssignableCustomizedDtorNonCompliant5 { // NON_COMPLIANT
public:
  COPY_CTOR(CopyAssignableCustomizedDtorNonCompliant5) CUSTOMIZED;
  // Move constructor is not declared
  COPY_ASSIGN(CopyAssignableCustomizedDtorNonCompliant5) CUSTOMIZED;
  MOVE_ASSIGN(CopyAssignableCustomizedDtorNonCompliant5) DEFAULTED;
  DTOR(CopyAssignableCustomizedDtorNonCompliant5) CUSTOMIZED;
};

// A public unmovable base class shall have a public virtual destructor
class UnmovableBaseNonvirtualDtor { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(UnmovableBaseNonvirtualDtor, DELETED, DELETED,
                             DELETED, DELETED, DEFAULTED)
};

// NON_COMPLIANT - reported by the audit query for having missing info.
class UnmovableNonvirtualDerived : public UnmovableBaseNonvirtualDtor {};

class UnmovableBasePublicVirtualDtor { // COMPLIANT
public:
  COPY_CTOR(UnmovableBasePublicVirtualDtor) = delete;
  MOVE_CTOR(UnmovableBasePublicVirtualDtor) = delete;
  COPY_ASSIGN(UnmovableBasePublicVirtualDtor) = delete;
  MOVE_ASSIGN(UnmovableBasePublicVirtualDtor) = delete;

  virtual ~UnmovableBasePublicVirtualDtor() = default;
};

// NON_COMPLIANT - reported by the audit query for having missing info.
class UnmovableDerivedPublicVirtualDtor
    : public UnmovableBasePublicVirtualDtor {};

class UnmovablePrivateVirtualDtor { // NON_COMPLIANT
public:
  COPY_CTOR(UnmovablePrivateVirtualDtor) = delete;
  MOVE_CTOR(UnmovablePrivateVirtualDtor) = delete;
  COPY_ASSIGN(UnmovablePrivateVirtualDtor) = delete;
  MOVE_ASSIGN(UnmovablePrivateVirtualDtor) = delete;

private:
  virtual ~UnmovablePrivateVirtualDtor() = default;
};

// NON_COMPLIANT - reported by the audit query for having missing info.
class UnmovablePrivateVirtualDtorDerived : public UnmovablePrivateVirtualDtor {
};

class BaseProtectedDtor { // COMPLIANT
public:
  COPY_CTOR(BaseProtectedDtor) = default;
  MOVE_CTOR(BaseProtectedDtor) = default;
  COPY_ASSIGN(BaseProtectedDtor) = delete;
  MOVE_ASSIGN(BaseProtectedDtor) = delete;

protected:
  ~BaseProtectedDtor() = default;
};

// NON_COMPLIANT - reported by the audit query for having missing info.
class ProtectedDtorDerived : public BaseProtectedDtor {};

class BaseVirtualProtectedDtor { // NON_COMPLIANT
public:
  COPY_CTOR(BaseVirtualProtectedDtor) = default;
  MOVE_CTOR(BaseVirtualProtectedDtor) = default;
  COPY_ASSIGN(BaseVirtualProtectedDtor) = delete;
  MOVE_ASSIGN(BaseVirtualProtectedDtor) = delete;

protected:
  virtual ~BaseVirtualProtectedDtor() = default;
};

// NON_COMPLIANT - reported by the audit query for having missing info.
class VirtualProtectedDtorDerived : public BaseVirtualProtectedDtor {};

} // namespace additional_requirements

} // namespace fully_specified

namespace implicit_special_members {

struct PodClass { // COMPLIANT - we know PODs are OK.
  int x;
  int y;
};

struct TrivialClass { // NON_COMPLIANT - audit result
  int x;
  int y;
  COPY_CTOR(TrivialClass) = default;
};

class NonTrivialClass { // NON_COMPLIANT - audit result
  int x;
  int y;

public:
  ~NonTrivialClass() { x = 1; }
};

// CodeQL resolves and stores all of the special member functions in the
// database for this class, so it is not an audit query result.
class NonTrivialDestructor { // NON_COMPLIANT - uncustomized copy ops.
  int x;
  int y;

public:
  COPY_CTOR(NonTrivialDestructor) = default;
  ~NonTrivialDestructor() { x = 1; }
};

// This class is not a valid category but hard to analyze in the general case.
// This should not be reported as a violation except by the audit query.
class CopyOnly { // NON_COMPLIANT - audit result
  COPY_CTOR(CopyOnly) = default;
  MOVE_CTOR(CopyOnly) = delete;
  MOVE_ASSIGN(CopyOnly) = delete;
};

// this class should not appear in the audit results, because we have all
// members in the database even though they aren't all explicitly declared
class OdrUsedMoveEnabled { // COMPLIANT
  NonTrivialClass x;

public:
  // copy operations are generated as deleted
  MOVE_CTOR(OdrUsedMoveEnabled) = default;
  MOVE_ASSIGN(OdrUsedMoveEnabled) = default;
  // destructor is generated as defaulted since it's non trivial and ODR-used.
};

void f(OdrUsedMoveEnabled o) {
  // This function ensures the non-trivial destructor is ODR-used.
  OdrUsedMoveEnabled o3 = std::move(o);
  o3 = std::move(o);
}

} // namespace implicit_special_members
