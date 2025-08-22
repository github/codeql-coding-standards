#include <iostream>
#include <utility>
#include <vector>

// Our database doesn't always contain implicitly defined special member
// functions, which we need to know in order to say if a class is copy or move
// assignable or constructible.
//
// This is very tricky to get right. So we don't merely have cases defined here
// with a .expected file. Instead we also ensure this file is compilable and use
// static_assert to check that our test itself is correct.
//
// We can also then generate the .expected file that matches these
// static_asserts.

// Save the expected lines here, to be initialized by EXPECT_SMF(), then sorted
// and printed by main().
std::vector<std::string> cc_vec;
std::vector<std::string> ca_vec;
std::vector<std::string> mc_vec;
std::vector<std::string> ma_vec;

// Generate a test for a class CLASS with the expected values for
// copy-constructible (CC), move-constructible (MC), copy-assignable (CA) and
// move-assignable (MA), and run the test at global initialization time.
//
// Separate the namespace and class name so that we can print the fully
// qualified name in the output, but also, so we can ensure the macro doesn't
// refer to classes from a different namespace than intended.
#define EXPECT_COPYABLE(NS, CLASS, CONSTRUCT, ASSIGN)                          \
  inline void testCopyable_##CLASS() {                                         \
    expect_copyable<CLASS, NS::CLASS, CONSTRUCT, ASSIGN>(#NS "::" #CLASS);     \
  }                                                                            \
  int dummy_copyable_##CLASS = (testCopyable_##CLASS(), 0);

#define EXPECT_MOVABLE(NS, CLASS, CONSTRUCT, ASSIGN)                           \
  inline void testMovable_##CLASS() {                                          \
    expect_movable<CLASS, NS::CLASS, CONSTRUCT, ASSIGN>(#NS "::" #CLASS);      \
  }                                                                            \
  int dummy_movable_##CLASS = (testMovable_##CLASS(), 0);

// Perform the static asserts and record the results.
//
// WARNING!
//
// The type trait std::is_move_constructible<T> will return true for copy
// constructible type with no move constructor. This is because
// is_move_constructible checks if T(declval<T&&>()) is a valid expression, and
// if this resolves to a copy constructor, then the `declval<T&&>()` decays to a
// `T&`. The type traits std::is_move_*<T> are only false for copy
// constructible/assignable types which have explicitly deleted move
// constructors/assignments.
template <typename T, typename FQ, bool CC, bool MC, bool CA, bool MA>
void expect_smf(std::string class_name) {
  // See EXPECT_SMF on why we separate T and FQ, one is unqualified, the other
  // is fully qualified. If they are different, the macro invocation was wrong.
  static_assert(std::is_same<T, FQ>::value, "T and FQ should be the same type");
  static_assert(std::is_copy_constructible<T>::value == CC,
                "Incorrect copy constructible value");
  static_assert(std::is_move_constructible<T>::value == MC,
                "Incorrect move constructible value");
  static_assert(std::is_copy_assignable<T>::value == CA,
                "Incorrect copy assignable value");
  static_assert(std::is_move_assignable<T>::value == MA,
                "Incorrect move assignable value");

  cc_vec.push_back(class_name + " | " + (CC ? "true" : "false"));
  ca_vec.push_back(class_name + " | " + (CA ? "true" : "false"));
  mc_vec.push_back(class_name + " | " + (MC ? "true" : "false"));
  ma_vec.push_back(class_name + " | " + (MA ? "true" : "false"));
}

template <typename T, typename FQ, bool Construct, bool Assign>
void expect_copyable(std::string class_name) {
  // See EXPECT_COPYABLE on why we separate T and FQ, one is unqualified, the
  // other is fully qualified. If they are different, the macro invocation was
  // wrong.
  static_assert(std::is_same<T, FQ>::value, "T and FQ should be the same type");
  static_assert(std::is_copy_constructible<T>::value == Construct,
                "Incorrect copy constructible value");
  static_assert(std::is_copy_assignable<T>::value == Assign,
                "Incorrect copy assignable value");

  cc_vec.push_back(class_name + " | " + (Construct ? "true" : "false"));
  ca_vec.push_back(class_name + " | " + (Assign ? "true" : "false"));
}

