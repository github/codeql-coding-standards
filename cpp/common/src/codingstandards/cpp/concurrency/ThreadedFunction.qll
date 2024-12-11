import cpp
private import codingstandards.cpp.concurrency.ThreadCreation

/**
 * Models a function that may be executed by some thread.
 */
abstract class ThreadedFunctionBase extends Function {
  abstract Expr getSpawnExpr();

  predicate isMultiplySpawned() { getSpawnExpr().getBasicBlock().inLoop() }
}

final class ThreadedFunction = ThreadedFunctionBase;

/**
 * Models a function that may be executed by some thread via
 * C++ standard classes.
 */
class CPPThreadedFunction extends ThreadedFunctionBase {
  ThreadConstructorCall tcc;

  CPPThreadedFunction() { tcc.getFunction() = this }

  override Expr getSpawnExpr() { result = tcc }
}

/**
 * Models a function that may be executed by some thread via
 * C11 standard functions.
 */
class C11ThreadedFunction extends ThreadedFunctionBase {
  C11ThreadCreateCall cc;

  C11ThreadedFunction() { cc.getFunction() = this }

  override Expr getSpawnExpr() { result = cc }
}
