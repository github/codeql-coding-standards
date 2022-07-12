const char *a1 = "\x11"
                 "G"; // COMPLIANT

const char *a2 = "\x1"
                 "G"; // COMPLIANT

const char *a3 = "\x1A"; // COMPLIANT

const char *a4 = "\x1AG"; // NON_COMPLIANT

const char *a5 = "\021"; // COMPLIANT
const char *a6 = "\029"; // NON_COMPLIANT
const char *a7 = "\0"
                 "0";     // COMPLIANT
const char *a8 = "\0127"; // NON_COMPLIANT
const char *a9 = "\0157"; // NON_COMPLIANT

const char *a10 = "\012\0129"; // NON_COMPLIANT (1x)
const char *a11 = "\012\019";  // NON_COMPLIANT
const char *a12 = "\012\017";  // COMPLIANT

const char *a13 = "\012AAA\017"; // NON_COMPLIANT (1x)

const char *a14 = "Some Data \012\017";  // COMPLIANT
const char *a15 = "Some Data \012\017A"; // NON_COMPLIANT (1x)
const char *a16 = "Some Data \012\017A"
                  "5"; // NON_COMPLIANT (1x)
const char *a17 = "Some Data \012\017"
                  "A"
                  "\0121"; // NON_COMPLIANT (1x)

const char *a18 = "\x11"
                  "G\001"; // COMPLIANT
const char *a19 = "\x11"
                  "G\0012"; // NON_COMPLIANT (1x)
const char *a20 = "\x11G"
                  "G\001"; // NON_COMPLIANT (1x)
const char *a21 = "\x11G"
                  "G\0013"; // NON_COMPLIANT (2x)

// clang-format off
const char *b1 = "\x11" "G"; // COMPLIANT
const char *b2 = "\x1" "G"; // COMPLIANT
const char *b3 = "\0" "0";     // COMPLIANT
const char *b4 = "Some Data \012\017A" "5"; // NON_COMPLIANT (1x)
const char *b5 = "Some Data \012\017" "A" "\0121"; // NON_COMPLIANT (1x)
const char *b6 = "\x11" "G\001"; // COMPLIANT
const char *b7 = "\x11" "G\0012"; // NON_COMPLIANT (1x)
const char *b8 = "\x11G" "G\001"; // NON_COMPLIANT (1x)
const char *b9 = "\x11G" "G\0013"; // NON_COMPLIANT (2x)

char c1 = '\023'; // COMPLIANT
char c2 = '\x0a'; // COMPLIANT
