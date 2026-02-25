// Test types used in templates.
//
// The rule is clear that even a usage in an uninstantiated template should be
// counted. However, we don't have enough information from the CodeQL extractor
// to do this precisely, so we err on the side of false negatives.
//
// The only API to find these type references in uninstantiated templates
// directly is `TypeMention`, which is too disassociated from the AST to easily
// determine whether than mention occurs in or outside of the definition of
// the type itself, inside a template, etc.
namespace {

// The following code is too hard to read without namespace indendation.
// clang-format off

/**
 * Test case 1: A type is used inside an instantiated template
 */
namespace instantiated_use {
    struct A1 {}; // COMPLIANT

    template <typename T> // COMPLIANT
    void foo(A1 l1) {}

    void f1() { foo<int>(A1{}); }
} // namespace instantiated_use

/**
 * Test case 2: A type is used inside an uninstantiated template
 */
namespace uninstantiated_use {
    struct A1 {}; // COMPLIANT

    template <typename T> // COMPLIANT
    void foo(A1 l1) {}
} // namespace uninstantiated_use

/**
 * Test case 3: A type is not used by a relevant template that is instantiated
 */
namespace instantiated_unused {
    struct A1 {}; // NON_COMPLIANT

    template <typename T> // COMPLIANT
    void foo(int l1) {}

    void f1() { foo<int>(42); }
} // namespace instantiated_unused

/**
 * Test case 4: A type that is not used by a relevant template that is not
 * instantiated
 */
namespace uninstantiated_unused {
    struct A1 {}; // NON_COMPLIANT[False Negative]

    template <typename T> // COMPLIANT
    void foo(int l1) {}
} // namespace uninstantiated_unused

/**
 * Test case 5: A type that is used to instantiate a template
 */
namespace use_by_instantiation {
    struct A1 {}; // COMPLIANT

    template <typename T> // COMPLIANT
        void foo() {
        T l1;
    }

    void f1() { foo<A1>(); }
} // namespace use_by_instantiation

/**
 * Test case 6: A type that is used as the type of a template parameter
 */
namespace use_as_template_parameter_type {
    enum A1 { a };

    template <A1 a = A1::a> void foo() {} // COMPLIANT

    // Instantiate the template -- if it isn't instantiated, the alert for A1 is
    // suppressed regardless of template parameter type usage
    void f1() { foo(); }
} // namespace use_as_template_parameter_type

/**
 * Test case 6: A type that is used as the default value of a non-type template
 * parameter
 */
namespace use_as_template_parameter_default_value {
    class A1 { // COMPLIANT[False positive]
        static const int a = 42;
    };

    // The only API to find this in the database is `TypeMention`, which is too
    // disassociated from the AST to easily determine if it is used in or
    // outside of the definition of `A1`.
    template <int a = A1::a> void foo() {}

    // Instantiate the template -- if it isn't instantiated, the alert for A1 is
    // suppressed regardless of template parameter default value
    void f1() { foo(); }
} // namespace use_as_template_parameter_default_value

} // namespace