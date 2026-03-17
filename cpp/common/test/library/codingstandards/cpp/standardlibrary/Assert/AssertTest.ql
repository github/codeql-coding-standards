import cpp
import codingstandards.cpp.standardlibrary.Assert
import utils.test.InlineExpectationsTest

module AssertTest implements TestSig {
  string getARelevantTag() { result = ["asserts_false", "condition"] }

  predicate hasActualResult(Location location, string element, string tag, string value) {
    exists(AssertInvocation assert, Expr condition |
      condition = assert.getAssertCondition() and
      location = assert.getLocation() and
      element = condition.toString() and
      (
        tag = "condition" and
        value = condition.toString().replaceAll(" ", "")
        or
        tag = "asserts_false" and
        value = "true" and
        assert.isAssertFalse()
      )
    )
  }
}

import MakeTest<AssertTest>
