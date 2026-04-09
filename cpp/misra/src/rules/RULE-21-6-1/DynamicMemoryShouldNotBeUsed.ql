/**
 * @id cpp/misra/dynamic-memory-should-not-be-used
 * @name RULE-21-6-1: Dynamic memory should not be used
 * @description Heap allocation is prohibited unless explicitly justified.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-6-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.DynamicMemory

/**
 * A function that directly or indirectly allocates dynamic memory.
 */
abstract class DynamicMemoryAllocatingFunction extends Function { }

/**
 * A function that directly allocates dynamic memory.
 * Includes C allocation functions (malloc, calloc, realloc, aligned_alloc)
 * and C++ allocation functions (operator new, operator new[]).
 *
 * This excludes placement-new operators, as they do not allocate memory themselves.
 */
class DirectDynamicMemoryAllocatingFunction extends DynamicMemoryAllocatingFunction {
  DirectDynamicMemoryAllocatingFunction() {
    this instanceof AllocationFunction and
    not this instanceof PlacementNewOrNewArrayAllocationFunction
    or
    this.hasGlobalOrStdName("aligned_alloc")
  }
}

/**
 * A function that indirectly allocates dynamic memory through
 * standard library types that use `std::allocator` or operator new internally.
 * Includes constructors of containers, strings, streams, regex, and other
 * allocating standard library types.
 */
abstract class IndirectDynamicMemoryAllocatingFunction extends DynamicMemoryAllocatingFunction { }

/**
 * A constructor of a standard library container that uses `std::allocator` directly
 * as template argument or under the hood as the default value of the template argument.
 * Includes `vector`, `deque`, `list`, `forward_list`, `set`, `map`, `multiset`, `multimap`,
 * `unordered_set`, `unordered_map`, `unordered_multiset`, `unordered_multimap`, and `valarray`.
 */
class AllocatorContainerConstructor extends IndirectDynamicMemoryAllocatingFunction {
  AllocatorContainerConstructor() {
    this instanceof Constructor and
    this.getDeclaringType()
        .hasQualifiedName("std",
          [
            "vector", "deque", "list", "forward_list", "set", "map", "multiset", "multimap",
            "unordered_set", "unordered_map", "unordered_multiset", "unordered_multimap", "valarray"
          ])
  }
}

/**
 * A constructor of a standard library string type that uses std::allocator.
 * Includes basic_string and its aliases (string, wstring, u16string, u32string).
 */
class AllocatorStringConstructor extends IndirectDynamicMemoryAllocatingFunction {
  AllocatorStringConstructor() {
    this instanceof Constructor and
    this.getDeclaringType()
        .hasQualifiedName("std", ["basic_string", "string", "wstring", "u16string", "u32string"])
  }
}

/**
 * A constructor of a container adaptor that contains an allocating container by default.
 * Includes stack (contains deque), queue (contains deque), and priority_queue (contains vector).
 */
class ContainerAdaptorConstructor extends IndirectDynamicMemoryAllocatingFunction {
  ContainerAdaptorConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", ["stack", "queue", "priority_queue"])
  }
}

/**
 * A constructor of a string stream that contains std::basic_string for buffer storage.
 * Includes `basic_stringstream`, `stringstream`, `wstringstream`,
 * `basic_istringstream`, `istringstream`, `wistringstream`,
 * `basic_ostringstream`, `ostringstream`, `wostringstream`.
 */
class StringStreamConstructor extends IndirectDynamicMemoryAllocatingFunction {
  StringStreamConstructor() {
    this instanceof Constructor and
    this.getDeclaringType()
        .hasQualifiedName("std",
          [
            "basic_stringstream", "stringstream", "wstringstream", "basic_istringstream",
            "istringstream", "wistringstream", "basic_ostringstream", "ostringstream",
            "wostringstream"
          ])
  }
}

/**
 * A constructor of a file stream that allocates an internal I/O buffer via `std::basic_filebuf`.
 * Includes `basic_fstream`, `fstream`, `wfstream`,
 * `basic_ifstream`, `ifstream`, `wifstream`,
 * `basic_ofstream`, `ofstream`, `wofstream`.
 */
class FileStreamConstructor extends IndirectDynamicMemoryAllocatingFunction {
  FileStreamConstructor() {
    this instanceof Constructor and
    this.getDeclaringType()
        .hasQualifiedName("std",
          [
            "basic_fstream", "fstream", "wfstream", "basic_ifstream", "ifstream", "wifstream",
            "basic_ofstream", "ofstream", "wofstream"
          ])
  }
}

