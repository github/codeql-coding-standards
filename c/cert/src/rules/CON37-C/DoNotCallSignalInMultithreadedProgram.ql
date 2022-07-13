/**
 * @id c/cert/do-not-call-signal-in-multithreaded-program
 * @name CON37-C: Do not call signal() in a multithreaded program
 * @description Calling signal() from within a multithreaded program can result in unpredictable
 *              program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con37-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency

from FunctionCall fc
// This should only be applied in the context of a multi-threaded program (since
// it is valid to be used in a non-threaded program) so we filter those types of
// programs out here
where
  not isExcluded(fc, Concurrency1Package::doNotCallSignalInMultithreadedProgramQuery()) and
  fc.getTarget().getName() = "signal" and
  exists(ThreadedFunction f)
select fc,
  "Call to `signal()` in multithreaded programs."
