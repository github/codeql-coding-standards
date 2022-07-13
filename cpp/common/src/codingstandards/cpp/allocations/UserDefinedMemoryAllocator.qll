import cpp
import codingstandards.cpp.Handlers

/**
 * Models the set of memory allocator functions as defined by declaring a
 * compiler attribute or being explicitly installed with `set_new_handler`.
 */
class UserDefinedMemoryAllocator extends Function {
  UserDefinedMemoryAllocator() {
    exists(Attribute s |
      s = getAnAttribute() and s.getName() = ["malloc", "gnu::malloc", "restrict", "allocator"]
    )
    or
    exists(SetHandlerFunction f | f.isNewHandler() and f.getHandler() = this)
  }
}