template <typename T, typename FQ, bool Construct, bool Assign>
void expect_movable(std::string class_name) {
  // See EXPECT_MOVABLE on why we separate T and FQ, one is unqualified, the
  // other is fully qualified. If they are different, the macro invocation was
  // wrong.
  static_assert(std::is_same<T, FQ>::value, "T and FQ should be the same type");
  static_assert(std::is_move_constructible<T>::value == Construct,
                "Incorrect move constructible value");
  static_assert(std::is_move_assignable<T>::value == Assign,
                "Incorrect move assignable value");

  mc_vec.push_back(class_name + " | " + (Construct ? "true" : "false"));
  ma_vec.push_back(class_name + " | " + (Assign ? "true" : "false"));
}

int main() {
  std::cout << "copy constructible" << std::endl;
  for (const auto &s : cc_vec) {
    std::cout << "| " << s << " |" << std::endl;
  }
  std::cout << "copy assignable" << std::endl;
  for (const auto &s : ca_vec) {
    std::cout << "| " << s << " |" << std::endl;
  }
  std::cout << "move constructible" << std::endl;
  for (const auto &s : mc_vec) {
    std::cout << "| " << s << " |" << std::endl;
  }
  std::cout << "move assignable" << std::endl;
  for (const auto &s : ma_vec) {
    std::cout << "| " << s << " |" << std::endl;
  }
}

namespace N1 {
// Empty class: all special member functions are implicitly defined.
class C1 {};
EXPECT_COPYABLE(N1, C1, true, true)
EXPECT_MOVABLE(N1, C1, true, true)
} // namespace N1

namespace N2 {
// Class with simple members: all special member functions are implicitly
// defined.
class C1 {
  int i;
  double d;
  std::string s;
};
EXPECT_COPYABLE(N2, C1, true, true)
EXPECT_MOVABLE(N2, C1, true, true)
} // namespace N2

namespace N3 {
// Class with a public user-declared copy constructor.
class C1 {
public:
  // Suppresses the implicit move constructor and move assignment operator.
  C1(const C1 &other) { /* stub */ }
};
EXPECT_COPYABLE(N3, C1, true, true)
EXPECT_MOVABLE(N3, C1, true, true)
}; // namespace N3

namespace N4 {
// Class with a private user-declared copy constructor.
class C1 {
private:
  // Suppresses the implicit move constructor and move assignment operator.
  C1(const C1 &other) { /* stub */ }
};
// public copy assignment operator means the class is still copy assignable.
EXPECT_COPYABLE(N4, C1, false, true)
EXPECT_MOVABLE(N4, C1, false, true)
}; // namespace N4

namespace N6 {
// Class with a private user-declared move constructor.
class C1 {
private:
  // Suppresses all other implicit special member functions.
  C1(C1 &&other) { /* stub */ }
};
EXPECT_COPYABLE(N6, C1, false, false)
EXPECT_MOVABLE(N6, C1, false, false)
}; // namespace N6

namespace N7 {
// Class with a public user-declared move constructor.
class C1 {
public:
  // Suppresses all other implicit special member functions.
  C1(C1 &&other) { /* stub */ }
};
EXPECT_COPYABLE(N7, C1, false, false)
EXPECT_MOVABLE(N7, C1, true, false)
}; // namespace N7

namespace N9 {
// Class with a private user-declared copy assignment operator.
class C1 {
private:
  // Suppresses implicit move construct&assign.
  C1 &operator=(const C1 &other) { /* stub */ return *this; }
};
EXPECT_COPYABLE(N9, C1, true, false)
EXPECT_MOVABLE(N9, C1, true, false)
}; // namespace N9

namespace N10 {
// Class with a public user-declared copy assignment operator.
class C1 {
public:
  // Suppresses implicit move construct&assign.
  C1 &operator=(const C1 &other) { /* stub */ return *this; }
};
EXPECT_COPYABLE(N10, C1, true, true)
EXPECT_MOVABLE(N10, C1, true, true)
}; // namespace N10

namespace N11 {
// Class with a private user-declared move assignment operator.
class C1 {
private:
  // Suppresses all other implicit special member functions.
  C1 &operator=(C1 &&other) { /* stub */ return *this; }
};
EXPECT_COPYABLE(N11, C1, false, false)
EXPECT_MOVABLE(N11, C1, false, false)
}; // namespace N11

