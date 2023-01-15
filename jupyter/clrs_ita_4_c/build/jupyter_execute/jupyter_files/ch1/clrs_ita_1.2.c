#include <stdio.h>

unsigned long long pow_long(int m,unsigned int n) {
    // Returns m^n for m,n integers, n positive
    int i; // index
    unsigned long long int p=1; // m^0
    for (i=0;i<n;i++) {
        p*=m;
    }
    
    return p;
}

int main() {
    int n=2;
    while (pow_long(2,n) < pow_long(n,8)) n++;
    
    printf("The first n for which 2^n>n^8 is n=%d.\nIn this case, 2^n = %lld and n^8=%lld.\n",n,pow_long(2,n),pow_long(n,8));
    return 0;
}

#include <stdio.h>

int main() {
    printf("  n | 100n^2 |   2^n\n"
           "---------------------\n");
    int n=1;
    long long lhs = 100;
    long long rhs = 2; // 2^1
    while (lhs>rhs) {
        printf(" %2lld | %6lld | %5lld \n",n,lhs,rhs);
        n++;
        lhs = 100 * n * n;
        rhs *= 2;
    }
    printf(" %2lld | %6lld | %5lld \n",n,lhs,rhs);
    
    return 0;
}
