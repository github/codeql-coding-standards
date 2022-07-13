#define MACROONE 1 // COMPLIANT

#define MACROTWO '#\'-#' + '#' // COMPLIANT

#define MACROTHREE "##" // COMPLIANT

#define MACROFOUR "##" + "#" // COMPLIANT

#define MACROFIVE(X) #X // COMPLIANT

#define MACROSIX(X, Y) X##Y // COMPLIANT

#define MACROSEVEN "##'" #"#" // COMPLIANT

#define MACROEIGHT '##' #"#" // COMPLIANT

#define MACRONINE "##\"\"" + "#" // COMPLIANT

#define MACROTEN "##\"\"'" + "#" // COMPLIANT

#define MACROELEVEN(X) X #X #X // COMPLIANT

#define MACROTWELVE(X) X##X##X // COMPLIANT

#define MACROTHIRTEEN(X) #X##X // NON_COMPLIANT

#define MACROFOURTEEN '#\'-#' + 1 #1 #1 + '#' // COMPLIANT