namespace N12 {
// Class with a public user-declared copy assignment operator.
class C1 {
public:
  // Suppresses all other implicit special member functions.
  C1 &operator=(C1 &&other) { /* stub */ return *this; }
};
EXPECT_COPYABLE(N12, C1, false, false)
EXPECT_MOVABLE(N12, C1, false, true)
}; // namespace N12

namespace N13 {
// Class with a public user-declared destructor.
class C1 {
public:
  // Suppresses implicit move construct&assign.
  ~C1() { /* stub */ }
};
EXPECT_COPYABLE(N13, C1, true, true)
EXPECT_MOVABLE(N13, C1, true, true)
} // namespace N13

namespace N14 {
// Class with a non-static reference data member.
class C1 {
  // Causes the implicit assignment operators to be deleted.
  int &rref;
};
EXPECT_COPYABLE(N14, C1, true, false);
EXPECT_MOVABLE(N14, C1, true, false);
} // namespace N14

namespace N15 {
// Class with a static reference data member.
class C1 {
  static int &rref;
};
EXPECT_COPYABLE(N15, C1, true, true);
EXPECT_MOVABLE(N15, C1, true, true);
} // namespace N15

namespace N16 {
// Class with a non-static rvalue reference data member.
class C1 {
  // Causes the implicit assignment operators and copy constructor to be
  // deleted.
  int &&rref;
};
EXPECT_COPYABLE(N16, C1, false, false);
EXPECT_MOVABLE(N16, C1, true, false);
} // namespace N16

namespace N17 {
// Class with a static rvalue reference data member.
class C1 {
  static int &&rref;
};
EXPECT_COPYABLE(N17, C1, true, true);
EXPECT_MOVABLE(N17, C1, true, true);
} // namespace N17

namespace N18 {
// Class with a const non-static non-class data member.
class C1 {
  // Causes the implicit assignment operators to be deleted.
  const int cint;
};
EXPECT_COPYABLE(N18, C1, true, false);
EXPECT_MOVABLE(N18, C1, true, false);
} // namespace N18

namespace N19 {
// Class with a const static non-class data member.
class C1 {
  static const int cint;
};
EXPECT_COPYABLE(N19, C1, true, true);
EXPECT_MOVABLE(N19, C1, true, true);
} // namespace N19

namespace N20 {
// Class with a const non-static class data member.
class C1 {};
EXPECT_COPYABLE(N20, C1, true, true);
EXPECT_MOVABLE(N20, C1, true, true);
class C2 {
  // Note that this does not suppress the implicit assignment operators until
  // overload resolution fails.
  const C1 c;
};
EXPECT_COPYABLE(N20, C2, true, false);
EXPECT_MOVABLE(N20, C2, true, false);
} // namespace N20

namespace N21 {
// Class with a const non-static const assignable class data member.
class C1 {
public:
  // Carefully constructed to be assignable when const.
  const C1 &operator=(const C1 &) const { /* stub */ return *this = *this; }
};
EXPECT_COPYABLE(N21, C1, true, true);
EXPECT_MOVABLE(N21, C1, true, true);

class C2 {
  // Carefully constructed so that overload resolution doesn't fail.
  const C1 c;
};
EXPECT_COPYABLE(N21, C2, true, true);
EXPECT_MOVABLE(N21, C2, true, true);

class C3 {
  // Arrays are also OK.
  const C1 c[10];
};
EXPECT_COPYABLE(N21, C3, true, true);
EXPECT_MOVABLE(N21, C3, true, true);

class C4 {
  // Const pointers are not class types and never assignable.
  C1 *const c;
};
EXPECT_COPYABLE(N21, C4, true, false);
EXPECT_MOVABLE(N21, C4, true, false);

class C5 {
  // References are not class types and never assignable.
  const C1 &c;
};
EXPECT_COPYABLE(N21, C5, true, false);
EXPECT_MOVABLE(N21, C5, true, false);

class C6 {
  // References disable the assignment operators.
  C1 &c;
};
EXPECT_COPYABLE(N21, C6, true, false);
EXPECT_MOVABLE(N21, C6, true, false);
} // namespace N21

namespace N22 {
// Class with a non-static anonymous union data member with trivial special
// member functions
class C1 {
  union {
  } u;
};
EXPECT_COPYABLE(N22, C1, true, true);
EXPECT_MOVABLE(N22, C1, true, true);
} // namespace N22

