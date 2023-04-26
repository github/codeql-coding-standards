 * `A4-7-1` - `IntegerExpressionLeadToDataLoss.ql` - reduce false positives and false negatives by:
   - Identifying additional categories of valid guard.
   - Excluding guards which were not proven to prevent overflow or underflow.
   - Expand coverage to include unary operations and arithmetic assignment operations.