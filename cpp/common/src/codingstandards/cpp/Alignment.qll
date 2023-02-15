/**
 * Provides a library with additional modeling for C and C++ memory alignment constructs.
 */

import cpp

/*
 * In theory each compilation of each file can have a different `max_align_t` value (for example,
 * if the same file is compiled under different compilers in the same database). We don't have the
 * fine-grained data to determine which compilation each operator new call is from, so we instead
 * report only in cases where there's a single clear alignment for the whole database.
 */

class MaxAlignT extends TypedefType {
  MaxAlignT() { getName() = "max_align_t" }
}

/**
 * Gets the alignment for `max_align_t`, assuming there is a single consistent alignment for the
 * database.
 */
int getGlobalMaxAlignT() {
  count(MaxAlignT m | | m.getAlignment()) = 1 and
  result = any(MaxAlignT t).getAlignment()
}