namespace N23 {
class NonTrivialCC {
public:
  NonTrivialCC(const NonTrivialCC &) {}
};

class NonTrivialCA {
public:
  NonTrivialCA &operator=(const NonTrivialCA &) { return *this; }
};

class NonTrivialMC {
public:
  NonTrivialMC(NonTrivialMC &&) {}
};

class NonTrivialMA {
public:
  NonTrivialMA &operator=(NonTrivialMA &&) { return *this; }
};

// Class with a non-static anonymous union data member with trivial special
// member functions
class C1 {
  union {
    int x;
  } u;
};
EXPECT_COPYABLE(N23, C1, true, true);
EXPECT_MOVABLE(N23, C1, true, true);

// Classes with non-static anonymous union data members with non-trivial special
// member functions
class C2 {
  union {
    // The non-trivial copy constructor on this variant member causes the
    // implicit copy constructor to be deleted. That same constructor is
    // selected as the move constructor, so that is also deleted.
    NonTrivialCC x;
  } u;
};
EXPECT_COPYABLE(N23, C2, false, true);
EXPECT_MOVABLE(N23, C2, false, true);

// Classes with non-static anonymous union data members with non-trivial special
// member functions
class C3 {
  union {
    // The non-trivial copy assignment on this variant member causes the
    // implicit copy assignment to be deleted. That same assignment is
    // selected as the move assignment, so that is also deleted.
    NonTrivialCA x;
  } u;
};
EXPECT_COPYABLE(N23, C3, true, false);
EXPECT_MOVABLE(N23, C3, true, false);

// Classes with non-static anonymous union data members with non-trivial special
// member functions
class C4 {
  union {
    // The non-trivial move constructor on this variant member causes the
    // implicit move constructor to be deleted.
    // Its definition also suppresses the other implicit special member
    // functions.
    NonTrivialMC x;
  } u;
};
EXPECT_COPYABLE(N23, C4, false, false);
EXPECT_MOVABLE(N23, C4, false, false);

// Classes with non-static anonymous union data members with non-trivial special
// member functions
class C5 {
  union {
    // The non-trivial move assignment on this variant member causes the
    // implicit move assignment to be deleted.
    // Its definition also suppresses the other implicit special member
    // functions.
    NonTrivialMA x;
  } u;
};
EXPECT_COPYABLE(N23, C5, false, false);
EXPECT_MOVABLE(N23, C5, false, false);

// Static anonymous union data members are OK.
class C6 {
  static union {
    NonTrivialCC x;
    NonTrivialCA y;
    NonTrivialMC z;
    NonTrivialMA w;
  } u;
};
EXPECT_COPYABLE(N23, C6, true, true);
EXPECT_MOVABLE(N23, C6, true, true);

// Non-anonymous unions can satisfy overload resolution.
class C7 {
  union U {
    NonTrivialCC x;

    U(const U &other) { /* stub */ }
  } u;
};
EXPECT_COPYABLE(N23, C7, true, true);
EXPECT_MOVABLE(N23, C7, true, true);
} // namespace N23

