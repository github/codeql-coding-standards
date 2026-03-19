#include <cstdint>
#include <string>

class MemberInitConstant {
  MemberInitConstant() : m1{42} {} // COMPLIANT
  std::int32_t m1;
};

class MemberInitializer {
  MemberInitializer() {}
  std::int32_t m1 = 0; // COMPLIANT
};

class MemberInitArg {
  MemberInitArg(std::int32_t p1 = 0) : m1{p1} {} // COMPLIANT
  std::int32_t m1;
};

class MemberHasCtor {
  MemberHasCtor() {}
  std::string m1; // COMPLIANT
};

class MemberStatic {
  MemberStatic() {} // COMPLIANT
  static std::int32_t m1;
};

class CtorDeleted {
  CtorDeleted() = delete; // COMPLIANT
  std::int32_t m1;
};

class MemberUninit {
  MemberUninit() {} // NON_COMPLIANT
  std::int32_t m1;
};

class MemberUninitEmpty {
  MemberUninitEmpty() : m1{} {} // COMPLIANT
  std::int32_t m1;
};

class MemberUninitArray {
  MemberUninitArray() {} // NON_COMPLIANT
  std::int32_t m1[5];
};

class MemberUninitPointer {
  MemberUninitPointer() {} // NON_COMPLIANT
  std::int32_t *m1;
};

class MemberUninitAndInit {
  MemberUninitAndInit() : m2{0} {} // NON_COMPLIANT
  std::int32_t m1;
  std::int32_t m2;
};

class MultipleCtors {
public:
  MultipleCtors(int a) {}           // NON_COMPLIANT
  MultipleCtors(float b) : m1{0} {} // COMPLIANT
  MultipleCtors() : m1{0} {}        // COMPLIANT
  std::int32_t m1;
};

class MemorCtorInitCompliant {
  MemorCtorInitCompliant(float x) : m1(x) {} // COMPLIANT
  MultipleCtors m1;
};

class DefaultedCtorUninit {
  DefaultedCtorUninit() = default; // NON_COMPLIANT
  std::int32_t m2;
};

class DefaultedCopyMove {
  DefaultedCopyMove(const DefaultedCopyMove &) = default; // COMPLIANT
  DefaultedCopyMove(DefaultedCopyMove &&) = default;      // COMPLIANT
  std::int32_t m1;
};

class CopyMoveUninit {
  CopyMoveUninit(const CopyMoveUninit &) {} // NON_COMPLIANT
  CopyMoveUninit(CopyMoveUninit &&) {}      // NON_COMPLIANT
  std::int32_t m1;
};

class CopyMoveInit {
  CopyMoveInit(const CopyMoveInit &other) : m1{other.m1} {} // COMPLIANT
  CopyMoveInit(CopyMoveInit &&other) : m1{other.m1} {}      // COMPLIANT
  std::int32_t m1;
};

class DelegatingCtorSameClassCompliant {
  DelegatingCtorSameClassCompliant(std::int32_t p1) : m1{p1} {} // COMPLIANT
  DelegatingCtorSameClassCompliant()
      : DelegatingCtorSameClassCompliant(0) {} // COMPLIANT
  std::int32_t m1;
};

class DelegatingCtorSameClassNonCompliant {
  DelegatingCtorSameClassNonCompliant(std::int32_t p1) {} // NON_COMPLIANT
  // A delegating constructor cannot initialize members, so we should not report
  // it.
  DelegatingCtorSameClassNonCompliant()
      : DelegatingCtorSameClassNonCompliant(0) {} // COMPLIANT
  std::int32_t m1;
};

class DelegatingCtorBaseCompliant {
public:
  DelegatingCtorBaseCompliant() : m1{m1} {} // COMPLIANT
  std::int32_t m1;
};

class DelegatingCtorBaseNonCompliant {
public:
  DelegatingCtorBaseNonCompliant() {} // NON_COMPLIANT
  std::int32_t m1;
};

class DelegateToCompliantBase : public DelegatingCtorBaseCompliant {
  DelegateToCompliantBase() : DelegatingCtorBaseCompliant{} {} // COMPLIANT
};

class DelegateToNonCompliantBase : public DelegatingCtorBaseCompliant {
  // A constructor cannot initialize members of a base class, so this
  // constructor should not be reported.
  DelegateToNonCompliantBase() : DelegatingCtorBaseCompliant{} {} // COMPLIANT
};

class DelegateCompliantNoMembers : public DelegateToCompliantBase {
  // A using declaration is fine with no fields to initialize.
  using DelegateToCompliantBase::DelegateToCompliantBase; // COMPLIANT
};

class DelegateCompliantMemberInit : public DelegateToCompliantBase {
  // A using declaration is fine with no fields to initialize.
  using DelegateToCompliantBase::DelegateToCompliantBase; // COMPLIANT
  std::int32_t m1 = 0;
};

