import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.types.TrivialType

/**
 * Get the largest word size, in bytes. Some projects may have multiple different
 * `VoidPointerType` sizes.
 */
int wordSize() { result = max(VoidPointerType v | | v.getSize()) }

/**
 * Converts bytes to words
 */
bindingset[bytes]
int minWordsRequiredToRepresentBytes(int bytes) { result = (1.0 * bytes / wordSize()).ceil() }

class TriviallyCopyableSmallType extends Type {
  TriviallyCopyableSmallType() {
    isTriviallyCopyableType(this) and
    exists(int size | size = this.getSize() | minWordsRequiredToRepresentBytes(size) <= 2)
  }
}
