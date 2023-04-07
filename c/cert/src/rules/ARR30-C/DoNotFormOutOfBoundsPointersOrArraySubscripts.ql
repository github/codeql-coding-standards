/**
 * @id c/cert/do-not-form-out-of-bounds-pointers-or-array-subscripts
 * @name ARR30-C: Do not form or use out-of-bounds pointers or array subscripts
 * @description Forming or using an out-of-bounds pointer is undefined behavior and can result in
 *              invalid memory accesses.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/arr30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

 import cpp
 import codingstandards.c.cert
 import codingstandards.c.OutOfBounds
 
 from
   OOB::BufferAccess ba, Expr bufferArg, Expr sizeArg, OOB::PointerToObjectSource bufferSource,
   string message
 where
   not isExcluded(ba, OutOfBoundsPackage::doNotFormOutOfBoundsPointersOrArraySubscriptsQuery()) and
   // exclude loops
   not exists(Loop loop | loop.getStmt().getChildStmt*() = ba.getEnclosingStmt()) and
   // exclude size arguments that are of type ssize_t
   not sizeArg.getAChild*().(VariableAccess).getTarget().getType() instanceof Ssize_t and
   // exclude size arguments that are assigned the result of a function call e.g. ftell
   not sizeArg.getAChild*().(VariableAccess).getTarget().getAnAssignedValue() instanceof FunctionCall and
   // exclude field or array accesses for the size arguments
   not sizeArg.getAChild*() instanceof FieldAccess and
   not sizeArg.getAChild*() instanceof ArrayExpr and
   (
     exists(int sizeArgValue, int bufferArgSize |
      OOB::isSizeArgGreaterThanBufferSize(bufferArg, sizeArg, bufferSource, bufferArgSize, sizeArgValue, ba) and
       message =
         "Buffer accesses offset " + sizeArgValue + 
         " which is greater than the fixed size " + bufferArgSize + " of the $@."
     )
     or
     exists(int sizeArgUpperBound, int sizeMult, int bufferArgSize |
       OOB::isSizeArgNotCheckedLessThanFixedBufferSize(bufferArg, sizeArg, bufferSource,
         bufferArgSize, ba, sizeArgUpperBound, sizeMult) and
       message =
         "Buffer may access up to offset " + sizeArgUpperBound + "*" + sizeMult +
           " which is greater than the fixed size " + bufferArgSize + " of the $@."
     )
     or
     OOB::isSizeArgNotCheckedGreaterThanZero(bufferArg, sizeArg, bufferSource, ba) and
     message = "Buffer access may be to a negative index in the buffer."
   )
 select ba, message, bufferSource, "buffer"