static void f(); // NON_COMPILANT - prefer to use an anonymous namespace

namespace {
void f1();        // COMPILANT
extern void f2(); // NON_COMPILANT

int i;         // COMPILANT
extern int i1; // NON_COMPILANT
static int i2; // NON_COMPILANT  - prefer to not use static as it is redundant
} // namespace

namespace named {
static const int i[] = {1}; // COMPILANT - exception
}