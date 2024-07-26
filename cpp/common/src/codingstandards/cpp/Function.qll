/** A module to reason about functions, such as well-known functions. */

import cpp

/**
 * A function whose name is suggestive that it counts the number of bits set.
 */
class PopCount extends Function {
  PopCount() { this.getName().toLowerCase().matches("%popc%nt%") }
}