namespace N24 {
// Potentially constructed subobjects must have overload resolution succeed.

// The first stage is accepting candidates. These classes only have one
// candidate, though that candidate may be deleted.
class NoCopyConstruct {
public:
  NoCopyConstruct(const NoCopyConstruct &) = delete;
  // Define other special member functions
  NoCopyConstruct(NoCopyConstruct &&) = default;
  NoCopyConstruct &operator=(const NoCopyConstruct &) = default;
  NoCopyConstruct &operator=(NoCopyConstruct &&) = default;
};
EXPECT_COPYABLE(N24, NoCopyConstruct, false, true);
EXPECT_MOVABLE(N24, NoCopyConstruct, true, true);

class NoMoveConstruct {
public:
  NoMoveConstruct(NoMoveConstruct &&) = delete;
  // Define other special member functions
  NoMoveConstruct(const NoMoveConstruct &) = default;
  NoMoveConstruct &operator=(const NoMoveConstruct &) = default;
  NoMoveConstruct &operator=(NoMoveConstruct &&) = default;
};
EXPECT_COPYABLE(N24, NoMoveConstruct, true, true);
EXPECT_MOVABLE(N24, NoMoveConstruct, false, true);

class NoCopyAssign {
public:
  NoCopyAssign &operator=(const NoCopyAssign &) = delete;
  // Define other special member functions
  NoCopyAssign(const NoCopyAssign &) = default;
  NoCopyAssign(NoCopyAssign &&) = default;
  NoCopyAssign &operator=(NoCopyAssign &&) = default;
};
EXPECT_COPYABLE(N24, NoCopyAssign, true, false);
EXPECT_MOVABLE(N24, NoCopyAssign, true, true);

class NoMoveAssign {
public:
  NoMoveAssign &operator=(NoMoveAssign &&) = delete;
  // Define other special member functions
  NoMoveAssign(const NoMoveAssign &) = default;
  NoMoveAssign(NoMoveAssign &&) = default;
  NoMoveAssign &operator=(const NoMoveAssign &) = default;
};
EXPECT_COPYABLE(N24, NoMoveAssign, true, true);
EXPECT_MOVABLE(N24, NoMoveAssign, true, false);

class C1 {
  NoCopyConstruct ncc;
};
EXPECT_COPYABLE(N24, C1, false, true);
EXPECT_MOVABLE(N24, C1, true, true);

class C2 {
  // C2 is still move constructible, because nmc will be copied.
  NoMoveConstruct nmc;
};
EXPECT_COPYABLE(N24, C2, true, true);
EXPECT_MOVABLE(N24, C2, true, true);

class C3 {
  NoCopyAssign nca;
};
EXPECT_COPYABLE(N24, C3, true, false);
EXPECT_MOVABLE(N24, C3, true, true);

class C4 {
  // C4 is still move assignable, because nma will be copied.
  NoMoveAssign nma;
};
EXPECT_COPYABLE(N24, C4, true, true);
EXPECT_MOVABLE(N24, C4, true, true);

} // namespace N24

namespace N25 {
// Potentially constructed subobjects include base classes and array elements,
// but not pointed-to objects.
class C1 {
  N24::NoCopyConstruct ncc[10];
};
EXPECT_COPYABLE(N25, C1, false, true);
EXPECT_MOVABLE(N25, C1, true, true);

class C2 : public N24::NoCopyConstruct {};
EXPECT_COPYABLE(N25, C2, false, true);
EXPECT_MOVABLE(N25, C2, true, true);

class C3 {
  N24::NoCopyConstruct *nccp;
};
EXPECT_COPYABLE(N25, C3, true, true);
EXPECT_MOVABLE(N25, C3, true, true);

class C4 {
  // Static data members do not affect special member functions.
  static N24::NoCopyConstruct ncc;
};
EXPECT_COPYABLE(N25, C4, true, true);
EXPECT_MOVABLE(N25, C4, true, true);

} // namespace N25

namespace N26 {
// Virtual inheritance is a little tricky.
//
// The spec says that copy/move constructors only do overload resolution on
// "potentially constructed subobjects," which would exclude virtual bases of
// abstract classes. However, this seems to be an unobservable difference, as
// the virtual base will always be constructed by the most-derived class,
// which will have to satisfy overload resolution on that base, and the
// abstract middle class will not be std::is_x_constructible because that
// requires T(declval<const T&>()) to be a valid expression, which it won't
// be if T is abstract.
//
// These tests aim to prove that we handle this correctly to myself...
class AbstractMiddleNoCopyConstruct : public virtual N24::NoCopyConstruct {
public:
  virtual void f() = 0;
};
// Not constructible because it's abstract.
EXPECT_COPYABLE(N26, AbstractMiddleNoCopyConstruct, false, true);
EXPECT_MOVABLE(N26, AbstractMiddleNoCopyConstruct, false, true);

class NonAbstractMiddleNoCopyConstruct : public virtual N24::NoCopyConstruct {};
EXPECT_COPYABLE(N26, NonAbstractMiddleNoCopyConstruct, false, true);
EXPECT_MOVABLE(N26, NonAbstractMiddleNoCopyConstruct, true, true);

class AbstractMiddleNoCopyAssign : public virtual N24::NoCopyAssign {
public:
  virtual void f() = 0;
};
// Not constructible because it's abstract.
EXPECT_COPYABLE(N26, AbstractMiddleNoCopyAssign, false, false);
EXPECT_MOVABLE(N26, AbstractMiddleNoCopyAssign, false, true);

class NonAbstractMiddleNoCopyAssign : public virtual N24::NoCopyAssign {};
EXPECT_COPYABLE(N26, NonAbstractMiddleNoCopyAssign, true, false);
EXPECT_MOVABLE(N26, NonAbstractMiddleNoCopyAssign, true, true);

class C1 : public AbstractMiddleNoCopyConstruct {
public:
  void f() override {}
};
EXPECT_COPYABLE(N26, C1, false, true);
EXPECT_MOVABLE(N26, C1, true, true);

class C2 : public AbstractMiddleNoCopyAssign {
public:
  void f() override {}
};
EXPECT_COPYABLE(N26, C2, true, false);
EXPECT_MOVABLE(N26, C2, true, true);

class C3 : public NonAbstractMiddleNoCopyConstruct {};
EXPECT_COPYABLE(N26, C3, false, true);
EXPECT_MOVABLE(N26, C3, true, true);

class C4 : public NonAbstractMiddleNoCopyAssign {};
EXPECT_COPYABLE(N26, C4, true, false);
EXPECT_MOVABLE(N26, C4, true, true);

} // namespace N26

