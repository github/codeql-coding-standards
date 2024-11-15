#ifndef HEADER3_H
#define HEADER3_H

// We should ignore the header guards in this file

// This is defined unconditionally by both header3.h and header4.h
#define MULTIPLE_INCLUDE // NON_COMPLIANT

// This is redefined in header3.h, but only if it isn't already defined
#define PROTECTED // COMPLIANT

// This is redefined in header3.h, but is conditional on some other condition,
// so this is redefined
#define NOT_PROTECTED // NON_COMPLIANT

#endif