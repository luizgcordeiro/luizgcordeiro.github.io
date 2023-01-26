#include <stdio.h>
#include <time.h>

// Standard matrix multiplication for comparison
// Only square matrices, just as in Strassen's algorithm

unsigned long long matrix_multiply ( int ** A , int ** B , int ** C , size_t n ) {
    // Standard matrix multiplication
    
    unsigned long long ops = 0; // number of operations
    size_t i,j,k; // indices
    for (i=0;i<n;i++) {
        for (j=0;j<n;j++) {
            for (k=0;k<n;k++) {
                C[i][j] += A[i][k]*B[k][j];
                ops+=2;
            }
        }
    }
    return ops;
}

// Matrix addition is necessary for Strassen's algorithm

unsigned long long matrix_add ( int ** A , size_t iA , size_t jA ,
                 int ** B , size_t iB , size_t jB ,
                 int ** C , size_t iC , size_t jC ,
                 size_t n ) {
    /*
        Matrix addition for square submatrices of order n, with indices
            i*, i*+1, ... i*+(n-1)
        and similarly for j*
    */
    
    // Could be made recursive.
    
    unsigned long long ops = 0; // number of operations
    size_t i,j; // indices
    for (i=0;i<n;i++) {
        for (j=0;j<n;j++) {
            C[iC+i][jC+j] += A[iA+i][jA+j]+B[iB+i][jB+j];
            ops+=2;
        }
    }
    
    return ops;
}

unsigned long long matrix_subtract ( int ** A , size_t iA , size_t jA ,
                      int ** B , size_t iB , size_t jB ,
                      int ** C , size_t iC , size_t jC ,
                      size_t n ) {
    /*
        Matrix subtraction for square submatrices of order n, with indices
            i*, i*+1, ... i*+(n-1)
        and similarly for j*
    */
    
    // Could be made recursive.
    
    unsigned long long ops = 0; // number of operations
    size_t i,j; // indices
    for (i=0;i<n;i++) {
        for (j=0;j<n;j++) {
            C[iC+i][jC+j] += A[iA+i][jA+j]-B[iB+i][jB+j];
            ops+=2;
        }
    }
    
    return ops;
}

// print matrix nicely
void print_matrix (int ** A , size_t m , size_t n ) {
    //prints a matrix A in a nice, python-compatible format
    size_t i,j; // indices
    printf("[\n");
    for (i=0;i<m-1;i++) {
        printf("  [");
        for (j=0;j<n-1;j++) {
            printf(" %6d ," , A[i][j]);
        }
        printf(" %6d],\n" , A[i][j]);
    }
    
    // last row
    printf("  [");
    for (j=0;j<n-1;j++) {
        printf(" %6d ," , A[i][j]);
    }
    printf(" %6d]\n" , A[i][j]);
    
    printf("]");
    
}

