/**
 * C-style assert macros can be implemented in many different structures.
 *
 * This aims to test that we support as many of these as possible.
 */

// Disable clang-format for this file to enable inline tests.
// clang-format off

bool __unlikely(bool condition);
bool __likely(bool condition);
void __assert(const char* expr, const char* file, int line);
bool __custom_abort(const char* expr, const char* file, int line);
void __print(const char* expr, const char* file, int line);
void abort();
[[noreturn]] void end_control_flow();

#define assert(X) \
  { (__builtin_expect(!(X), 0) ? __assert (#X, __FILE__, __LINE__) : (void)0); }

void g() {}

void f1(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(false && "abort here"); // $ condition=...&&... asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
    assert(1 && "always true"); // $ condition=...&&...
    assert(x ? 1 : 0); // $ condition=...?...:...
}

#define assert(X) \
  { __builtin_expect((X), 1) ? (void)0 : __assert (#X, __FILE__, __LINE__); }

void f2(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
}

#define assert(X) \
  { if(!(X)) { __print (#X, __FILE__, __LINE__); abort(); } }

void f3(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
}

#define assert(X) \
  { __likely(X) || __custom_abort (#X, __FILE__, __LINE__); }

void f4(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
}

#define assert(X) \
  { __unlikely(!(X)) && __custom_abort (#X, __FILE__, __LINE__); }

void f5(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
}

#define assert(X) \
  { if (__unlikely((X))) { (void) 0; } else { __print( #X, __FILE__, __LINE__); end_control_flow(); } }

void f6(int x) {
    assert(x); // $ condition=x
    assert(false); // $ condition=0 asserts_false=true
    assert(0); // $ condition=0 asserts_false=true
    assert(1); // $ condition=1
}