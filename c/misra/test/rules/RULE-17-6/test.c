void test_array(int arr1[10]) {}                             // COMPLIANT
void test_array_uses_static(int arr2[static 11]) {}          // NON_COMPLIANT
void test_array_uses_static_multi(int arr3[static 12][5]) {} // NON_COMPLIANT
void test_array_uses_static_again(
    int arr4[11]) { // COMPLIANT[FALSE_POSITIVE] - apparently a CodeQL
                    // bug where the static is associated with the fixed
                    // size
}