unsigned long long strassen ( int ** A , size_t iA , size_t jA ,
               int ** B , size_t iB , size_t jB ,
               int ** C , size_t iC , size_t jC ,
               size_t n ) {
    
    /*
        Strassen algorithm on submatrices of order n, with indexes
        starting at i* and j*
    */
    
    ///////////////////////////
    // Base case
    if (n==1) {
        C[iC][jC] += A[iA][jA]*B[iB][jB];
        return 2;
    }
    
    ///////////////////////////    
    // Divide
    size_t m = n/2; // half of order
    
    ///////////////////////////    
    // Conquer
    
    size_t i,j; // indices
    
    unsigned long long ops = 0; // number of operations
    
    // Initialize auxiliary matrices
    int *** S = malloc( 10 * sizeof(int*) );
    for (i=0;i<10;i++) {
        S[i] = malloc( m * sizeof(int*) );
        for (j=0;j<m;j++) {
            S[i][j] = calloc (m, sizeof(int) ); // initialize row to zero
        }
    }
    
    int *** P = malloc( 7 * sizeof(int*) );
    for (i=0;i<7;i++) {
        P[i] = malloc( m * sizeof(int*) );
        for (j=0;j<m;j++) {
            P[i][j] = calloc (m, sizeof(int) ); // initialize row to zero
        }
    }
    
    // Compute auxiliary matrices
    
    for (i=0;i<m;i++) {
        for (j=0;j<m;j++) {
            // S1 = B12 - B22
            S[0][i][j] = B[iB+i][jB+m+j] - B[iB+m+i][jB+m+j];
            // S2 = A11 + A12
            S[1][i][j] = A[iA+i][jA+j] + A[iA+i][jA+m+j];
            // S3 = A21 + A22
            S[2][i][j] = A[iA+m+i][jA+j] + A[iA+m+i][jA+m+j];
            // S4 = B21 - B11
            S[3][i][j] = B[iB+m+i][jB+j] - B[iB+i][jB+j];
            // S5 = A11 + A22
            S[4][i][j] = A[iA+i][jA+j] + A[iA+m+i][jA+m+j];
            // S6 = B11 + B22
            S[5][i][j] = B[iB+i][jB+j] + B[iB+m+i][jB+m+j];
            ops+=10;
            // S7 = A12 - A22
            S[6][i][j] = A[iA+i][jA+m+j]-A[iA+m+i][jA+m+j];
            // S8 = B21 + B22
            S[7][i][j] = B[iB+m+i][jB+j] + B[iB+m+i][jB+m+j];
            // S9 = A11 - A21
            S[8][i][j] = A[iA+i][jA+j] - A[iA+m+i][jA+j];
            // S10 = B11 + B12
            S[9][i][j] = B[iB+i][jB+j] + B[iB+i][jB+m+j];
        }
    }
    
    //P1 = A11 * S1
    ops += strassen ( A    , iA     , jA     ,
                      S[0] , 0      , 0      ,
                      P[0] , 0      , 0      ,
                      m );
    //P2 = S2*B22
    ops += strassen ( S[1] , 0      , 0      ,
                      B    , iB + m , jB + m ,
                      P[1] , 0      , 0      ,
                      m );
    //P3 = S3*B11
    ops += strassen ( S[2] , 0      , 0      ,
                      B    , iB     , jB     ,
                      P[2] , 0      , 0      ,
                      m );
    //P4 = A22*S4
    ops += strassen ( A    , iA + m , jA + m ,
                      S[3] , 0      , 0      ,
                      P[3] , 0      , 0      ,
                      m );
    //P5 = S5*S6
    ops += strassen ( S[4] , 0      , 0      ,
                      S[5] , 0      , 0      ,
                      P[4] , 0      , 0      ,
                      m );
    //P6 = S7*S8
    ops += strassen ( S[6] , 0      , 0      ,
                      S[7] , 0      , 0      ,
                      P[5] , 0      , 0      ,
                      m );
    //P7 = S9*S10
    ops += strassen ( S[8] , 0      , 0      ,
                      S[9] , 0      , 0      ,
                      P[6] , 0      , 0      ,
                      m );
    
    // Finish by updating product entries
    for (i=0;i<m;i++) {
        for (j=0;j<m;j++) {
            // C11 += P5 + P4 - P2 + P6
            C[iC+i][jC+j] += P[4][i][j] + P[3][i][j] - P[1][i][j] + P[5][i][j];
            // C12 += P1 + P2
            C[iC+i][jC+m+j] += P[0][i][j] + P[1][i][j];
            // C21 += P3 + P4
            C[iC+m+i][jC+j] += P[2][i][j] + P[3][i][j];
            // C22 += P5 + P1 - P3 - P7
            C[iC+m+i][jC+m+j] += P[4][i][j] + P[0][i][j] - P[2][i][j] - P[6][i][j];
            ops+=12;
        }
    }
    
    // Free auxiliary matrices
    for (i=0;i<10;i++) {
        for (j=0;j<m;j++) {
            free(S[i][j]);
        }
        free(S[i]);
    }

    for (i=0;i<7;i++) {
        for (j=0;j<m;j++) {
            free(P[i][j]);
        }
        free(P[i]);
    }
    
    free(S);
    free(P);
    
    return ops;
}

