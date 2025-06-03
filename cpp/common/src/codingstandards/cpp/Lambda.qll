import codingstandards.cpp.alertreporting.CustomPathStateProblem
import codingstandards.cpp.Expr
import codingstandards.cpp.Scope

signature class LambdaSig extends LambdaExpression;

class ImplicitThisCapturingLambdaExpr extends LambdaExpression {
  ImplicitThisCapturingLambdaExpr() {
    exists(LambdaCapture capture |
      capture = getACapture() and
      capture.getField().getName() = "(captured this)" and
      capture.isImplicit()
    )
  }
}

class ImplicitCaptureLambdaExpr extends LambdaExpression {
  LambdaCapture capture;

  ImplicitCaptureLambdaExpr() { capture = getCapture(_) and capture.isImplicit() }

  LambdaCapture getImplicitCapture() { result = capture }
}

/**
 * A module to find lambda expressions that are eventually copied or moved.
 *
 * Unfortunately, CodeQL does not capture all lambda flow or all lambda copies/moves. However,
 * since lambdas can only be used in an extremely limited number of ways, we can easily roll our
 * own dataflow-like analysis as a custom path problem, to match lambdas to stores.
 */
module TransientLambda<LambdaSig Source> {
  final class FinalLocatable = Locatable;

  /**
   * Create a custom path problem, which inherently performs a graph search to find paths from start
   * nodes (in this case, lambda expressions) to end nodes (in this case, copies and moves of
   * lambdas).
   */
  private module TransientLambdaConfig implements CustomPathStateProblemConfigSig {
    class Node extends FinalLocatable {
      Node() {
        this instanceof Source
        or
        this instanceof Variable
        or
        this.(VariableAccess).getTarget() instanceof Parameter
        or
        this instanceof Expr
        or
        this instanceof Function
        or
        this instanceof NewExpr
      }
    }

    class State = TranslationUnit;

    // Do not search past the first copy or move of a lambda.
    predicate searchPastEnd() { none() }

    predicate start(Node n, TranslationUnit state) { n instanceof Source and state = n.getFile() }

    bindingset[state]
    pragma[inline_late]
    predicate end(Node n, TranslationUnit state) {
      n instanceof Variable and not n instanceof Parameter
      or
      n instanceof Function and
      not functionDefinedInTranslationUnit(n, state)
      or
      exists(NewExpr alloc |
        alloc = n and
        alloc.getAllocatedType().stripTopLevelSpecifiers() instanceof Closure
      )
    }

    predicate edge(Node a, TranslationUnit s1, Node b, TranslationUnit s2) {
      s2 = s1 and
      (
        a = b.(Variable).getInitializer().getExpr()
        or
        exists(Call fc, int i |
          a = fc.getArgument(i) and
          (
            b = fc.getTarget().getParameter(i)
            or
            b = fc.getTarget()
          )
        )
        or
        exists(Call fc, Function f, ReturnStmt ret |
          f = fc.getTarget() and
          ret.getEnclosingFunction() = f and
          a = ret.getExpr() and
          b = fc
        )
        or
        b = a.(Parameter).getAnAccess()
        or
        temporaryObjectFlowStep(a, b)
        or
        a = b.(NewExpr).getInitializer()
      )
    }
  }

  import CustomPathStateProblem<TransientLambdaConfig> as TransientFlow

  module PathProblem {
    import TransientFlow
  }

  predicate isStored(Source lambda, Element store, string reason) {
    TransientFlow::problem(lambda, store) and
    (
      if store instanceof Function and not functionDefinedInTranslationUnit(store, lambda.getFile())
      then reason = "passed to a different translation unit"
      else reason = "copied or moved"
    )
  }
}

/**
 * An alterate module for detecting transient lambdas which uses the standard CodeQL dataflow
 * library.
 *
 * Ideally, this module eventually replaces `TransientLambda`, however, current CodeQL support for
 * flow of lambdas is unreliable and incomplete/inconsistent. This implementation does not detect
 * all cases correctly, but it is a starting place to revisit at a later time.
 *
 * In the current dataflow library, there are many missing nodes and edges, making this currently
 * difficult or impossible to implement correctly.
 */
