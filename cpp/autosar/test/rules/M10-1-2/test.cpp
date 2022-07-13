/**
 * This test case models the following inheritance hierarchy:
 *
 *      A
 *     / \
 *    B   C _
 *   / \ / \  \
 *  D   E   F   \
 *   \ / \ / \   Y — Z
 *    G   H   I  |
 *    |   |   | /
 *    |   |   J
 *     \ / \ /
 *      K   L
 *
 * Only derivations at the 'top' of any diamond may be declared virtual.
 *
 * Compliant class names are numbered '1', while non-compliant class numbering
 * is incremented.
 */

class A1 {};                          // COMPLIANT
class B1 : virtual A1 {};             // COMPLIANT
class C1 : virtual A1 {};             // COMPLIANT
class D1 : virtual B1 {};             // COMPLIANT
class E1 : virtual B1, virtual C1 {}; // COMPLIANT
class F1 : virtual C1 {};             // COMPLIANT
class Y1 : virtual C1 {};             // COMPLIANT
class Z1 : Y1 {};                     // COMPLIANT
class G1 : D1, virtual E1 {};         // COMPLIANT
class H1 : virtual E1, virtual F1 {}; // COMPLIANT
class I1 : virtual F1 {};             // COMPLIANT
class J1 : I1, Y1 {};                 // COMPLIANT
class K1 : G1, H1 {};                 // COMPLIANT
class L1 : J1, H1 {};                 // COMPLIANT

class L2 : J1, virtual H1 {};         // NON_COMPLIANT
class L3 : virtual J1, H1 {};         // NON_COMPLIANT
class K2 : virtual G1, virtual H1 {}; // NON_COMPLIANT
class J2 : I1, virtual Y1 {};         // NON_COMPLIANT
class G2 : virtual D1, virtual E1 {}; // NON_COMPLIANT
class Z2 : virtual Y1 {};             // NON_COMPLIANT