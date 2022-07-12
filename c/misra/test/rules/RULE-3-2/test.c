// clang-format off

void f0(){

    // NON_COMPLIANT
    int a; // \
    if(a > 1)
    {
        a++;
    }
}

void f1(){

    // NON_COMPLIANT
    int a; // \\
    if(a > 1)
    {
        a++;
    }
}

void f2(){

    // COMPLIANT[FALSE_POSITIVE] - has a space
    int a; // \ 
    if(a > 1)
    {
        a++;
    }
}

void f3(){

    // COMPLIANT[FALSE_POSITIVE] - has a space 
    int a; // \\ 
    if(a > 1)
    {
        a++;
    }
}




void f4(){

    // COMPLIANT
    int a; // \ n
    if(a > 1)
    {
        a++;
    }
}

void f5(){

    // COMPLIANT
    int a; // \\ n
    if(a > 1)
    {
        a++;
    }
}
