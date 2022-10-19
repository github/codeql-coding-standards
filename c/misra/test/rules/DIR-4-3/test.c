#define N1 asm("HCF") 
#define N2 __asm__("HCF") 

void f1(){
    int a;
    N1; // NON_COMPLIANT 
}

void f2(){
    int a;
    N2; // NON_COMPLIANT 
}

void f3(){
    N1;
}

void f4(){
    N2;
}

void f5(){
    __asm__("HCF");
}

void f6(){
    asm("HCF");
}

inline void f7(){
    int a;
    N1; // NON_COMPLIANT 
}

inline void f8(){
    int a;
    N2; // NON_COMPLIANT 
}

inline void f9(){
    N1;
}

inline void f10(){
    N2;
}

inline void f11(){
    __asm__("HCF");
}

inline void f12(){
    asm("HCF");
}