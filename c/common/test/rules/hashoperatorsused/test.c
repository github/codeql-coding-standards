#define MACROONE 1 // COMPLIANT

#define MACROTWO '#' // COMPLIANT

#define MACROTHREE "##" // COMPLIANT

#define MACROFOUR "##" + "#" // COMPLIANT

#define MACROFIVE(X) #X // NON_COMPLIANT

#define MACROSIX(X, Y) X##Y // NON_COMPLIANT

#define MACROSEVEN "##'" #"#" // NON_COMPLIANT

#define MACROEIGHT '##' #"#" // NON_COMPLIANT

#define MACRONINE "##\"\"" + "#" // COMPLIANT

#define MACROTEN "##\"\"'" + "#" // COMPLIANT