#include <stdio.h>
#include <math.h>

unsigned long long int pow2( int n ) {
    if (n==0) {
        return 1;
    }
    return 2*pow2(n-1);
}

unsigned long long int Pow10( int n ) {
    if (n==0) {
        return 1;
    }
    return 10*Pow10(n-1);
}

unsigned long long fact( int n ) {
    if (n==1) {
        return 1;
    }
    return n*fact(n-1);
}

int main () {
    int i,j; // index
    unsigned long long times[7] = {Pow10(6), // 1 second = 10^6 usec
                                   Pow10(6)*60, // 1 minute = 6*10^7 usec
                                   Pow10(6)*60*60, // 1 hour = 36 * 10^8 usec
                                   Pow10(6)*60*60*24, // 1 day = 864 * 10^8 usec
                                   Pow10(6)*60*60*24*30, // 1 month = 2592 * 10^9 usec
                                   Pow10(6)*60*60*24*365, // 1 year = 31536 * 10^9 usec
                                   Pow10(6)*60*60*24*365*100 // 1 century = 31536 * 10^11 usec
                                   };
    unsigned long long t;
    char format_string[20];
    int col_widths[7] = {16,17,19,20,22,23,25};
    int first_col_width = 10;
    
    char initial_rows[5][8][30]={
            {"","1 second","1 minute","1 hour","1 day","1 month","1 year","1 century"},
            {"---","---","---","---","---","---","---","---"},
            {"$\\lg n$"},
            {"$\\sqrt{n}$"},
            {"$n$"},
        };
    
    for (i=1;i<8;i++) {
        sprintf(initial_rows[2][i],"$2^{%llu}$",times[i-1]);
        sprintf(initial_rows[3][i],"$\\sqrt{%llu}$",times[i-1]);
        sprintf(initial_rows[4][i],"$%llu$",times[i-1]);
    }
    for (i=0;i<5;i++) {
        printf("|");
        // Little trick to allow printing formatted string with parameters in a variable
        sprintf(format_string," %c%ds |",'%',first_col_width);
        printf(format_string,initial_rows[i][0]);
        for (j=1;j<8;j++) {
            sprintf(format_string," %c%ds |",'%',col_widths[j-1]);
            printf(format_string,initial_rows[i][j]);
        }
        printf("\n");
    }
    
    // For the next ones, the largest n for which f(n)<=t will be found with the bisection method.
    // We can use the interval [0,t], as the functions always satisfy f(t)>t>f(0)=1 or 0
    unsigned long long n_l,n_u,mi; //lower n, upper n, middle
    
    // Solve n lg n <=t
    
    sprintf(format_string,"| %c%ds |",'%',first_col_width);
    printf(format_string,"$n\\lg n$");
    for (i=0;i<7;i++) {
        t=  times[i];
        n_l = 0;
        n_u = t;
        while (n_l+1<n_u) {
            mi = (n_l+n_u)/2;
             if (mi * log2((double)mi) <= t) {
                n_l=mi;
            } else {
                n_u=mi;
            }
        }
        
        sprintf(format_string," %c%dllu |",'%',col_widths[i]);
        printf(format_string,n_l);
    }
    
    printf("\n");
        
    // Solve n^2 <=t
    
    sprintf(format_string,"| %c%ds |",'%',first_col_width);
    printf(format_string,"$n^2$");
    for (i=0;i<7;i++) {
        t=  times[i];
        n_l = 0;
        n_u = t;
        while (n_l+1<n_u) {
            mi = (n_l+n_u)/2;
             if (mi * mi <= t) {
                n_l=mi;
            } else {
                n_u=mi;
            }
        }
        
        sprintf(format_string," %c%dllu |",'%',col_widths[i]);
        printf(format_string,n_l);
    }
    
    printf("\n");
        
    // Solve n^3 <=t
    
    sprintf(format_string,"| %c%ds |",'%',first_col_width);
    printf(format_string,"$n^3$");
    for (i=0;i<7;i++) {
        t=  times[i];
        n_l = 0;
        n_u = t;
        while (n_l+1<n_u) {
            mi = (n_l+n_u)/2;
             if (mi * mi * mi<= t) {
                n_l=mi;
            } else {
                n_u=mi;
            }
        }
        
        sprintf(format_string," %c%dllu |",'%',col_widths[i]);
        printf(format_string,n_l);
    }
    
    printf("\n");
        
    // Solve 2^n <=t
    
    sprintf(format_string,"| %c%ds |",'%',first_col_width);
    printf(format_string,"$2^n$");
    for (i=0;i<7;i++) {
        t=  times[i];
        n_l = 0;
        /*
            Here, taking n_u = t would entail calculating 2^t, which is too large.
            We can choose a smaller upper bound: The largest t is
                t = 10^6*60*60*24*365*100
                  = (2^6 * 5^6) *(3 * 5 * 2^2) * (3 * 5 * 2^2) * (2^3 * 3) * (73 * 5) * (2^2 * 5^2)
                  = 2^15 * 3^3 * 5^11 * 73
                  < 2^15 * 3^3 * (5^3)^4 * 73
                  = 2^15 * 27 * (125)^4 * 73
                  < 2^15 * 32 * (128)^4 * 128
                  = 2^15 * 2^5 * (2^7)^4 * 2^7
                  = 2^55
            so taking n_u=55 is more than enough.
        */
        n_u = 55;
        while (n_l+1<n_u) {
            mi = (n_l+n_u)/2;
             if (pow2(mi)<= t) {
                n_l=mi;
            } else {
                n_u=mi;
            }
        }
        
        sprintf(format_string," %c%dllu |",'%',col_widths[i]);
        printf(format_string,n_l);
    }
    
    printf("\n");
    
    // Solve n! <=t
    
    sprintf(format_string,"| %c%ds |",'%',first_col_width);
    printf(format_string,"$n!$");
    
    /*
        In this case, as factorials grow extremely fast, we can simply do a linear search starting at 1.
        
        Compiling the previous row already lets us know that n<=51 (as we also know that 51!>2^51, clearly).
        
        We could also implement factorials implicity here for better performance, but the code below is more readable.
    */
    n_l=1;
    
    for (i=0;i<7;i++) {
        t = times[i];
        
        while (fact(n_l)<=t) n_l++;
        sprintf(format_string," %c%dllu |",'%',col_widths[i]);
        printf(format_string,n_l-1);
    }
    
    printf("\n");
    
    return 0;
}     