class DelegateNonCompliantMemberUninit : public DelegateToNonCompliantBase {
  // using declaration cannot initialize m1
  using DelegateToNonCompliantBase::DelegateToNonCompliantBase; // NON_COMPLIANT
  std::int32_t m1;
};

class UsingSelfConstructor {
  UsingSelfConstructor() : m1{0} {} // COMPLIANT
  // useless, but allowed. We don't handle this.
  using UsingSelfConstructor::UsingSelfConstructor; // COMPLIANT
  std::int32_t m1;
};

class UsingAliasUnrelated {
  UsingAliasUnrelated() : m1(0) {} // COMPLIANT
  // Not a `UsingDeclarationEntry`, should be compliant.
  using string = std::string; // COMPLIANT
  // A `UsingDeclarationEntry` that doesn't introduce a constructor should be
  // compliant.
  using std::string::basic_string; // COMPLIANT
  std::int32_t m1;
};

struct AggregateFieldCtor {
  std::string m1;
};

struct AggregateFieldNSDMI {
  std::int32_t m1 = 0;
};

struct AggregateFieldUninit {
  std::int32_t m1;
};

struct AggregateOfCompliantAggregates {
  AggregateFieldCtor m1;
  AggregateFieldNSDMI m2;
};

struct AggregateOfNonCompliantAggregate {
  AggregateFieldUninit m1;
};

void test_aggregates() {
  AggregateFieldCtor l1;       // COMPLIANT
  new AggregateFieldCtor;      // COMPLIANT
  new AggregateFieldCtor{};    // COMPLIANT
  new AggregateFieldCtor();    // COMPLIANT
  new AggregateFieldCtor[5];   // COMPLIANT
  new AggregateFieldCtor[5]{}; // COMPLIANT

  AggregateFieldNSDMI l2;             // COMPLIANT
  AggregateOfCompliantAggregates l3;  // COMPLIANT
  new AggregateFieldNSDMI;            // COMPLIANT
  new AggregateOfCompliantAggregates; // COMPLIANT

  AggregateFieldUninit l4;                          // NON_COMPLIANT
  AggregateFieldUninit l5 = {};                     // COMPLIANT
  AggregateFieldUninit l6{};                        // COMPLIANT
  AggregateFieldUninit l7 = AggregateFieldUninit{}; // COMPLIANT
  AggregateFieldUninit l8 = AggregateFieldUninit(); // COMPLIANT
  AggregateFieldUninit l9[5];                       // NON_COMPLIANT
  AggregateFieldUninit l10[5] = {};                 // COMPLIANT
  AggregateFieldUninit l11[5]{};                    // COMPLIANT
  new AggregateFieldUninit;                         // NON_COMPLIANT
  new AggregateFieldUninit{};                       // COMPLIANT
  new AggregateFieldUninit();                       // COMPLIANT
  new AggregateFieldUninit[5];                      // NON_COMPLIANT
  new AggregateFieldUninit[5]{};                    // COMPLIANT
  new AggregateFieldUninit[5]();                    // COMPLIANT

  AggregateOfNonCompliantAggregate l12;         // NON_COMPLIANT
  AggregateOfNonCompliantAggregate l13 = {};    // COMPLIANT
  AggregateOfNonCompliantAggregate l14{};       // COMPLIANT
  AggregateOfNonCompliantAggregate l15[5];      // NON_COMPLIANT
  AggregateOfNonCompliantAggregate l16[5] = {}; // COMPLIANT
  new AggregateOfNonCompliantAggregate;         // NON_COMPLIANT
  new AggregateOfNonCompliantAggregate{};       // COMPLIANT
  new AggregateOfNonCompliantAggregate();       // COMPLIANT

  new int;    // COMPLIANT
  new int[5]; // COMPLIANT
  new int *;  // COMPLIANT
}

class HasAggregateMemberCompliant {
  HasAggregateMemberCompliant() : m3{0}, m5{0} {}
  AggregateFieldCtor m1;
  AggregateFieldNSDMI m2;
  AggregateFieldUninit m3;
  AggregateOfCompliantAggregates m4;
  AggregateOfNonCompliantAggregate m5;
};

class HasAggregateMemberNonCompliant {
  HasAggregateMemberNonCompliant() {} // NON_COMPLIANT
  AggregateFieldUninit m1;
  AggregateOfNonCompliantAggregate m2;
};

class HasAggregateMemberCompliantInit {
  HasAggregateMemberCompliantInit() {}
  AggregateFieldUninit m1 = {};
  AggregateOfNonCompliantAggregate m2 = {};
};

class HasUninitArrayAggregateMemberNonCompliant {
  HasUninitArrayAggregateMemberNonCompliant() {} // NON_COMPLIANT
  AggregateFieldUninit m1[5];
};