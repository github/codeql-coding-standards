#include <stdatomic.h>
#include <stddef.h>
#include <threads.h>
  
mtx_t mx;
 
int t1(void *dummy) {
  mtx_lock(&mx);
  mtx_unlock(&mx);
  return 0;
}
 
int f1() {
  thrd_t threads[5];
   
  mtx_init(&mx, mtx_plain);
  
  for (size_t i = 0; i < 5; i++) {
    thrd_create(&threads[i], t1, NULL);
    
  }
  for (size_t i = 0; i < 5; i++) {
    thrd_join(threads[i], 0);
  }
 
  mtx_destroy(&mx);
  return 0;
}

int f2() {
  thrd_t threads[5];
   
  mtx_init(&mx, mtx_plain);
  
  for (size_t i = 0; i < 5; i++) {
    thrd_create(&threads[i], t1, NULL);   
  }

  mtx_destroy(&mx);
  return 0;
}