namespace N27 {
class C1 {
  virtual void foo()=0;
};
// Not constructible because it's abstract.
EXPECT_COPYABLE(N27, C1, false, true);
EXPECT_MOVABLE(N27, C1, false, true);

class C2 : public C1 {
  void foo() override {}
};
EXPECT_COPYABLE(N27, C2, true, true);
EXPECT_MOVABLE(N27, C2, true, true);

} // namespace N27

namespace N28 {
class C1 {
  // Nested private class are excluded.
  private:
  class C2 {};
};

EXPECT_COPYABLE(N28, C1, true, true);
EXPECT_MOVABLE(N28, C1, true, true);

// We can't access C2 to even run the test.
//using C2 = C1::C2;
//EXPECT_COPYABLE(N28, C2, true, true);
//EXPECT_MOVABLE(N28, C2, true, true);

class C3 {
  // Nested private class are excluded.
  public:
  class C4 {};
};

EXPECT_COPYABLE(N28, C3, true, true);
EXPECT_MOVABLE(N28, C3, true, true);

using C4 = C3::C4;
EXPECT_COPYABLE(N28::C3, C4, true, true);
EXPECT_MOVABLE(N28::C3, C4, true, true);
} // namespace N28

namespace N29 {
// Now we're getting into overload resolution, which is very complicated.
//
// Firstly, let's test candidate resolution with simple pass/fail scenarios.
class CopyableMovable {
public:
  CopyableMovable(const CopyableMovable &) {}
  CopyableMovable(CopyableMovable &&) {}
  CopyableMovable &operator=(const CopyableMovable &) { return *this; }
  CopyableMovable &operator=(CopyableMovable &&) { return *this; }
};
EXPECT_COPYABLE(N29, CopyableMovable, true, true);
EXPECT_MOVABLE(N29, CopyableMovable, true, true);

class C1 {
  // cm.operator=() and cm(cm) resolve successfully.
  CopyableMovable cm;
};
EXPECT_COPYABLE(N29, C1, true, true);
EXPECT_MOVABLE(N29, C1, true, true);

class C2 {
  // ncc(const ncc) resolves to deleted function.
  N24::NoCopyConstruct ncc;
};
EXPECT_COPYABLE(N29, C2, false, true);
EXPECT_MOVABLE(N29, C2, true, true);

class C3 {
  // nca::operator=(nca) resolves to deleted function.
  N24::NoCopyAssign nca;
};
EXPECT_COPYABLE(N29, C3, true, false);
EXPECT_MOVABLE(N29, C3, true, true);

class Base {};
class Derived : Base {
  public:
  Derived(const Derived &) = delete;
  Derived(const Base &) {}
  Derived &operator=(const Derived &) = delete;
  Derived &operator=(const Base &) { return *this; }
  template <typename T>
  Derived &operator=(const T &) { return *this; }
  template <typename T>
  Derived(const T &) { }
};

class C4 {
  // d(d) resolves to deleted function, because Derived::Derived(const Base&)
  // is not a copy constructor.
  Derived d;
};
EXPECT_COPYABLE(N29, C4, false, true);
EXPECT_MOVABLE(N29, C4, false, true);

} // namespace N29