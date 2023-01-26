#include <stdio.h>
#include <time.h>

int matrix_multiply ( int ** A , int ** B , int ** C , size_t n ) {
    // Standard matrix multiplication
    
    int ops = 0; // number of operations
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

// Function that alocates a copy of a submatrix dynamically

int ** submatrix ( int ** A , size_t i1 , size_t i2 , size_t j1 , size_t j2 ) {
    // Creates a submatrix A[i1:i2,j1:j2] (inclusive)
    size_t i,j; // indices
    size_t m = i2-i1+1;
    size_t n = j2-j1+1;
    
    int ** A_ = malloc(m * sizeof(int *));
    
    for (i=0;i<m;i++) {
        A_[i] = malloc(n*sizeof(int));
        for (j=0;j<n;j++) {
            A_[i][j]=A[i+i1][j+j1];
        }
    }
            
    return A_;
}

// Free dinamically allocated matrix for convenience

void free_allocated_matrix(int ** A , size_t m) {
    // Frees a dinamically allocated matrix A with m rows.
    size_t i;
    
    for (i=0;i<m;i++) {
        free(A[i]);
    }
    
    free(A);
}

int matrix_multiply_recursive_copy ( int ** A , int ** B , int ** C , size_t n ) {
    
    //Works only for powers of 2
    
    
    if (n==1) {
        C[0][0] += A[0][0]*B[0][0];
        return 2;
    }
    
    size_t i,j; // Indices
    
    int ops = 0; // number of operations
    
    //Create submatrices
    size_t m = n/2;
    
    int ** A11 = submatrix(A,0,m-1,0,m-1);
    int ** A12 = submatrix(A,0,m-1,m,n-1);
    int ** A21 = submatrix(A,m,n-1,0,m-1);
    int ** A22 = submatrix(A,m,n-1,m,n-1);
    int ** B11 = submatrix(B,0,m-1,0,m-1);
    int ** B12 = submatrix(B,0,m-1,m,n-1);
    int ** B21 = submatrix(B,m,n-1,0,m-1);
    int ** B22 = submatrix(B,m,n-1,m,n-1);
    int ** C11 = submatrix(C,0,m-1,0,m-1);
    int ** C12 = submatrix(C,0,m-1,m,n-1);
    int ** C21 = submatrix(C,m,n-1,0,m-1);
    int ** C22 = submatrix(C,m,n-1,m,n-1);
    
    ops += matrix_multiply_recursive_copy(A11,B11,C11,m);
    ops += matrix_multiply_recursive_copy(A12,B21,C11,m);
    ops += matrix_multiply_recursive_copy(A11,B12,C12,m);
    ops += matrix_multiply_recursive_copy(A12,B22,C12,m);
    ops += matrix_multiply_recursive_copy(A21,B11,C21,m);
    ops += matrix_multiply_recursive_copy(A22,B21,C21,m);
    ops += matrix_multiply_recursive_copy(A21,B12,C22,m);
    ops += matrix_multiply_recursive_copy(A22,B22,C22,m);
    
    // Copy the results back to the original matrices
    
    for (i=0;i<m;i++) {
        for (j=0;j<m;j++) {
            A[i][j] = A11[i][j];
            B[i][j] = B11[i][j];
            C[i][j] = C11[i][j];
        }
        for (;j<n;j++) {
            A[i][j] = A12[i][j-m];
            B[i][j] = B12[i][j-m];
            C[i][j] = C12[i][j-m];
        }
    }
    for (;i<n;i++) {
        for (j=0;j<m;j++) {
            A[i][j] = A21[i-m][j];
            B[i][j] = B21[i-m][j];
            C[i][j] = C21[i-m][j];
        }
        for (;j<n;j++) {
            A[i][j] = A22[i-m][j-m];
            B[i][j] = B22[i-m][j-m];
            C[i][j] = C22[i-m][j-m];
        }
    }    
    
    free_allocated_matrix(A11,m);
    free_allocated_matrix(A12,m);
    free_allocated_matrix(A21,n-m);
    free_allocated_matrix(A22,n-m);
    free_allocated_matrix(B11,m);
    free_allocated_matrix(B12,m);
    free_allocated_matrix(B21,n-m);
    free_allocated_matrix(B22,n-m);
    free_allocated_matrix(C11,m);
    free_allocated_matrix(C12,m);
    free_allocated_matrix(C21,n-m);
    free_allocated_matrix(C22,n-m);
    
    return ops;
}

int matrix_multiply_recursive_index ( int ** A , size_t iA1 , size_t iA2 , size_t jA1 , size_t jA2 ,
                                      int ** B , size_t iB1 , size_t iB2 , size_t jB1 , size_t jB2 ,
                                      int ** C , size_t iC1 , size_t iC2 , size_t jC1 , size_t jC2 ) {
    
    // Works only for powers of 2
    // Assumes submatrices are of same order
    /*
        Takes submatrices of A and B and adds their product to a submatrix of C
        Indexes i*1 ad i*2 determine that the submatrix has rows of index i
        satisfying
            i1 <= i < i2
        and similarly for j*1 and j*2 
        
        To take all of A (square of order n by n), simply use iA1 = jA1 = 0 and iA2 = jA2 = n
    */
    
    size_t n = iA2-iA1; // order of all matrices
    
    if (n==1) {
        C[iC1][jC1] += A[iA1][jA1]*B[iB1][jB1];
        return 2;
    }
    
    int ops = 0; // number of operations
    
    //Create submatrices
    size_t m = n/2; // half of order
    
    /*
        A11 = A[i1:i1+m][j1:j1+m]
        A12 = A[i1:i1+m][j1+m:j2]
        A11 = A[i1+m:i2][j1:j1+m]
        A12 = A[i1+m:i2][j1+m:j2]
        
        and similarly for B11, B12 etc.
    */
    
    //C11 += A11*B11
    ops += matrix_multiply_recursive_index( A , iA1 , iA1+m , jA1 , jA1+m ,
                                            B , iB1 , iB1+m , jB1 , jB1+m ,
                                            C , iC1 , iC1+m , jC1 , jC1+m );
    //C11 += A12*B21
    ops += matrix_multiply_recursive_index( A , iA1 , iA1+m , jA1+m , jA2 ,
                                            B , iB1+m , iB2 , jB1 , jB1+m ,
                                            C , iC1 , iC1+m , jC1 , jC1+m);
    //C12 += A11*B12
    ops += matrix_multiply_recursive_index( A , iA1 , iA1+m , jA1 , jA1+m ,
                                            B , iB1 , iB1+m , jB1+m , jB2 ,
                                            C , iC1 , iC1+m , jC1+m , jC2 );
    //C12 += A12*B22
    ops += matrix_multiply_recursive_index( A , iA1 , iA1+m , jA1+m , jA2 ,
                                            B , iB1+m , jB2 , jB1+m , jB2 ,
                                            C , iC1 , iC1+m , jC1+m , jC2 );
    //C21 += A21*B11
    ops += matrix_multiply_recursive_index( A , iA1+m , iA2 , jA1 , jA1+m ,
                                            B , iB1 , iB1+m , jB1 , jB1+m ,
                                            C , iC1+m , iC2 , jC1 , jC1+m );
    //C21 += A22*B21
    ops += matrix_multiply_recursive_index( A , iA1+m , iA2 , jA1+m , jA2 ,
                                            B , iB1+m , iB2 , jB1 , jB1+m ,
                                            C , iC1+m , iC2 , jC1 , jC1+m );
    //C22 += A21*B12
    ops += matrix_multiply_recursive_index( A , iA1+m , iA2 , jA1 , jA1+m ,
                                            B , iB1 , iB1+m , jB1+m , jB2 ,
                                            C , iC1+m , iC2 , jC1+m , jC2 );
    //C22 += A22*B22
    ops += matrix_multiply_recursive_index( A , iA1+m , iA2 , jA1+m , jA2 ,
                                            B , iB1+m , iB2 , jB1+m , jB2 ,
                                            C , iC1+m , iC2 , jC1+m , jC2 );
    
    
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

int main() {
    srand(time(NULL)); // random seed
    
    // Order of matrices; 8 is large-ish and readable
    size_t n = 8;
    
    size_t i,j; // indices
    
    // Create random matrices with entries between -99 and 99
    int ** A , ** B , ** C , ** D , **E;
    
    A = malloc(n*sizeof(int*));
    B = malloc(n*sizeof(int*));
    C = malloc(n*sizeof(int*));
    D = malloc(n*sizeof(int*));
    E = malloc(n*sizeof(int*));
    
    for (i=0;i<n;i++) {
        A[i] = malloc(n*sizeof(int));
        B[i] = malloc(n*sizeof(int));
        C[i] = malloc(n*sizeof(int));
        D[i] = malloc(n*sizeof(int));
        E[i] = malloc(n*sizeof(int));
        
        for (j=0;j<n;j++) {
            // between -99 and 99
            A[i][j] = rand()%199 - 99;
            B[i][j] = rand()%199 - 99;
            C[i][j] = 0;
            D[i][j] = 0;
            E[i][j] = 0;
        }
    }
    
    // Start calculating products and number of operations
    int number_of_operations;
    
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
    printf("Matrix product calculated through recursive matrix multiplication with copying submatrices:\n");
    
    number_of_operations = matrix_multiply_recursive_copy(A,B,D,n);
    
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
    printf("Matrix product calculated through recursive matrix multiplication with index calculations:\n");
    
    number_of_operations = matrix_multiply_recursive_index( A , 0 , n , 0 , n ,
                                                            B , 0 , n , 0 , n ,
                                                            E , 0 , n , 0 , n );
    
    printf("A*B =\n");
    print_matrix(E,n,n);
    
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
            if (C[i][j]!=D[i][j] || C[i][j]!=E[i][j]) {
                printf("Entries (i,j)=(%zu,%zu) were calculated differently!\n",i,j);
                i=n+1;
                j=n+1;
            }
        }
    }
    if (i==n && j==n) {
        printf("The products were calculated the same.");
    }
    printf("\n");
    for (i=0;i<n;i++) {
        free(A[i]);
        free(B[i]);
        free(C[i]);
        free(D[i]);
        free(E[i]);
    }
    
    
    
    free(A);
    free(B);
    free(C);
    free(D);
    free(E);
    
    return 0;
}

