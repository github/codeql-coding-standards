/**
 * Provides the class `InformationLeakBoundary`, which models data-flow sinks
 * where information is passed across a trust boundary.
 */

import cpp

/**
 * A data-flow sink where information is passed across a trust boundary. Internal pointer values and
 * uninitialized data should not leak across such a boundary since that can constitute an
 * _information leak_, which is commonly used to defeat address-space layout randomization.
 */
abstract class InformationLeakBoundary extends Expr { }

/**
 * The second argument to a call to `copy_to_user`, typically used by Linux kernels to copy data
 * from kernel mode to user mode.
 */
class LinuxKernelInformationLeakBoundary extends InformationLeakBoundary {
  LinuxKernelInformationLeakBoundary() {
    exists(FunctionCall call |
      call.getTarget().getName() = "copy_to_user" and
      this = call.getArgument(1)
    )
  }
}

/**
 * The first argumnent to a call to `copyout` and derviates, typically used by BSD/XNU kernels to
 * copy data from kernel mode to user mode.
 */
class BSDXNUInformationLeakBoundary extends InformationLeakBoundary {
  BSDXNUInformationLeakBoundary() {
    // BSD and XNU kernels
    exists(FunctionCall call |
      call.getTarget().getName().regexpMatch("copyout(_nofault)?") and
      this = call.getArgument(0)
    )
  }
}
