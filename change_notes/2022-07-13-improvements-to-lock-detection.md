- `CON53-CPP` - `DeadlockByLockingInPredefinedOrder.ql`
  - Optimized performance and expanded coverage to include cases where locking
    order is not serialized 
- `CON52-CPP` - `PreventBitFieldAccessFromMultipleThreads.ql`
  - Fixed an issue with RAII-style locks and scope causing locks to not be
    correctly identified. 