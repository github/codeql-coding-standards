#include <cstdint>

// Test Rule of Zero - compliant case
void test_rule_of_zero_empty_class() {
  struct EmptyClass {}; // COMPLIANT
}

void test_rule_of_zero_value_class() {
  struct ValueClass {
    std::int32_t m1{42};
  }; // COMPLIANT
}

void test_rule_of_zero_non_copyable_member() {
  struct NonCopyableMember {
    NonCopyableMember(const NonCopyableMember &) = delete;
    NonCopyableMember &operator=(const NonCopyableMember &) = delete;
  };

  struct NonCopyableValueClass {
    NonCopyableMember m1;
  }; // COMPLIANT
}

void test_rule_of_zero_unmovable_member() {
  struct UnmovableMember {
    UnmovableMember(UnmovableMember &&) = delete;
    UnmovableMember &operator=(UnmovableMember &&) = delete;
  };

  struct NonCopyableValueClass {
    UnmovableMember m1;
  }; // COMPLIANT
}

void test_rule_of_zero_non_copyable_and_unmovable_member() {
  struct NonCopyableAndUnmovableMember {
    NonCopyableAndUnmovableMember(const NonCopyableAndUnmovableMember &) =
        delete;
    NonCopyableAndUnmovableMember &
    operator=(const NonCopyableAndUnmovableMember &) = delete;
    NonCopyableAndUnmovableMember(NonCopyableAndUnmovableMember &&) = delete;
    NonCopyableAndUnmovableMember &
    operator=(NonCopyableAndUnmovableMember &&) = delete;
  };

  struct NonCopyableValueClass {
    NonCopyableAndUnmovableMember m1;
  }; // COMPLIANT
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | False              | False           | False
void test_all_explicit_cc_not_mc_ca_ma() {
  class CCOnly { // NON-COMPLIANT unmovable with copy constructor
    // Defaulted special member functions
    CCOnly(const CCOnly &) = default; // Copy constructor
    // Deleted special member functions
    CCOnly &operator=(const CCOnly &) = delete; // Copy assignment operator
    CCOnly(CCOnly &&) = delete;
    CCOnly &operator=(CCOnly &&) = delete;
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | True               | False           | False
void test_all_explicit_cc_mc_not_ca_ma() {
  class CCAndMCOnly { // COMPLIANT -- copy enabled unassignable
    // Defaulted special member functions
    CCAndMCOnly(const CCAndMCOnly &) = default; // Copy constructor
    CCAndMCOnly(CCAndMCOnly &&) = default;      // Move constructor
    // Deleted special member functions
    CCAndMCOnly &
    operator=(const CCAndMCOnly &) = delete;         // Copy assignment operator
    CCAndMCOnly &operator=(CCAndMCOnly &&) = delete; // Move assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | False              | True            | False
void test_all_explicit_cc_ca_not_mc_ma() {
  class CCAndCAOnly { // NON-COMPLIANT -- copy enabled not move constructible
    // Defaulted special member functions
    CCAndCAOnly(const CCAndCAOnly &) = default; // Copy constructor
    CCAndCAOnly &
    operator=(const CCAndCAOnly &) = default; // Copy assignment operator
    // Deleted special member functions
    CCAndCAOnly(CCAndCAOnly &&) = delete;            // Move constructor
    CCAndCAOnly &operator=(CCAndCAOnly &&) = delete; // Move assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | False              | False           | True
void test_all_explicit_cc_ma_not_mc_ca() {
  class CCAndMAOnly { // NON-COMPLIANT -- copy enabled not move constructible
    // Defaulted special member functions
    CCAndMAOnly(const CCAndMAOnly &) = default; // Copy constructor
    CCAndMAOnly &
    operator=(CCAndMAOnly &&) = default; // Move assignment operator
    // Deleted special member functions
    CCAndMAOnly(CCAndMAOnly &&) = delete; // Move constructor
    CCAndMAOnly &
    operator=(const CCAndMAOnly &) = delete; // Copy assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | True               | True            | False
void test_all_explicit_cc_mc_ca_not_ma() {
  class CCAndMAAndCAOnly { // NON-COMPLIANT -- copy enabled not fully assignable
    // Defaulted special member functions
    CCAndMAAndCAOnly(const CCAndMAAndCAOnly &) = default; // Copy constructor
    CCAndMAAndCAOnly(CCAndMAAndCAOnly &&) = default;      // Move constructor
    CCAndMAAndCAOnly &
    operator=(const CCAndMAAndCAOnly &) = default; // Copy assignment operator
    // Deleted special member functions
    CCAndMAAndCAOnly &
    operator=(CCAndMAAndCAOnly &&) = delete; // Move assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// True               | True               | False           | True
void test_all_explicit_cc_ma_ma_not_ca() {
  class CCAndMAAndMAOnly { // NON-COMPLIANT -- copy enabled not fully assignable
    // Defaulted special member functions
    CCAndMAAndMAOnly(const CCAndMAAndMAOnly &) = default; // Copy constructor
    CCAndMAAndMAOnly(CCAndMAAndMAOnly &&) = default;      // Move constructor
    CCAndMAAndMAOnly &
    operator=(CCAndMAAndMAOnly &&) = default; // Move assignment operator
    // Deleted special member functions
    CCAndMAAndMAOnly &
    operator=(const CCAndMAAndMAOnly &) = delete; // Copy assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | True               | False           | False
void test_all_explicit_mc_not_cc_ca_ma() {
  class MCOnly { // COMPLIANT -- unmovable
    // Defaulted special member functions
    MCOnly(MCOnly &&) = default; // Move constructor
    // Deleted special member functions
    MCOnly(const MCOnly &) = delete;            // Copy constructor
    MCOnly &operator=(const MCOnly &) = delete; // Copy assignment operator
    MCOnly &operator=(MCOnly &&) = delete;
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | True               | True            | False
void test_all_explicit_mc_ca_not_cc_ma() {
  class MCAndCAOnly { // NON-COMPLIANT -- move-only with copy assignment
                      // operator
    // Defaulted special member functions
    MCAndCAOnly(MCAndCAOnly &&) = default; // Move constructor
    MCAndCAOnly &
    operator=(const MCAndCAOnly &) = default; // Copy assignment operator
    // Deleted special member functions
    MCAndCAOnly(const MCAndCAOnly &) = delete;       // Copy constructor
    MCAndCAOnly &operator=(MCAndCAOnly &&) = delete; // Move assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | True               | False           | True
void test_all_explicit_mc_ma_not_cc_ca() {
  class MCAndMAOnly { // COMPLIANT -- move-only assignable
    // Defaulted special member functions
    MCAndMAOnly(MCAndMAOnly &&) = default; // Move constructor
    MCAndMAOnly &
    operator=(MCAndMAOnly &&) = default; // Move assignment operator
    // Deleted special member functions
    MCAndMAOnly(const MCAndMAOnly &) = delete; // Copy constructor
    MCAndMAOnly &
    operator=(const MCAndMAOnly &) = delete; // Copy assignment operator
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | True               | True            | True
void test_all_explicit_mc_ma_ca_not_cc() {
  class MCAndMAAndCAOnly { // NON-COMPLIANT -- move-only with copy assignment
                           // operator
    // Defaulted special member functions
    MCAndMAAndCAOnly(MCAndMAAndCAOnly &&) = default; // Move constructor
    MCAndMAAndCAOnly &
    operator=(MCAndMAAndCAOnly &&) = default; // Move assignment operator
    MCAndMAAndCAOnly &
    operator=(const MCAndMAAndCAOnly &) = default; // Copy assignment operator
    // Deleted special member functions
    MCAndMAAndCAOnly(const MCAndMAAndCAOnly &) = delete; // Copy constructor
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | False              | True            | False
void test_all_explicit_ca_not_cc_mc_ma() {
  class CAOnly { // NON-COMPLIANT -- unmovable with copy assignment operator
    // Defaulted special member functions
    CAOnly &operator=(const CAOnly &) = default; // Copy assignment operator
    // Deleted special member functions
    CAOnly(const CAOnly &) = delete; // Copy constructor
    CAOnly(CAOnly &&) = delete;      // Move constructor
    CAOnly &operator=(CAOnly &&) = delete;
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | False              | True            | True
void test_all_explicit_ca_ma_not_cc_mc() {
  class CAAndMAOnly { // NON-COMPLIANT -- unmovable with copy and move
                      // assignment operators
    // Defaulted special member functions
    CAAndMAOnly &
    operator=(const CAAndMAOnly &) = default; // Copy assignment operator
    CAAndMAOnly &
    operator=(CAAndMAOnly &&) = default; // Move assignment operator
    // Deleted special member functions
    CAAndMAOnly(const CAAndMAOnly &) = delete; // Copy constructor
    CAAndMAOnly(CAAndMAOnly &&) = delete;      // Move constructor
  };
}

// Copy Constructible | Move Constructible | Copy Assignable | Move Assignable
// False              | False              | False           | True
void test_all_explicit_ma_not_cc_ca_mc() {
  class MAOnly { // NON-COMPLIANT -- unmovable with move assignment operator
    // Defaulted special member functions
    MAOnly &operator=(MAOnly &&) = default; // Move assignment operator
    // Deleted special member functions
    MAOnly(MAOnly &&) = delete;                 // Move constructor
    MAOnly(const MAOnly &) = delete;            // Copy constructor
    MAOnly &operator=(const MAOnly &) = delete; // Copy assignment operator
  };
}

int test_implicit_defaulted_copy_constructor() {
  // When no copy constructor is explicitly defined, one is implicitly defined.
  // If the class declares a move constructor or assignment operator, the
  // implicit copy constructor is deleted.
  class NonCompliantClass1 { // COMPLIANT -- unmovable with copy constructor and assignment operator.
    // Move constructor and assignment operator are not defined because a copy assignment operator is declared.
    NonCompliantClass1 &operator=(const NonCompliantClass1 &) = default; // Copy assignment operator
  };

  class NonCompliantClass2 { // NON-COMPLIANT -- unmovable with copy constructor.
    int x = 0;
    // Move constructor and assignment operator are not defined because a copy assignment operator is declared.
    NonCompliantClass2 &operator=(const NonCompliantClass2 &) = delete; // Copy assignment operator
  };
}

void test_implicit_deleted_copy_constructor() {
  // When no copy constructor is explicitly defined, one is implicitly defined.
  // If the class declares a move constructor or assignment operator, the
  // implicit copy constructor is deleted.
  class CompliantClass { // COMPLIANT -- unmovable
    CompliantClass &
    operator=(const CompliantClass &) = delete; // Copy assignment operator
    // No implicit move constructor because copy assignment operator is declared
  };

  class NonCompliantClass { // NON-COMPLIANT -- unmovable with copy assignment
                            // operator
    NonCompliantClass &
    operator=(const NonCompliantClass &) = default; // Copy assignment operator
  };
}

void test_implicit_defaulted_deleted_copy_constructor() {
  // Implicitly declared copy constructor is defined as deleted in some cases.
  // Here we test non-copyable members.
  class NonCopyableMember {
    NonCopyableMember(const NonCopyableMember &) = delete; // Copy constructor
    NonCopyableMember(NonCopyableMember&&) = delete; // Move constructor
    NonCopyableMember &
    operator=(const NonCopyableMember &) = delete; // Copy assignment operator
    NonCopyableMember &
    operator=(NonCopyableMember &&) = delete; // Move assignment operator
  };

  class CompliantClass { // COMPLIANT -- Move only
    NonCopyableMember m_member;
    CompliantClass(CompliantClass &&) = default; // Move constructor
  };

  class NonCompliantClass { // NON-COMPLIANT -- Copy enabled with no copy constructor
    int m_member;
    NonCompliantClass(NonCompliantClass &&) = default; // Move constructor
    NonCompliantClass& operator=(const NonCompliantClass &) = default; // Copy assignment operator
  };
}

void test_no_implicit_defaulted_move_constructor() {
  // A move constructor is not implicitly declared if a destructor or other
  // special member function is explicitly defined.
  class ExplicitCopyConstructorNonCompliant1 { // NON-COMPLIANT -- move only with implicit copy assignment operator
    ExplicitCopyConstructorNonCompliant1(const ExplicitCopyConstructorNonCompliant1 &) = delete;
  };
  
  class ExplicitCopyConstructorNonCompliant2{ // NON-COMPLIANT -- copy enabled with no move constructor
    ExplicitCopyConstructorNonCompliant2(const ExplicitCopyConstructorNonCompliant2 &) = default;
  };

  class ExplicitCopyAssignmentCompliant { // COMPLIANT -- move only
    ExplicitCopyAssignmentCompliant &operator=(const ExplicitCopyAssignmentCompliant &) = delete; // Copy assignment operator
  };

  class ExplicitCopyAssignmentNonCompliant { // NON-COMPLIANT -- copy enabled with no move assignment operator
    ExplicitCopyAssignmentNonCompliant &operator=(const ExplicitCopyAssignmentNonCompliant &) = default; // Copy assignment operator
  };

  class ExplicitMoveAssignmentCompliant { // COMPLIANT -- unmovable
    ExplicitMoveAssignmentCompliant &operator=(ExplicitMoveAssignmentCompliant &&) = delete;
  };

  class ExplicitMoveAssignmentNonCompliant { // NON-COMPLIANT -- unmovable with move assignment operator
    ExplicitMoveAssignmentNonCompliant &operator=(ExplicitMoveAssignmentNonCompliant &&) = default;
  };

  class ExplicitDestructorNonCompliant { // NON-COMPLIANT -- unmovable with copy assignment operator
    ~ExplicitDestructorNonCompliant() = default; // Destructor
  };

  class ExplicitDestructorCompliant { // COMPLIANT -- unmovable
    ~ExplicitDestructorCompliant() = default; // Destructor
    ExplicitDestructorCompliant &operator=(const ExplicitDestructorCompliant&) = delete;
  };
}

void test_implicit_defaulted_copy_assignment_operator() {
  // When no copy assignment operator is explicitly defined, one is implicitly
  // defined. If a move constructor or assignment operator is declared, the
  // implicit copy assignment operator is deleted. There are other cases where
  // it is deleted as well, such as when a member is not copyable, covered in
  // the next test.
  class CompliantClass { // NON-COMPLIANT -- Copy enabled but not movable
    CompliantClass(const CompliantClass &) = default; // Copy constructor
  };

  class NonCompliantClass { // NON-COMPLIANT -- Unmovable but copy assignable
    NonCompliantClass(const NonCompliantClass &) = delete; // Copy constructor
  };
}

void test_implicit_deleted_copy_assignment_operator() {
  // When no copy assignment operator is explicitly defined, one is implicitly
  // defined. If a move constructor or assignment operator is declared, the
  // implicit copy assignment operator is deleted. There are other cases where
  // it is deleted as well, such as when a member is not copyable.
  class NonCopyableMember {
    NonCopyableMember(const NonCopyableMember &) = delete; // Copy constructor
    NonCopyableMember(NonCopyableMember&&) = delete; // Move constructor
    NonCopyableMember &
    operator=(const NonCopyableMember &) = delete; // Copy assignment operator
    NonCopyableMember &
    operator=(NonCopyableMember &&) = delete; // Move assignment operator
  };

  class CompliantClass1 { // COMPLIANT -- Unmovable
    CompliantClass1(const CompliantClass1 &) = delete;
    CompliantClass1(CompliantClass1 &&) = delete;
  };

  class CompliantClass2 { // COMPLIANT -- Unmovable
    CompliantClass2(const CompliantClass2 &) = delete;
    CompliantClass2& operator=(CompliantClass2 &&) = delete;
  };

  class CompliantClass3 { // COMPLIANT -- Unmovable
    CompliantClass3(const CompliantClass3 &) = delete;
    NonCopyableMember m_member;
  };

  class NonCompliantClass { // COMPLIANT -- Movable with copy assignment
    NonCompliantClass(const NonCompliantClass &) = delete;
    NonCompliantClass(NonCompliantClass &&) = default;
    NonCompliantClass& operator=(NonCompliantClass &&) = delete;
  };
}

void test_implicit_defaulted_move_assignment_operator() {
    // If not defined, a move assignment operator is implicitly declared
    // if and only if no destructor or special member function is explicitly
    // defined.
    class ExplicitCopyConstructor { // NON-COMPLIANT -- Copy enabled assignable with but not move constructible or assignable
      ExplicitCopyConstructor(const ExplicitCopyConstructor &) = default; // Copy constructor
    };

    class ExplicitCopyAssignment { // NON-COMPLIANT -- Copy enabled with no move constructor
        int x;
        ExplicitCopyAssignment &operator=(const ExplicitCopyAssignment &) = default;
    };

    class ExplicitMoveConstructor1 { // COMPLIANT -- Copy enabled unassignable
        // Implicit copy constructor and assignment operator are deleted because a move constructor is declared
        ExplicitMoveConstructor1(ExplicitMoveConstructor1 &&) = default; // Move constructor
    };

    class ExplicitMoveConstructor2 { // COMPLIANT -- Unmovable
        // Implicit copy constructor and assignment operator are deleted because a move constructor is declared
        ExplicitMoveConstructor2(ExplicitMoveConstructor2 &&) = delete; // Move constructor
    };

    class ExplicitDestructor { // NON-COMPLIANT -- unmovable with copy ctor/assign
        int x;
        // Copy constructor and assignment operator are implicitly defaulted.
        // Move constructor and assignment operator are deleted because a destructor is declared.
        ~ExplicitDestructor() = delete; // Destructor
    };
}