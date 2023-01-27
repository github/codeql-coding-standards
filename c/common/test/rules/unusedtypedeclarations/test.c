// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

struct A {}; // NON_COMPLIANT - unused

struct C {};        // COMPLIANT - used in the type def
typedef struct C D; // NON_COMPLIANT - typedef itself not used

struct F {}; // COMPLIANT - used as a global function return type

struct F test_return_value() {
  struct F f;
  return f;
}

struct G {}; // COMPLIANT - used as a global function parameter type

void test_global_function(struct G g) {}

enum M { C1, C2, C3 }; // COMPLIANT - used in an enum type access below

void test_enum_access() { int i = C1; }

struct O {}; // COMPLIANT - used in typedef below

typedef struct O P; // COMPLIANT - used in typedef below
typedef P Q;        // COMPLIANT - used in function below
typedef Q R;        // NON_COMPLIANT - never used

Q test_type_def() {}

struct {     // COMPLIANT - used in type definition
  union {    // COMPLIANT - f1 and f3 is accessed
    struct { // COMPLIANT - f1 is accessed
      int f1;
    };
    struct { // COMPLIANT - f3 is accessed
      float f2;
      float f3;
    };
    struct { // NON_COMPLIANT - f4 is never accessed
      long f4;
    };
  };
  int f5;
} s;

void test_nested_struct() {
  s.f1;
  s.f3;
  s.f5;
}