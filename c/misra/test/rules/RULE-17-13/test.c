// semmle-extractor-options: --language=c -std=c99
const int x; // COMPLIANT
const int f_ret_const_int(void); // COMPLIANT
const int* f_ret_const_int_ptr(void); // COMPLIANT

// Basic function typedefs
typedef int ftype_ret_int(void);
typedef const int ftype_ret_const_int(void); // COMPLIANT
typedef const int* ftype_ret_const_int_ptr(void); // COMPLIANT
typedef int const* ftype_ret_int_const_ptr(void); // COMPLIANT

// Typedefs that use function typedefs
typedef ftype_ret_int ftype_ret_int2; // COMPLIANT
typedef const ftype_ret_int *ptr_const_ftype_ret_int; // NON-COMPLIANT
typedef ftype_ret_int *const const_ptr_ftype_ret_int; // COMPLIANT
typedef ftype_ret_int const* const_ptr_ftype_ret_int_; // NON-COMPLIANT

// Test all qualifiers
typedef const ftype_ret_int const_ftype_ret_int; // NON-COMPLIANT
typedef volatile ftype_ret_int volatile_ftype_ret_int; // NON-COMPLIANT
typedef _Atomic ftype_ret_int atomic_ftype_ret_int; // NON-COMPLIANT
//extern restrict ftype_ret_int restrict_ftype_ret_int; // NON-COMPLIANT

// Test parameters of declaration specifiers
typedef void (*take_ftype_ret_int)(ftype_ret_int); // COMPLIANT
typedef void (*take_const_ftype_ret_int)(const ftype_ret_int); // NON-COMPLIANT
typedef void (*take_ptr_ftype_ret_int)(ftype_ret_int*); // COMPLIANT
typedef void (*take_ptr_const_ftype_ret_int)(const ftype_ret_int *); // NON-COMPLIANT
typedef void (*take_const_ptr_ftype_ret_int)(ftype_ret_int const *); // COMPLIANT

// Test return types of declaration specifiers
typedef ftype_ret_int* (return_ftype_ret_int)(void); // COMPLIANT
typedef const ftype_ret_int* (return_ftype_ret_int)(void); // NON-COMPLIANT
typedef ftype_ret_int const* (return_ftype_ret_int)(void); // COMPLIANT

// Other storage class specifiers
extern const ftype_ret_int extern_ftype; // NON-COMPLIANT
extern const ftype_ret_int *extern_const_ftype_type; // NON-COMPLIANT
extern ftype_ret_int const * extern_ftype_const_ptr; // COMPLIANT

// Other declarations
void param_list(
    const ftype_ret_int *param_ftype, // NON-COMPLIANT
    const ftype_ret_int *param_const_ftype_type, // NON-COMPLIANT
    ftype_ret_int const *param_ftype_const_ptr // COMPLIANT
) {
    const ftype_ret_int *var_ftype; // NON-COMPLIANT
    const ftype_ret_int *var_const_ftype_type; // NON-COMPLIANT
    ftype_ret_int const *var_ftype_const_ptr; // COMPLIANT

    struct TestStruct {
        const ftype_ret_int *struct_ftype; // NON-COMPLIANT
        const ftype_ret_int *struct_const_ftype_type; // NON-COMPLIANT
        ftype_ret_int const *struct_ftype_const_ptr; // COMPLIANT
    };
}
