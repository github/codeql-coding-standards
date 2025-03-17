// clang-format off
// Note that in this file the COMPLIANT/NON_COMPLIANT markers are above the 
// item 

// COMPLIANT
/* ... */ 

// NON_COMPLIANT
/* /* */ 

// NON_COMPLIANT
/* // */ 

// COMPLIANT
// // / / 

// COMPLIANT
//  / 

// NON_COMPLIANT
//  /* 

// COMPLIANT
/* https://github.com */

// COMPLIANT
/* https://name-with-hyphen-and-num-12345.com */

// NON_COMPLIANT
/* https://github.com // */

// NON_COMPLIANT
/* a://b, a://b., ://a.b, a://b., a://.b, ://, a://, ://b */

// COMPLIANT
// https://github.com

// COMPLIANT
//* foo

// NON_COMPLIANT
///* foo

void f(){}