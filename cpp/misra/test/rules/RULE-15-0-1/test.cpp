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

class CustomizedCopyCtorCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyCtorCompliant, CUSTOMIZED, DEFAULTED,
                             DEFAULTED, DEFAULTED, CUSTOMIZED)
};

class CustomizedMoveCtorCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveCtorCompliant, DEFAULTED, CUSTOMIZED,
                             DEFAULTED, DEFAULTED, CUSTOMIZED)
};

class CustomizedCopyAssignCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyAssignCompliant, DEFAULTED,
                             DEFAULTED, CUSTOMIZED, DEFAULTED, CUSTOMIZED)
};

class CustomizedMoveAssignCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveAssignCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, CUSTOMIZED, CUSTOMIZED)
};

class CustomizedCopyCtorDefaultDtor { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyCtorDefaultDtor, CUSTOMIZED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DEFAULTED)
};

class CustomizedCopyCtorDeletedDtor { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyCtorDeletedDtor, CUSTOMIZED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DELETED)
};

class CustomizedMoveCtorNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveCtorNonCompliant, CUSTOMIZED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DEFAULTED)
};

class CustomizedCopyAssignNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedCopyAssignNonCompliant, DEFAULTED,
                             DEFAULTED, CUSTOMIZED, DEFAULTED, DEFAULTED)
};

class CustomizedMoveAssignNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CustomizedMoveAssignNonCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, CUSTOMIZED, DEFAULTED)
};

// Move-only with a customized dtor requires customized move operations.
class MoveOnlyNotCustomizedNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyNotCustomizedNonCompliant, DELETED,
                             DEFAULTED, DELETED, DELETED, CUSTOMIZED)
};

// Move-only with a customized dtor requires customized move operations.
class MoveOnlyAssignableNotCustomizedNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableNotCustomizedNonCompliant,
                             DELETED, DEFAULTED, DELETED, DEFAULTED, CUSTOMIZED)
};

class MoveOnlyCustomizedCompliant { // COMPLIANT -- customized move
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyCustomizedCompliant, DELETED, CUSTOMIZED,
                             DELETED, DELETED, CUSTOMIZED)
};

class MoveOnlyAssignableCustomizedCompliant { // COMPLIANT -- customized move
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableCustomizedCompliant, DELETED,
                             CUSTOMIZED, DELETED, CUSTOMIZED, CUSTOMIZED)
};

class MoveOnlyNotCustomizedCompliant { // COMPLIANT -- default dtor
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyNotCustomizedCompliant, DELETED, DEFAULTED,
                             DELETED, DELETED, DEFAULTED)
};

class MoveOnlyAssignableNotCustomizedCompliant { // COMPLIANT -- default dtor
public:
  DEFINE_ALL_SPECIAL_MEMBERS(MoveOnlyAssignableNotCustomizedCompliant, DELETED,
                             DEFAULTED, DELETED, DEFAULTED, DEFAULTED)
};

// Copy-enabled with customized dtor requires customized copy and move
class CopyEnabledCustomizedDtorNonCompliant { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledCustomizedDtorNonCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, DEFAULTED, CUSTOMIZED)
};

class CopyEnabledNonCustomizedDtorCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledNonCustomizedDtorCompliant, DEFAULTED,
                             DEFAULTED, DEFAULTED, DEFAULTED, DEFAULTED)
};

class CopyEnabledCustomizedDtorCompliant { // COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(CopyEnabledCustomizedDtorCompliant, CUSTOMIZED,
                             CUSTOMIZED, CUSTOMIZED, CUSTOMIZED, CUSTOMIZED)
};

// A public unmovable base class shall have a public virtual destructor
class UnmovableBaseNonvirtualDtor { // NON_COMPLIANT
public:
  DEFINE_ALL_SPECIAL_MEMBERS(UnmovableBaseNonvirtualDtor, DELETED, DELETED,
                             DELETED, DELETED, DEFAULTED)
};

class UnmovableNonvirtualDerived : public UnmovableBaseNonvirtualDtor {};

class UnmovableBasePublicVirtualDtor { // COMPLIANT
public:
  COPY_CTOR(UnmovableBasePublicVirtualDtor) = delete;
  MOVE_CTOR(UnmovableBasePublicVirtualDtor) = delete;
  COPY_ASSIGN(UnmovableBasePublicVirtualDtor) = delete;
  MOVE_ASSIGN(UnmovableBasePublicVirtualDtor) = delete;

  virtual ~UnmovableBasePublicVirtualDtor() = default;
};

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

class UnmovablePrivateVirtualDtorDerived : public UnmovablePrivateVirtualDtor {
};

class BaseProtectedDtor { // COMPLIANT
public:
  COPY_CTOR(BaseProtectedDtor) = default;
  MOVE_CTOR(BaseProtectedDtor) = default;
  COPY_ASSIGN(BaseProtectedDtor) = default;
  MOVE_ASSIGN(BaseProtectedDtor) = delete;

protected:
  ~BaseProtectedDtor() = default;
};

class ProtectedDtorDerived : public BaseProtectedDtor {};

class BaseVirtualProtectedDtor { // NON_COMPLIANT
public:
  COPY_CTOR(BaseVirtualProtectedDtor) = default;
  MOVE_CTOR(BaseVirtualProtectedDtor) = default;
  COPY_ASSIGN(BaseVirtualProtectedDtor) = default;
  MOVE_ASSIGN(BaseVirtualProtectedDtor) = delete;

protected:
  virtual ~BaseVirtualProtectedDtor() = default;
};

class VirtualProtectedDtorDerived : public BaseVirtualProtectedDtor {};

} // namespace additional_requirements

} // namespace fully_specified
