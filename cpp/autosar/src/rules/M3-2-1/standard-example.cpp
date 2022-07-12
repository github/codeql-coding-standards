// File a.cpp
extern int32_t a;
extern int32_t b[];
extern char_t c;
int32_t f1();
int32_t f2(int32_t);
// File b.cpp
extern int64_t a;    // Non-compliant – not compatible
extern int32_t b[5]; // Compliant
int16_t c;           // Non-compliant
char_t f1();         // Non-compliant
char_t f2(char_t);   // Compliant – not the same function as
                     //             int32_t f2 ( int32_t )