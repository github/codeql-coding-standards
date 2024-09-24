void func1() {}
void func2(int x, char* y) {}

typedef struct {} s;

int func3() {
    return 0;
}

typedef void (*func_ptr_t1)();
typedef void (*func_ptr_t2)(int x, char* y);
typedef s (*func_ptr_t3)();

func_ptr_t1 func_ptr1 = &func1; // COMPLIANT
func_ptr_t2 func_ptr2 = func2; // NON-COMPLIANT
func_ptr_t3 func_ptr3 = &(func3); // NON-COMPLIANT

void take_func(func_ptr_t1 f1, func_ptr_t2 f2);

func_ptr_t1 returns_func(int x) {
    if (x == 0) {
        return func1; // NON-COMPLIANT
    } else if (x == 1) {
        return &func1; // COMPLIANT
    }

    return returns_func(0); // COMPLIANT
}

#define MACRO_IDENTITY(f) (f)
#define MACRO_INVOKE_RISKY(f) (f())
#define MACRO_INVOKE_IMPROVED(f) ((f)())

void test() {
    func1();     // COMPLIANT
    func2(1, "hello"); // COMPLIANT

    func1;     // NON-COMPLIANT 
    func2;     // NON-COMPLIANT 

    &func1;     // COMPLIANT 
    &func2;     // COMPLIANT 

    (func1)();     // COMPLIANT
    (func2)(1, "hello"); // COMPLIANT

    &(func1); // NON-COMPLIANT
    &(func2); // NON-COMPLIANT

    (&func1)();     // COMPLIANT
    (&func2)(1, "hello"); // COMPLIANT

    (func1());     // COMPLIANT
    (func2(1, "hello")); // COMPLIANT

    take_func(&func1, &func2); // COMPLIANT
    take_func(func1, &func2); // NON-COMPLIANT
    take_func(&func1, func2); // NON-COMPLIANT
    take_func(func1, func2); // NON-COMPLIANT

    returns_func(0); // COMPLIANT
    returns_func(0)(); // COMPLIANT
    (returns_func(0))(); // COMPLIANT

    (void*) &func1;     // COMPLIANT 
    (void*) (&func1);     // COMPLIANT 
    (void*) func1;     // NON-COMPLIANT 
    (void*) (func1);     // NON-COMPLIANT 
    ((void*) func1);     // NON-COMPLIANT 

    MACRO_IDENTITY(func1); // NON-COMPLIANT
    MACRO_IDENTITY(func1)(); // NON-COMPLIANT
    MACRO_IDENTITY(&func1); // COMPLIANT
    MACRO_IDENTITY(&func1)(); // COMPLIANT

    MACRO_INVOKE_RISKY(func3); // NON-COMPLIANT
    MACRO_INVOKE_IMPROVED(func3); // NON-COMPLIANT
    MACRO_INVOKE_IMPROVED(&func3); // COMPLIANT

    // Function pointers are exempt from this rule.
    func_ptr1(); // COMPLIANT
    func_ptr2(1, "hello"); // COMPLIANT
    func_ptr1; // COMPLIANT
    func_ptr2; // COMPLIANT
    &func_ptr1; // COMPLIANT
    &func_ptr2; // COMPLIANT
    (func_ptr1)(); // COMPLIANT
    (func_ptr2)(1, "hello"); // COMPLIANT
    (*func_ptr1)(); // COMPLIANT
    (*func_ptr2)(1, "hello"); // COMPLIANT
    take_func(func_ptr1, func_ptr2); // COMPLIANT
    (void*) func_ptr1; // COMPLIANT
    (void*) &func_ptr1;     // COMPLIANT 
    (void*) (&func_ptr1);     // COMPLIANT 
    (void*) func_ptr1;     // COMPLIANT 
    (void*) (func_ptr1);     // COMPLIANT 
    ((void*) func_ptr1);     // COMPLIANT 
    MACRO_IDENTITY(func_ptr1); // COMPLIANT
    MACRO_IDENTITY(func_ptr1)(); // COMPLIANT
    MACRO_IDENTITY(&func_ptr1); // COMPLIANT
    (*MACRO_IDENTITY(&func_ptr1))(); // COMPLIANT
    MACRO_INVOKE_RISKY(func_ptr3); // COMPLIANT
    MACRO_INVOKE_IMPROVED(func_ptr3); // COMPLIANT
    MACRO_INVOKE_IMPROVED(*&func_ptr3); // COMPLIANT

}