module TransientLambdaDataFlow<LambdaSig Source> {
  import semmle.code.cpp.dataflow.new.DataFlow as DataFlow
  import DataFlow::DataFlow as NewDataFlow

  final class FinalLocatable = Locatable;

  /**
   * Create a custom path problem, which inherently performs a graph search to find paths from start
   * nodes (in this case, lambda expressions) to end nodes (in this case, copies and moves of
   * lambdas).
   */
  module TransientLambdaConfig implements NewDataFlow::StateConfigSig {
    class FlowState = TranslationUnit;

    predicate isSource(NewDataFlow::Node n, TranslationUnit state) {
      n.asExpr() instanceof Source and state = n.asExpr().getFile()
    }

    predicate isSink(NewDataFlow::Node n) {
      n.asOperand().getDef().getAst() instanceof VariableDeclarationEntry
      or
      exists(n.asVariable()) and not exists(n.asParameter())
      or
      exists(NewExpr alloc |
        alloc.getAllocatedType() instanceof Closure and
        alloc.getInitializer() = n.asExpr()
      )
      or
      // Detect casting to std::function, which results in a copy of the lambda.
      exists(Conversion conv | conv.getExpr() = n.asExpr())
      or
      // Detect all function calls, in case the definition is in a different translation unit.
      // We cannot detect this with stateful dataflow, for performance reasons.
      exists(FunctionCall fc | fc.getAnArgument() = n.asExpr())
    }

    predicate isSink(NewDataFlow::Node n, TranslationUnit state) {
      // Ideally, we would be able to check here for calls to functions defined outside of the
      // translation unit, but in the current stateful dataflow library, this will result in a
      // cartesian product of all nodes with all translation units. This limitation doesn't exist
      // in the alternate `TransientLambda` module which uses `CustomPathStateProblem`.
      //
      // Since this predicate holds for none(), it may seem that we don't need to use stateful flow.
      // However, stateful flow is still a good idea so that we can add isBarrier() to prevent flow
      // out of the translation unit. That should be possible to do without introducing a
      // cartesian product.
      //
      // To work around the cartesian product, this predicate holds for none() and `isSink(n)`
      // should hold for all function calls. After flow has found lambda/function call pairs, we
      // can filter out those pairs where the function is defined in a different translation unit.
      //
      // This isn't quite implemented yet.
      none()
    }

    predicate isBarrierOut(NewDataFlow::Node n, TranslationUnit state) {
      // TODO: Implement a barrier to prevent flow out of the translation unit.
      none()
    }

    predicate isAdditionalFlowStep(
      NewDataFlow::Node a, TranslationUnit s1, NewDataFlow::Node b, TranslationUnit s2
    ) {
      // Add additional flow steps to handle:
      //
      // auto x = []() { ... };
      //
      // Which isn't represented in the dataflow graph otherwise.
      pragma[only_bind_out](s2) = s1 and
      (
        pragma[only_bind_out](a.asExpr()) =
          b.asOperand()
              .getDef()
              .getAst()
              .(VariableDeclarationEntry)
              .getVariable()
              .getInitializer()
              .getExpr()
        or
        a.asExpr().(Conversion).getExpr() = b.asExpr()
      )
    }
  }

  import NewDataFlow::GlobalWithState<TransientLambdaConfig> as TransientFlow

  module PathProblem {
    import TransientFlow::PathGraph
  }

  predicate isStored(Source lambda, Element store) {
    exists(NewDataFlow::Node sink |
      TransientFlow::flow(NewDataFlow::exprNode(lambda), sink) and
      store = sink.asOperand().getDef().getAst() and
      not exists(FunctionCall fc |
        fc.getAnArgument() = sink.asExpr() and
        exists(FunctionDeclarationEntry funcDef |
          funcDef = fc.getTarget().getDefinition() and
          funcDef.getFile() = lambda.getFile().(TranslationUnit).getATransitivelyIncludedFile()
        )
      )
    )
  }
}
