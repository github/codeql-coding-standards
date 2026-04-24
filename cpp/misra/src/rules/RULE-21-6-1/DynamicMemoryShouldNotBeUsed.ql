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
import codingstandards.cpp.allocations.CustomOperatorNewDelete

/**
 * A function that directly or indirectly allocates dynamic memory.
 */
abstract class DynamicMemoryAllocatingFunction extends Function { }

/**
 * A function that directly allocates dynamic memory.
 * Includes C allocation functions (`malloc`, `calloc`, realloc`,` `aligned_alloc`)
 * and C++ allocation functions (`operator new`, `operator new[]`).
 *
 * This excludes placement-new operators, as they do not allocate memory themselves.
 */
class DirectDynamicMemoryAllocatingFunction extends DynamicMemoryAllocatingFunction {
  DirectDynamicMemoryAllocatingFunction() {
    this instanceof AllocationFunction and
    not this instanceof PlacementOperatorNew
    or
    /*
     * TEMP: `aligned_alloc` is not modeled by `AllocationFunction` in cpp-all@5.0.0
     * which this query currently depends on. The PR
     * https://github.com/github/codeql/pull/21725 fixes this, so we can delete this
     * exception case after we bump to the newest version.
     */

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
 * A constructor of a standard library classes that uses `std::allocator` directly
 * as template argument or under the hood as the default value of the template argument.
 * This class can be divided into big categories:
 *
 * 1. A constructor of standard library containers such as `vector`, `deque`, `unordered_set`.
 * 2. A constructor of standard library strings such as `string`, `wstring` that derives from
 *    `std::basic_string`.
 */
class AllocatorConstructor extends IndirectDynamicMemoryAllocatingFunction {
  AllocatorConstructor() {
    this instanceof Constructor and
    /* Ensure that the constructor accepts a `std::allocator`. */
    this.getDeclaringType()
        .(ClassTemplateInstantiation)
        .getATemplateArgument()
        .(Type)
        .resolveTypedefs() instanceof StdAllocator
  }
}

/**
 * A constructor of a container adaptor that contains an allocating container by default.
 * Includes `stack` (contains `deque`), `queue` (contains `deque`), and `priority_queue`
 * (contains `vector`).
 */
class ContainerAdaptorConstructor extends IndirectDynamicMemoryAllocatingFunction {
  ContainerAdaptorConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", ["stack", "queue", "priority_queue"])
  }
}

/**
 * A constructor of a string stream that contains `std::basic_string` for buffer storage.
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
 * A constructor of a type-erasing wrapper that may allocate via `operator new`.
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
 * Includes `promise`, `future`, `shared_future`, `packaged_task`, and `locale`.
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
 * A constructor of `std::valarray` that allocates dynamic memory.
 */
class ValarrayConstructor extends IndirectDynamicMemoryAllocatingFunction {
  ValarrayConstructor() {
    this instanceof Constructor and
    this.getDeclaringType().hasQualifiedName("std", "valarray")
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
 *
 * Includes C deallocation functions (`free`) and C++ deallocation functions
 * (`operator delete`, `operator delete[]`, `~T()` for any `T`.)
 */
class DirectDynamicMemoryDeallocatingFunction extends DynamicMemoryDeallocatingFunction {
  DirectDynamicMemoryDeallocatingFunction() {
    this instanceof DeallocationFunction or
    this instanceof Destructor
  }
}

/**
 * A function that indirectly deallocates dynamic memory through standard
 * library classes and their member functions (e.g. `std::allocator::deallocate`).
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
    /* 1. Direct allocation: malloc, calloc, realloc, aligned_alloc, operator new, operator new[]. */
    call.getTarget() instanceof DirectDynamicMemoryAllocatingFunction and
    message = "Call to dynamic memory allocating function '" + call.getTarget().getName() + "'."
    or
    /* 2. Indirect allocation: C++ standard library types that allocate internally. */
    call.getTarget() instanceof IndirectDynamicMemoryAllocatingFunction and
    (
      if call.getTarget() instanceof AllocatorConstructor
      then
        message =
          "Initialization of an object of class '" + call.getTarget().getName() +
            "' that uses 'std::allocator<T>'."
      else
        message =
          "Initialization of an object of class '" + call.getTarget().getName() +
            "' that dynamically allocates memory internally."
    )
    or
    /*
     * 3. Deallocation: free, operator delete, operator delete[], std::allocator::deallocate.
     * Excludes realloc (already caught as allocation).
     */

    (
      call.getTarget() instanceof DynamicMemoryDeallocatingFunction and
      (
        call instanceof DestructorCall implies not call.isCompilerGenerated() // Exclude RAII constructor calls.
      )
    ) and
    not call.getTarget() instanceof DynamicMemoryAllocatingFunction and // Exclude `realloc`.
    message = "Call to '" + call.getTarget().getName() + "' that dynamically deallocates memory."
  )
select call, message