/**
 * A constructor of a regex type that allocates for compiled pattern representation.
 * Includes `basic_regex`, `regex`, `wregex`.
 */
class RegexConstructor extends IndirectDynamicMemoryAllocatingFunction {
  RegexConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", ["basic_regex", "regex", "wregex"])
  }
}

/**
 * A constructor of a type-erasing wrapper that may allocate via operator new.
 * SBO (small buffer optimization) is not guaranteed by the standard.
 * Includes `std::function` and `std::any`.
 */
class TypeErasureConstructor extends IndirectDynamicMemoryAllocatingFunction {
  TypeErasureConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", ["function", "any"])
  }
}

/**
 * A constructor of a type that heap-allocates shared state for
 * cross-object or cross-thread communication.
 * Includes promise, future, shared_future, packaged_task, and locale.
 */
class SharedStateConstructor extends IndirectDynamicMemoryAllocatingFunction {
  SharedStateConstructor() {
    this instanceof Constructor and
    this.getDeclaringType()
        .hasQualifiedName("std", ["promise", "future", "shared_future", "packaged_task", "locale"])
  }
}

/**
 * A constructor of `std::thread` that heap-allocates callable and arguments
 * for transfer to the new thread.
 */
class ThreadConstructor extends IndirectDynamicMemoryAllocatingFunction {
  ThreadConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", "thread")
  }
}

/**
 * A constructor of `std::filesystem::path` that contains `std::basic_string` for path storage.
 */
class FilesystemPathConstructor extends IndirectDynamicMemoryAllocatingFunction {
  FilesystemPathConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std::filesystem", "path")
  }
}

/**
 * A smart pointer factory function that allocates dynamic memory.
 * Includes `make_unique`, `make_shared`, and `allocate_shared`.
 */
class SmartPointerFactoryFunction extends IndirectDynamicMemoryAllocatingFunction {
  SmartPointerFactoryFunction() {
    this.hasQualifiedName("std", ["make_unique", "make_shared", "allocate_shared"])
  }
}

/**
 * The `std::async` function that allocates callable storage and shared state for the future.
 */
class AsyncFunction extends IndirectDynamicMemoryAllocatingFunction {
  AsyncFunction() { this.hasQualifiedName("std", "async") }
}

/**
 * A function that directly or indirectly deallocates dynamic memory.
 */
abstract class DynamicMemoryDeallocatingFunction extends Function { }

/**
 * A function that directly deallocates dynamic memory.
 * Includes C deallocation functions (`free`)
 * and C++ deallocation functions (`operator delete`, `operator delete[]`).
 */
class DirectDynamicMemoryDeallocatingFunction extends DynamicMemoryDeallocatingFunction {
  DirectDynamicMemoryDeallocatingFunction() { this instanceof DeallocationFunction }
}

/**
 * A function that indirectly deallocates dynamic memory through
 * standard library classes and their member functions (e.g. `std::allocator::deallocate`).
 */
class IndirectDynamicMemoryDeallocatingFunction extends DynamicMemoryDeallocatingFunction {
  IndirectDynamicMemoryDeallocatingFunction() {
    this instanceof AllocateOrDeallocateStdlibMemberFunction and
    this.getName() = "deallocate"
  }
}

from FunctionCall call, string message
where
  not isExcluded(call, Banned7Package::dynamicMemoryShouldNotBeUsedQuery()) and
  (
    // Direct allocation: malloc, calloc, realloc, aligned_alloc, operator new, operator new[]
    call.getTarget() instanceof DirectDynamicMemoryAllocatingFunction and
    message = "Call to dynamic memory allocating function '" + call.getTarget().getName() + "'."
    or
    // Indirect allocation: std library types that allocate internally
    call.getTarget() instanceof IndirectDynamicMemoryAllocatingFunction and
    message =
      "Call to '" + call.getTarget().getName() +
        "' that dynamically allocates memory via the standard library."
    or
    // Deallocation: free, operator delete, operator delete[], std::allocator::deallocate
    // Excludes realloc (already caught as allocation).
    call.getTarget() instanceof DynamicMemoryDeallocatingFunction and
    not call.getTarget() instanceof DynamicMemoryAllocatingFunction and
    message = "Call to dynamic memory deallocating function '" + call.getTarget().getName() + "'."
  )
select call, message
