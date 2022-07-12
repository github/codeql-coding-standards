- `A3-1-5` - `TrivialOrTemplateFunctionDefinedOutsideClassDefinition.ql`
  - Fix #470 by ignoring destructors defined outside of classes and also fixing a statement counting bug in the trivial (short) function definition where child statements of while statements were not considered in the function length.
  