int main() {
    srand(time(NULL)); // random seed
    
    // Order of matrices; 8 is large-ish and readable
    size_t n = 8;
    
    size_t i,j; // indices
    
    // Create random matrices with entries between -99 and 99
    int ** A , ** B , ** C , ** D;
    
    A = malloc(n*sizeof(int*));
    B = malloc(n*sizeof(int*));
    C = malloc(n*sizeof(int*));
    D = malloc(n*sizeof(int*));
    
    for (i=0;i<n;i++) {
        A[i] = malloc(n*sizeof(int));
        B[i] = malloc(n*sizeof(int));
        C[i] = malloc(n*sizeof(int));
        D[i] = malloc(n*sizeof(int));
        
        for (j=0;j<n;j++) {
            // between -99 and 99
            A[i][j] = rand()%199 - 99;
            B[i][j] = rand()%199 - 99;
            C[i][j] = 0;
            D[i][j] = 0;
        }
    }
    
    /*
    A[0][0] = 1;
    A[0][1] = 3;
    A[1][0] = 7;
    A[1][1] = 5;
    B[0][0] = 6;
    B[0][1] = 8;
    B[1][0] = 4;
    B[1][1] = 2;
    */
    
    // Start calculating products and number of operations
    unsigned long long number_of_operations;
    
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");
    
    printf("Random matrices:\n");
    printf("A =\n");
    print_matrix(A,n,n);
    
    printf("\n");
    
    printf("B =\n");
    print_matrix(B,n,n);
    
    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");

    printf("Matrix product calculated through standard matrix multiplication:\n");
    
    number_of_operations = matrix_multiply(A,B,C,n);
    
    printf("A*B =\n");
    print_matrix(C,n,n);
    
    printf("\n");
    
    printf("Number of operations: %d" , number_of_operations);
    
    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");
    printf("Matrix product calculated through Strassen's algorithm:\n");
    
    number_of_operations = strassen ( A , 0 , 0 ,
                                      B , 0 , 0 ,
                                      D , 0 , 0 ,
                                      n );
    
    printf("A*B =\n");
    print_matrix(D,n,n);
    
    printf("\n");
    
    printf("Number of operations: %d" , number_of_operations);
    
    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");
    
    for (i=0;i<n;i++) {
        for (j=0;j<n;j++) {
            if (C[i][j]!=D[i][j]) {
                printf("Entries (i,j)=(%zu,%zu) were calculated differently!\n",i,j);
                i=n+1;
                j=n+1;
            }
        }
    }
    if (i==n && j==n) {
        printf("The products were calculated the same.");
    }
    
    for (i=0;i<n;i++) {
        free(A[i]);
        free(B[i]);
        free(C[i]);
        free(D[i]);
    }
    
    free(A);
    free(B);
    free(C);
    free(D);
    
    
    // Let us print the number of operations for small values of n
    
    n=1;
    
    unsigned long long operations_standard = 2, operations_strassen = 2;
    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");
    
    printf("\nThe following table shows the number of operations (additions and scalar multiplications)\n"
           "performed to calculate C+=A*B with both standard multiplication and Strassen's algorithm.\n\n");
    printf("| %15s | %15s | %15s |\n"
           "|-----------------|-----------------|-----------------|\n",
          "n",
          "standard",
          "Strassen");
    do {
        printf("| %15d | %15llu | %15llu |\n",
               n , operations_standard , operations_strassen);
        
        n*=2;
        operations_standard = 2*n*n*n;
        operations_strassen *= 7;
        operations_strassen += (22*n*n)/4;
            /*
                T(n) requires
                    7*T(n/2) (computing P_i);
                    10*(n/2)^2 (computing S_i);
                    12*(n/2)^2 (updatin C_ij.
            */
    } while ( (n<=16384) && (operations_standard<=operations_strassen) );
    return 0;
}
