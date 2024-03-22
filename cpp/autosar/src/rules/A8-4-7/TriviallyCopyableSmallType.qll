import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TrivialType

/**
 * Get the largest word size, in bytes. Some projects may have multiple different
 * `VoidPointerType` sizes.
 */
int wordSize() { result = max(VoidPointerType v | | v.getSize()) }

/**
 * Converts bytes to words
 */
bindingset[bytes]
float bytesToWords(float bytes) { result = bytes / wordSize() }

class TriviallyCopyableSmallType extends Type {
  TriviallyCopyableSmallType() {
    isTriviallyCopyableType(this) and
    exists(int size | size = this.getSize() | bytesToWords(size) <= 2)
  }
}
