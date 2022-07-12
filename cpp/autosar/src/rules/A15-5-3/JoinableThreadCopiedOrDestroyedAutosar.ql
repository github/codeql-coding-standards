/**
 * @id cpp/autosar/joinable-thread-copied-or-destroyed-autosar
 * @name A15-5-3: Destroying or copy assigning a joinable thread abruptly terminates the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/a15-5-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.joinablethreadcopiedordestroyed.JoinableThreadCopiedOrDestroyed

class JoinableThreadCopiedOrDestroyedAutosarQuery extends JoinableThreadCopiedOrDestroyedSharedQuery {
  JoinableThreadCopiedOrDestroyedAutosarQuery() {
    this = Exceptions1Package::joinableThreadCopiedOrDestroyedAutosarQuery()
  }
}
