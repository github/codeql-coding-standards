This issue tracks prior art in existing queries (cpp/cert, cpp/autosar, cpp/misra) that may inform the implementation of MISRA C++ 2023 rule 4-1-3, which targets undefined and unspecified behavior in C++17.

**Labels used:**
- **exact** — rule exactly catches the UB or unspecified behavior case
- **partial** — rule catches some of the UB or unspecified cases
- **preventative** — UB or unspecified behavior cannot occur if the rule is followed
- **prior art** — the rule contains code that could be repurposed to implement a new query
- **other(...)** — another relationship; description given inline

---

## Undefined Behavior

| # | Page | Behavior | Relevant Rules |
|---|------|----------|----------------|
| 1 | 21 | Subobject with reference member or const subobject; original name cannot be used to access new subobject (std::launder context, placement new) | MEM54-CPP (prior art — placement new capacity/alignment), EXP54-CPP (prior art — object lifetime) |
| 2 | — | Unsequenced effects: side effects on scalar objects where order of evaluation is unspecified | EXP50-CPP (exact), A5-0-1 (exact) |
| 3 | — | Race conditions on shared data | CON50-CPP (preventative), CON51-CPP (preventative), CON52-CPP (preventative), CON53-CPP (preventative), CON54-CPP (preventative), CON55-CPP (preventative), CON56-CPP (preventative) |
| 4 | — | Various preprocessor undefined behavior (see rows 69–74 for specifics) | A16-0-1 (preventative — limits preprocessor to include/guards), RULE-19-0-2 (preventative — function-like macros not defined), RULE-19-3-1 (partial — `#`/`##` should not be used), DCL51-CPP (prior art — reserved names) |
| 5 | — | Modifying a string literal | A2-13-4 (preventative — string literals shall not be assigned to non-const pointers) |
| 6 | 55 | ODR violations (one-definition rule) | DCL60-CPP (exact) |
| 7 | 77 | std::exit called to end program during destruction of an object with static or thread storage duration | A15-5-3 (partial — registered exit handler throws exception), RULE-18-5-2 (prior art — program-terminating functions should not be used) |
| 8 | 80 | Block-scope static/thread object previously destroyed; flow of control passes through its definition during destruction of another static/thread object | DCL56-CPP (prior art — cycles during static object initialization), A3-3-2 (prior art — static/thread-local objects shall be constant-initialized), EXP54-CPP (prior art) |
| 9 | 80 | Use of standard library object or function not permitted within signal handlers that does not happen before completion of destruction of static storage duration objects | — (no existing rule found) |
| 10 | 80 | Use of object with static storage duration that does not happen before the object's destruction | EXP54-CPP (partial), MEM50-CPP (prior art) |
| 11 | 81 | Indirection through an invalid pointer value; passing an invalid pointer to a deallocation function | MEM50-CPP (exact — do not access freed memory), MEM51-CPP (partial) |
| 12 | 83 | Indirecting through a pointer returned from a zero-size allocation request | MEM52-CPP (prior art — detect and handle memory allocation errors) |
| 13 | 83 | Deallocation function terminates by throwing an exception | DCL57-CPP (preventative — do not let exceptions escape from deallocation functions), A15-5-1 (preventative — deallocation functions shall not exit with exception) |
| 14 | 85 | Calling `free()` on an object with a non-trivial destructor (ending lifetime without calling destructor) | A18-5-1 (exact — malloc/calloc/free shall not be used), MEM51-CPP (prior art) |
| 15 | 85 | Using placement new to reuse storage of an object without properly ending that object's lifetime | MEM54-CPP (partial — placement new capacity/alignment), EXP54-CPP (prior art) |
| 16 | 85 | Overwriting an object via a sibling union member | RULE-8-18-1 (exact — member of a union must not be copied to another member) |
| 17 | 85 | Using a pointer to allocated storage as the operand of `delete` after the object's lifetime has ended (non-trivial class) | EXP57-CPP (partial — do not delete pointers to incomplete classes), MEM51-CPP (prior art) |
| 18 | 85 | Accessing a non-static data member or calling a non-static member function through a pointer to allocated storage whose object lifetime has ended | EXP54-CPP (exact — access of object after lifetime) |
| 19 | 85 | `static_cast` or `dynamic_cast` of pointer to allocated storage whose object lifetime has ended (except `static_cast` to `cv void*`) | EXP54-CPP (exact), RULE-8-2-1 (prior art — virtual base class cast) |
| 20 | 86 | Using a glvalue referring to allocated storage to: access the object, call a non-static member function, convert to virtual base class, or use with `dynamic_cast`/`typeid`, after the object lifetime has ended | EXP54-CPP (exact) |
| 21 | 87 | Ending lifetime of object with non-trivial destructor (static/thread/automatic) where the object type no longer matches the type for which the implicit destructor will be called | MEM51-CPP (prior art), A18-5-1 (prior art) |
| 22 | 87 | Creating a new object within the storage of a `const` complete object with static, thread, or automatic storage duration | MEM54-CPP (prior art) |
| 23 | 95 | Accessing the stored value of an object through a glvalue whose type does not match the dynamic type or any permitted alias (strict aliasing rule violation) | EXP55-CPP (partial — accessing cv-qualified object through cv-unqualified type), EXP62-CPP (prior art — memcpy/memset/memcmp on non-trivial objects) |
| 24 | 101 | Floating-point converted to another floating-point type when result is not representable (or not between two adjacent representable values) | A4-7-1 (partial — integer/float expressions shall not lead to data loss) |
| 25 | 101 | Floating-point value converted to integer when value is not representable in the integer type | A4-7-1 (partial) |
| 26 | 101 | Integer converted to floating-point type when value is outside the range of representable values | A4-7-1 (partial) |
| 27 | 104 | Signed integer overflow; result of arithmetic expression not in the range of representable values | A4-7-1 (exact — integer expression shall not lead to data loss) |
| 28 | 104 | Division by zero | A5-6-1 (exact — right operand of integer division/remainder shall not be zero) |
| 29 | 104 | Expression of type `T&` implicitly converted to `T` outside the lifetime of the object | EXP54-CPP (exact) |
| 30 | 118 | Calling a lambda that captures by reference after the lifetime of the captured variables has ended | EXP61-CPP (exact — lambda capturing by reference stored/returned beyond lifetime) |
| 31 | 120 | Calling a function pointer through an expression whose type is different from the function's actual type | EXP56-CPP (partial — calling function with mismatched language linkage), A5-2-4 (prior art — reinterpret_cast shall not be used) |
| 32 | 126 | Downcasting an xvalue to a class other than its actual class type (e.g., `static_cast<D&&>(std::move(b))` where b is of type B, not D) | A5-2-2 (prior art — C-style casts shall not be used), RULE-8-2-1 (prior art — virtual base class cast) |
| 33 | 127 | Converting integral or enumeration type to a complete enumeration type when the original value is outside the range of enumeration values | INT50-CPP (exact — do not cast to an out-of-range enumeration value), A7-2-1 (partial — enum expression shall only have values corresponding to enumerators) |
| 34 | 127 | Casting `cv-B*` to `cv-D*` when the pointer is non-null and does not point to an object of type D | RULE-8-2-1 (partial — virtual base class cast to derived class), A5-2-2 (prior art) |
| 35 | 127 | Casting pointer-to-member D to base class pointer-to-member B where B does not contain the member (e.g., multiple-inheritance scenarios) | OOP55-CPP (prior art — pointer-to-member operators) |
| 36 | 136 | Non-allocating form of `operator new` returning `nullptr` | MEM52-CPP (prior art — detect and handle memory allocation errors) |
| 37 | 137 | Calling `delete` on a pointer that did not come from a `new` expression (or pointer to subobject thereof) | MEM51-CPP (exact — properly deallocate dynamically-allocated resources), A18-5-3 (partial — form of delete shall match new) |
| 38 | 137 | Calling `delete[]` on a pointer that did not come from a `new[]` expression | MEM51-CPP (exact), A18-5-3 (exact — new[] array freed with delete) |
| 39 | 138 | Static type of `delete` operand differs from its dynamic type, and the static type is not a base class with a virtual destructor | A12-4-1 (preventative — base class destructor shall be public virtual), A12-4-2 (preventative — if public destructor is non-virtual, class should be final) |
| 40 | 138 | `delete[]` on object where static type differs from dynamic type (always UB) | EXP51-CPP (exact — do not delete an array through a pointer of the incorrect type) |
| 41 | 138 | Deleting an object with incomplete class type when the complete class has a non-trivial destructor | A5-3-3 (exact — pointers to incomplete class types shall not be deleted), EXP57-CPP (exact — do not delete pointers to incomplete classes) |
| 42 | 140 | `E1.*.E2` evaluated where the dynamic type of E1 does not contain the member E2 | OOP55-CPP (partial — do not use pointer-to-member operators to access nonexistent members) |
| 43 | 141 | Null pointer-to-member value used in a pointer-to-member expression | OOP55-CPP (exact — do not use a null pointer-to-member value in a pointer-to-member expression) |
| 44 | 141 | Second operand of `/` or `%` is zero | A5-6-1 (exact) |
| 45 | 141 | Quotient in `/` or `%` is not representable in the result type | A4-7-1 (partial) |
| 46 | 142 | Pointer arithmetic via addition or subtraction that forms a pointer outside the bounds of an array (or one past the end), even if not dereferenced | A5-0-4 (partial — pointer arithmetic with non-final classes), CTR52-CPP (prior art — library functions shall not overflow) |
| 47 | 142 | Subtracting two pointers that do not point to the same array (or one past the end), even if not dereferenced | CTR54-CPP (prior art — do not subtract iterators not referring to same container) |
| 48 | 142 | Addition `P + Q` where `P` is a pointer to `T` and `Q` is in an array of `T'` but `T` and `T'` are not similar types | A5-0-4 (prior art) |
| 49 | 142 | Right operand of a shift operation is negative or greater than or equal to the bit width of the left operand | M5-8-1 (exact — right bit-shift operand shall be between zero and one less than width of left operand), RULE-7-0-4 (exact — operands of bitwise/shift operators shall be appropriate) |
| 50 | 143 | Shifting a signed integer such that the result is not representable in the result type | A4-7-1 (partial — integer expressions shall not lead to data loss), M5-8-1 (prior art) |
| 51 | 148 | Assigning to an overlapping object that is also being read from | RULE-8-18-1 (exact — slice of array must not be copied to overlapping region) |
| 52 | 161 | Flowing off the end of a value-returning function without executing a `return` statement | MSC52-CPP (exact — value-returning functions must return a value from all exit paths) |
| 53 | 162 | Block-scope static variable with recursive initialization (e.g., `static int x = f(); return x;` where `f` calls itself) | DCL56-CPP (exact — avoid cycles during initialization of static objects), RULE-8-2-10 (preventative — functions shall not call themselves), A7-5-2 (preventative — functions shall not call themselves) |
| 54 | 175 | Modifying a `const` object during its lifetime, except through a `mutable` member | A7-1-1 (preventative — const/constexpr specifiers shall be used for immutable data), EXP55-CPP (prior art — cv-unqualified access) |
| 55 | 176 | Referring to a `volatile` object through a non-`volatile` glvalue | EXP55-CPP (exact — do not access cv-qualified object through cv-unqualified type), A5-2-3 (partial — cast shall not remove const or volatile qualification) |
| 56 | 209 | Returning from a function declared `[[noreturn]]` | A7-6-1 (exact — functions declared with [[noreturn]] shall not return) |
| 57 | 231 | Indeterminate (uninitialized) value produced by evaluation (with narrow exceptions for unsigned narrow character types) | EXP53-CPP (exact — do not read uninitialized memory), A8-5-0 (exact — all memory shall be initialized before it is read) |
| 58 | 255 | Calling a non-static member function of class X on an object that is not of type X or a class derived from X | OOP55-CPP (prior art — pointer-to-member operators; reinterpret_cast context) |
| 59 | 276 | Calling a pure virtual function (only possible during construction or destruction) | OOP50-CPP (partial — do not invoke virtual functions from constructors or destructors), RULE-15-1-1 (partial — dynamic type shall not be used from within constructor or destructor) |
| 60 | 300 | Deleting an object after its lifetime has already ended (double free) | MEM51-CPP (exact), MEM50-CPP (exact — do not access freed memory) |
| 61 | 307 | Operations performed in a ctor-initializer (perhaps indirectly) before the base class is mem-initialized | A12-1-1 (preventative — constructors shall explicitly initialize all base classes), ERR53-CPP (prior art — do not reference base classes or data members in constructor function-try-block) |
| 62 | 309 | Referring to any non-static member of an object before the constructor begins execution, or after the destructor ends execution | A12-1-1 (preventative), RULE-15-1-2 (preventative — all constructors should explicitly initialize all virtual base classes and immediate base classes) |
| 63 | 310 | Converting a pointer to C to a pointer or reference to base class B before C and all its bases that derive from B have started construction | A12-1-1 (prior art) |
| 64 | 311 | `typeid` operand refers to an object under construction/destruction and the static type of the operand is neither the constructor/destructor's class nor one of its bases | RULE-15-1-1 (exact — object's dynamic type shall not be used from within its constructor or destructor) |
| 65 | 312 | `dynamic_cast` operand refers to an object under construction/destruction and the static type is not a pointer to or object of the constructor/destructor's own class or one of its bases | RULE-15-1-1 (exact) |
| 66 | 398 | Overload resolution would have failed or found a better match with more external linkage identifiers in scope | DCL60-CPP (prior art — one-definition rule) |
| 67 | 403 | Infinite recursion during template instantiation | A7-5-2 (prior art — functions shall not call themselves), RULE-8-2-10 (prior art), A14-7-2 (prior art — template specialization shall be declared in same file as primary template) |
| 68 | 439 | Referring to any static member or base class of the object in the handler for a function-try-block of a constructor or destructor for that object | ERR53-CPP (exact — do not reference base classes or class data members in constructor/destructor function-try-block handler), RULE-18-3-3 (exact — handlers for function-try-block of constructor/destructor shall not refer to non-static members) |
| 69 | 446 | Macro producing the `defined` token (e.g., `#define DEFINED defined`) used in `#if` | RULE-19-1-1 (exact — the `defined` preprocessor operator shall be used appropriately), DCL51-CPP (prior art — redefining/undefining of reserved tokens) |
| 70 | 448 | `#include` directive must expand to a valid `<h-char-sequence>` or `"q-char-sequence"` form | A16-0-1 (prior art — preprocessor shall only be used for file inclusion and include guards) |
| 71 | 449 | Preprocessing directives within macro arguments | RULE-19-0-2 (preventative — function-like macros shall not be defined) |
| 72 | 450 | Using `#` or `##` preprocessor operators in ways that produce undefined behavior | RULE-19-3-1 (exact — `#` and `##` preprocessor operators should not be used) |
| 73 | 454 | Overflow in `#line` directive; invalid form after macro substitution; `#define` or `#undef` of `defined` | RULE-19-1-1 (partial — `defined` operator shall be used appropriately), DCL51-CPP (partial — `#define`/`#undef` of reserved names) |
| 74 | 479 | Adding declarations or definitions to namespace `std::` (unless otherwise specified); declaring explicit specializations of STL class template member functions | DCL58-CPP (exact — do not modify the standard namespaces), A17-6-1 (exact — non-standard entities shall not be added to standard namespaces) |
| 75 | 480 | Adding declarations to the `posix` namespace; redefining names reserved to the implementation | DCL58-CPP (partial), DCL51-CPP (partial — redefining or undefining of reserved tokens) |
| 76 | 481 | Placing a file whose name is equivalent to a standard library header name in the same directory | DCL51-CPP (prior art), A17-6-1 (prior art) |
| 77 | 482 | Replacement functions/handlers not meeting required semantics; incomplete type as template argument when not explicitly allowed; invalid argument passed to standard library function; replacement destructor exits via exception | MEM55-CPP (partial — replacement operator new/delete must meet required semantics), ERR55-CPP (partial — honor exception specifications), A15-5-1 (prior art — destructors shall not exit with exception) |
| 78 | 483 | Calling standard library functions from different threads in ways that can cause a data race | CON50-CPP (preventative), CON54-CPP (preventative), RULE-6-7-2 (prior art — global variables shall not be used) |
| 79 | 483 | Accessing an object outside its lifetime (standard library context) | EXP54-CPP (exact), MEM50-CPP (exact) |
| 80 | 483 | Violating a function's `Requires:` paragraph unless `Throws:` is specified for that violation | — (no existing rule found) |
| 81 | 490 | Using `offsetof()` on a static data member or a function member | EXP59-CPP (exact — use offsetof() on valid types and members) |
| 82 | 503 | Passing invalid alignment values to alignment-sensitive functions | MEM54-CPP (partial — placement new shall be used only with properly aligned pointers), A18-5-4 (prior art — operator delete/new partnership) |
| 83 | 518 | Contents of a named standard library header (implementation-defined restrictions on what may appear) | A16-0-1 (prior art) |
| 84 | 634 | Constructing a `shared_ptr<T>` from a raw pointer obtained by casting another `shared_ptr`'s managed pointer (e.g., `shared_ptr<Derived>(static_cast<Derived*>(base_ptr.get()))`): this creates two independent ownership chains over the same raw object, causing a double-free when either `shared_ptr` reaches reference count zero. The correct alternative is `std::static_pointer_cast<Derived>(base_ptr)`. | MEM56-CPP (exact — do not store an already-owned pointer value in an unrelated smart pointer; the shared query's `isAdditionalFlowStep` tracks `.get()` call results), A20-8-1 (exact — same shared query, AUTOSAR variant), RULE-23-11-1 (prior art — flags raw-pointer constructors of `shared_ptr`/`unique_ptr` for a different reason but detects the same syntactic pattern) |
