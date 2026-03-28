/**
 * Provides a configurable module PossibleDataRaceBetweenThreadsShared with a `problems` predicate
 * for the following issue:
 * Threads shall not access the same memory location concurrently without utilization
 * of thread synchronization objects.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency
import codingstandards.cpp.lifetimes.StorageDuration

signature module PossibleDataRaceBetweenThreadsSharedConfigSig {
  Query getQuery();

  class ObjectIdentity extends Element {
    StorageDuration getStorageDuration();
  }

  class SubObject {
    string toString();

    ObjectIdentity getRootIdentity();

    Expr getAnAccess();
  }
}

module PossibleDataRaceBetweenThreadsShared<PossibleDataRaceBetweenThreadsSharedConfigSig Config> {
  newtype TNonReentrantOperation =
    TReadWrite(Config::SubObject object) {
      object.getRootIdentity().getStorageDuration().isStatic()
      or
      object.getRootIdentity().getStorageDuration().isAllocated()
    } or
    TStdFunctionCall(FunctionCall call) {
      call.getTarget()
          .hasName([
              "setlocale", "tmpnam", "rand", "srand", "getenv", "getenv_s", "strtok", "strerror",
              "asctime", "ctime", "gmtime", "localtime", "mbrtoc16", "c16rtomb", "mbrtoc32",
              "c32rtomb", "mbrlen", "mbrtowc", "wcrtomb", "mbsrtowcs", "wcsrtombs"
            ])
    }

  class NonReentrantOperation extends TNonReentrantOperation {
    string toString() {
      exists(Config::SubObject object |
        this = TReadWrite(object) and
        result = object.toString()
      )
      or
      exists(FunctionCall call |
        this = TStdFunctionCall(call) and
        result = call.getTarget().getName()
      )
    }

    Expr getAReadExpr() {
      exists(Config::SubObject object |
        this = TReadWrite(object) and
        result = object.getAnAccess()
      )
      or
      this = TStdFunctionCall(result)
    }

    Expr getAWriteExpr() {
      exists(Config::SubObject object, Assignment assignment |
        this = TReadWrite(object) and
        result = assignment and
        assignment.getLValue() = object.getAnAccess()
      )
      or
      this = TStdFunctionCall(result)
    }

    string getReadString() {
      this = TReadWrite(_) and
      result = "read operation"
      or
      this = TStdFunctionCall(_) and
      result = "call to non-reentrant function"
    }

    string getWriteString() {
      this = TReadWrite(_) and
      result = "write to object"
      or
      this = TStdFunctionCall(_) and
      result = "call to non-reentrant function"
    }

    Element getSourceElement() {
      exists(Config::SubObject object |
        this = TReadWrite(object) and
        result = object.getRootIdentity()
      )
      or
      this = TStdFunctionCall(result)
    }
  }

  class WritingThread extends ThreadedFunction {
    NonReentrantOperation aWriteObject;
    Expr aWriteExpr;

    WritingThread() {
      aWriteExpr = aWriteObject.getAWriteExpr() and
      // This function directly contains the write expression, or transitively calls the function
      // that contains the write expression.
      this.calls*(aWriteExpr.getEnclosingFunction()) and
      // The write isn't synchronized with a mutex or condition object.
      not aWriteExpr instanceof LockProtectedControlFlowNode and
      // The write doesn't seem to be during a special initialization phase of the program.
      not aWriteExpr.getEnclosingFunction().getName().matches(["%init%", "%boot%", "%start%"])
    }

    Expr getAWriteExpr() { result = aWriteExpr }
  }

  class ReadingThread extends ThreadedFunction {
    Expr aReadExpr;

    ReadingThread() {
      exists(NonReentrantOperation op |
        aReadExpr = op.getAReadExpr() and
        this.calls*(aReadExpr.getEnclosingFunction()) and
        not aReadExpr instanceof LockProtectedControlFlowNode
      )
    }

    Expr getAReadExpr() { result = aReadExpr }
  }

  predicate mayBeDataRace(Expr write, Expr read, NonReentrantOperation operation) {
    exists(WritingThread wt |
      wt.getAWriteExpr() = write and
      write = operation.getAWriteExpr() and
      exists(ReadingThread rt |
        read = rt.getAReadExpr() and
        read = operation.getAReadExpr() and
        (
          wt.isMultiplySpawned() or
          not wt = rt
        )
      )
    )
  }

  query predicate problems(
    Expr write, string message, Element operationSource, string operationName, WritingThread wt,
    string wtName, Expr read, string readConcurrent, ReadingThread rt, string rtName
  ) {
    exists(NonReentrantOperation operation, string writeString, string readString |
      not isExcluded(write, Config::getQuery()) and
      mayBeDataRace(write, read, operation) and
      wt = min(WritingThread f | f.getAWriteExpr() = write | f order by f.getName()) and
      rt = min(ReadingThread f | f.getAReadExpr() = read | f order by f.getName()) and
      writeString = operation.getWriteString() and
      readString = operation.getReadString() and
      operationSource = operation.getSourceElement() and
      operationName = operation.toString() and
      wtName = wt.getName() and
      readConcurrent = "concurrent " + readString and
      rtName = rt.getName() and
      if wt.isMultiplySpawned()
      then
        message =
          "Threaded " + writeString +
            " $@ not synchronized from thread function $@ spawned from a loop."
      else
        message =
          "Threaded " + writeString +
            " $@ from thread function $@ is not synchronized with $@ from thread function $@."
    )
  }
}