#include <stdio.h>
#include <time.h>

int matrix_multiply ( int ** A , int ** B , int ** C , size_t m , size_t n , size_t p ) {
    /*
        Standard matrix multiplication
        A of order m x n , B of order n x p , C += A*B of order m x p
    */
    
    int ops = 0; // number of operations
    size_t i,j,k; // indices
    for (i=0;i<m;i++) {
        for (j=0;j<p;j++) {
            for (k=0;k<n;k++) {
                C[i][j] += A[i][k]*B[k][j];
                ops+=2;
            }
        }
    }
    return ops;
}

int matrix_multiply_recursive ( int ** A , size_t iA1 , size_t iA2 , size_t jA1 , size_t jA2 ,
                                int ** B , size_t iB1 , size_t iB2 , size_t jB1 , size_t jB2 ,
                                int ** C , size_t iC1 , size_t iC2 , size_t jC1 , size_t jC2 ) {
    
    // Works only for powers of 2
    // Assumes submatrices are of same order
    /*
        Takes submatrices of A and B and adds their product to a submatrix of C
        Indexes i*1 ad i*2 determine that the submatrix has rows of index i
        satisfying
            i1 <= i < i2
        and similarly for j*1 and j*2 
        
        To take all of A (square of order n by n), simply use iA1 = jA1 = 0 and iA2 = jA2 = n
    */
    
    // Matrix orders
    size_t m = iA2-iA1;
    size_t n = iB2-iB1;
    size_t p = jB2-jB1;
    
    if ( m==0 || n==0 || p==0 ) {
        return 0;
    }
    
    if ( m==1 && n==1 && p==1 ) {
        C[iC1][jC1] += A[iA1][jA1]*B[iB1][jB1];
        return 2;
    }
    
    int ops = 0; // number of operations
    
    //Create submatrices
    size_t m_ = m/2; // half of order
    size_t n_ = n/2; // half of order
    size_t p_ = p/2; // half of order
    
    /*
        A11 = A[i1:i1+m][j1:j1+m]
        A12 = A[i1:i1+m][j1+m:j2]
        A11 = A[i1+m:i2][j1:j1+m]
        A12 = A[i1+m:i2][j1+m:j2]
        
        and similarly for B11, B12 etc.
    */
    
    //C11 += A11*B11
    ops += matrix_multiply_recursive( A , iA1 , iA1+m_ , jA1 , jA1+n_ ,
                                            B , iB1 , iB1+n_ , jB1 , jB1+p_ ,
                                            C , iC1 , iC1+m_ , jC1 , jC1+p_ );
    //C11 += A12*B21
    ops += matrix_multiply_recursive( A , iA1 , iA1+m_ , jA1+n_ , jA2 ,
                                            B , iB1+n_ , iB2 , jB1 , jB1+p_ ,
                                            C , iC1 , iC1+m_ , jC1 , jC1+p_);
    //C12 += A11*B12
    ops += matrix_multiply_recursive( A , iA1 , iA1+m_ , jA1 , jA1+n_ ,
                                            B , iB1 , iB1+n_ , jB1+p_ , jB2 ,
                                            C , iC1 , iC1+m_ , jC1+p_ , jC2 );
    //C12 += A12*B22
    ops += matrix_multiply_recursive( A , iA1 , iA1+m_ , jA1+n_ , jA2 ,
                                            B , iB1+n_ , iB2 , jB1+p_ , jB2 ,
                                            C , iC1 , iC1+m_ , jC1+p_ , jC2 );
    //C21 += A21*B11
    ops += matrix_multiply_recursive( A , iA1+m_ , iA2 , jA1 , jA1+n_ ,
                                            B , iB1 , iB1+n_ , jB1 , jB1+p_ ,
                                            C , iC1+m_ , iC2 , jC1 , jC1+p_ );
    //C21 += A22*B21
    ops += matrix_multiply_recursive( A , iA1+m_ , iA2 , jA1+n_ , jA2 ,
                                            B , iB1+n_ , iB2 , jB1 , jB1+p_ ,
                                            C , iC1+m_ , iC2 , jC1 , jC1+p_ );
    //C22 += A21*B12
    ops += matrix_multiply_recursive( A , iA1+m_ , iA2 , jA1 , jA1+n_ ,
                                            B , iB1 , iB1+n_ , jB1+p_ , jB2 ,
                                            C , iC1+m_ , iC2 , jC1+p_ , jC2 );
    //C22 += A22*B22
    ops += matrix_multiply_recursive( A , iA1+m_ , iA2 , jA1+n_ , jA2 ,
                                            B , iB1+n_ , iB2 , jB1+p_ , jB2 ,
                                            C , iC1+m_ , iC2 , jC1+p_ , jC2 );
    
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

/////////////////

int main() {
    srand(time(NULL)); // random seed
    
    // Order of matrices;
    
    size_t m = 4 + rand()%15;
    size_t n = 4 + rand()%15;
    size_t p = 4 + rand()%15;

    size_t i,j; // indices

    // Create random matrices with entries between -99 and 99
    int ** A , ** B , ** C , **E;

    A = malloc(m*sizeof(int*));
    B = malloc(n*sizeof(int*));
    C = malloc(m*sizeof(int*));
    E = malloc(m*sizeof(int*));

    for (i=0;i<m;i++) {
        A[i] = malloc(n*sizeof(int));
        for (j=0;j<n;j++) {
            A[i][j] = rand()%199 - 99;
        }
    }

    for (i=0;i<n;i++) {
        B[i] = malloc(p*sizeof(int));
        for (j=0;j<p;j++) {
            B[i][j] = rand()%199 - 99;
        }
    }

    for (i=0;i<m;i++) {
        C[i] = malloc(p*sizeof(int));
        E[i] = malloc(p*sizeof(int));
        for (j=0;j<p;j++) {
            C[i][j] = 0;
            E[i][j] = 0;
        }
    }

    // Start calculating products and number of operations
    int number_of_operations;

    for (i=0;i<30;i++) {
        printf("=");
    }

    printf("\n");

    printf("Random matrices:\n");
    printf("A =\n");
    print_matrix(A,m,n);

    printf("\n");

    printf("B =\n");
    print_matrix(B,n,p);

    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");

    printf("Matrix product calculated through standard matrix multiplication:\n");

    number_of_operations = matrix_multiply(A,B,C,m,n,p);

    printf("A*B =\n");
    print_matrix(C,m,p);

    printf("\n");

    printf("Number of operations: %d" , number_of_operations);

    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");
    printf("Matrix product calculated through recursive matrix multiplication with index calculations:\n");

    number_of_operations = matrix_multiply_recursive( A , 0 , m , 0 , n ,
                                                      B , 0 , n , 0 , p ,
                                                      E , 0 , m , 0 , p );

    printf("A*B =\n");
    print_matrix(E,m,p);

    printf("\n");

    printf("Number of operations: %d" , number_of_operations);

    // ==============================
    printf("\n");
    for (i=0;i<30;i++) {
        printf("=");
    }
    printf("\n");

    for (i=0;i<m;i++) {
        for (j=0;j<p;j++) {
            if (C[i][j]!=E[i][j]) {
                printf("Entries (i,j)=(%zu,%zu) were calculated differently!\n",i,j);
                i=n+1;
                j=p+1;
            }
        }
    }
    if (i==m && j==p) {
        printf("The products were calculated the same.");
    }
    printf("\n");

    for (i=0;i<m;i++) {
        free(A[i]);
        free(C[i]);
        free(E[i]);
    }

    for (i=0;i<n;i++) {
        free(B[i]);
    }

    free(A);
    free(B);
    free(C);
    free(E);

    return 0;
}
