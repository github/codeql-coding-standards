#ifndef INVALID4_H1
#define INVALID4_H1

void invalid4_f1();

#endif

#ifndef INVALID4_H2
#define INVALID4_H2

// NON-COMPLIANT -- There should not be two inclusion guards in one file.
void invalid4_f1();

#endif