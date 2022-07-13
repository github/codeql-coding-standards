import cpp
import codingstandards.cpp.autosar

/**
 * Get the largest word size, in bytes. Some projects may have multiple different
 * `VoidPointerType` sizes.
 */
int wordSize() { result = max(VoidPointerType v | | v.getSize()) }

/**
 * Converts bytes to words
 */
bindingset[bytes]
int bytesToWords(int bytes) { result = bytes / wordSize() }

class TriviallySmallType extends Type {
  TriviallySmallType() { exists(int size | size = this.getSize() | bytesToWords(size) <= 2) }
}
