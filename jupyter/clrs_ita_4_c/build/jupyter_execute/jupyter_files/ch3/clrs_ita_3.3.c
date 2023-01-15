#include <math.h>
#include <stdio.h>

unsigned long long fact( unsigned long long n) ; // factorial
unsigned long long pow_long(unsigned long long m , unsigned long long n) ; // m^n

int main() {
    unsigned long long k,n;
    
    printf("| %7s | %19s | %14s |\n","n","ceil(lg n)!","ceil(lg lg n)!");
    printf("|---------|---------------------|----------------|\n");
    
    printf("| %7d | %19d | %14s |\n",1,fact(ceil(log2(1))),"undefined" ); // n=1
    for (k=1;k<21;k++) {
        n=pow_long(2,k);
        printf("| %7llu | %19llu | %14llu |\n",n,fact(ceil(log2(n))),fact(ceil(log2(log2(n)))) );
    }
    
    return 0;
}

unsigned long long fact( unsigned long long n) {
    if (n==0) return 1;
    return n*fact(n-1);
}

unsigned long long pow_long(unsigned long long m,unsigned long long n){
    if (n==0) return 1;
    return m*pow_long(m,n-1);
}
