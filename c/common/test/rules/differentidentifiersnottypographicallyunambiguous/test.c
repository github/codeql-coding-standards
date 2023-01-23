// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
int case1_foo;
int case1_FOO; // NON_COMPLIANT
int case1_fOo; // NON_COMPLIANT

int case2_foo;
int case2_f_o_o; // NON_COMPLIANT

int case3_fOO;
int case3_fO0; // NON_COMPLIANT

int case4_II;
int case4_I1; // NON_COMPLIANT
int case4_Il; // NON_COMPLIANT

int case5_S;
int case5_5; // NON_COMPLIANT

int case6_Z;
int case6_2; // NON_COMPLIANT

int case7_n;
int case7_h; // NON_COMPLIANT

int case8_B;
int case8_8; // NON_COMPLIANT

int case9_rn;
int case9_m;  // NON_COMPLIANT
int case9_rh; // NON_COMPLIANT

int case10_xrnrnx;
int case10_xmmx;   // NON_COMPLIANT
int case10_xmrnx;  // NON_COMPLIANT
int case10_xrnmx;  // NON_COMPLIANT
int case10_xrnrhx; // NON_COMPLIANT
int case10_xrhrhx; // NON_COMPLIANT
int case10_xmrhx;  // NON_COMPLIANT
int case10_xrhmx;  // NON_COMPLIANT

int case11_o, case11_O; // NON_COMPLIANT

int case12_BBb;
int case12_8bB; // NON_COMPLIANT

// Transitive rules are compliant

// m -> rn -> rh
int case13_m;
int case13_rh; // COMPLIANT

// b -> B -> 8
int case14_b;
int case14_8; // COMPLIANT

// z -> Z -> 2
int case15_z;
int case15_2; // COMPLIANT

// s -> S -> 5
int case16_s;
int case16_5; // COMPLIANT

// o -> O -> 0
int case17_o;
int case17_0;