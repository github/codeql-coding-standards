/**
 * @id cpp/cert/joinable-thread-copied-or-destroyed-cert
 * @name ERR50-CPP: Destroying or copy assigning a joinable thread abruptly terminates the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/err50-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.joinablethreadcopiedordestroyed.JoinableThreadCopiedOrDestroyed

class JoinableThreadCopiedOrDestroyedCertQuery extends JoinableThreadCopiedOrDestroyedSharedQuery {
  JoinableThreadCopiedOrDestroyedCertQuery() {
    this = Exceptions1Package::joinableThreadCopiedOrDestroyedCertQuery()
  }
}
