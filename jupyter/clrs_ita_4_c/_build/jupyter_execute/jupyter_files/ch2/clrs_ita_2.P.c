#include <stdio.h>
#include <time.h>

void bubble_sort(int *A, size_t n) {
    // Bubblesort

    int i, j, x;
    for (i = 0; i < n - 1; i++) {
        for (j = n - 1; j > i; j--) {
            if (A[j] < A[j - 1]) {
                x = A[j];
                A[j] = A[j - 1];
                A[j - 1] = x;
            }
        }
    }
}

// Test code below

int main() {
    srand(time(NULL));

    int i; // Index
    int n=10; // Test size

    
    // Dinamically allocate random integer array
    int * A = malloc(n*sizeof(int));
    for (i=0;i<n;i++) {
        A[i] = rand()%11 - 5;
    }
    
    printf("Array created:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n\n",A[i]);
    
    bubble_sort(A,n);

    printf("Ordered array:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n\n",A[i]);
    
    free(A);
    
    return 0;
}

#include <stdio.h>
#include <time.h>

int Horner(int n, int *a, int x) {
  /*
    Implements Horner's rule to evaluate
    a[0]+a[1]*x_+a[2]*x^2+...+a[n]x^n
    Note that array a has length n+1!
  */
  int y = 0;
  int i;
  for (i = n; i >= 0; i--) {
    y = a[i] + x * y;
  }
  return y;
}

int main() {
    srand(time(NULL));
    int i;
    
    int n=rand()%3+2;     // random number between 2 and 4
    
    int * a = malloc((n+1)*sizeof(int));  // random coefficients
    int x = rand()%7-3;  // random between -3 and 3
    for (i=0;i<=n;i++) {
        a[i] = rand()%7-3; // random between -3 and 3
        printf("+(%d)*(%d)^%d",a[i],x,i);
    }
    printf(" = %d\n",Horner(n,a,x));
    
    free(a);
    
    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

void print_int_array(int *v, int n); //Prints an n-sized integer array v
int * random_int_array(size_t n); // Randomly creates an n-sized integer array

int merge_inversions(int *A, int p, int q, int r) {
  // Merges A[p:q] and A[q+1:r], where p<=q<r, and returns the number of inversions

  int i,j,k; // Loop indices
  int inversions=0;  // number of inversions
  int n1 = q - p + 1; // Length of A[p:q]
  int n2 = r - q;     // Length of A[q+1:r]
  
  int * L = malloc(n1*sizeof(int));
  int * R = malloc(n2*sizeof(int));

  // Copy A[p:q] and A[q+1:r] to L and R
  memcpy(L,A+p,n1*sizeof(int));
  memcpy(R,A+q+1,n2*sizeof(int));

  i = 0; // Index of L
  j = 0; // Index of R
  k = p; // Index of A[p:q]
  while (i < n1 && j < n2) {
    if (L[i] <= R[j]) {
      A[k++] = L[i++];
    } else {
      A[k++] = R[j++];
      inversions+=(n1-i); // (last index)-i+1 = (n1-1)-i+1
    }
  }

  // Copy the remainders of L or R to A
  while (i < n1) {
    A[k++] = L[i++];
  }

  while (j < n2) {
    A[k++] = R[j++];
  }

  free(L);
  free(R);

  return inversions;
}

int merge_sort_inversions(int *A, int p, int r) {
  // Merge-sort and inversion counting on A[p:r]
  int inversions = 0;
  
  if (p == r) {
    return 0;
  }

  // Break A[p:q] in two
  int q = (p + r) / 2;
  inversions += merge_sort_inversions(A, p, q);
  inversions += merge_sort_inversions(A, q + 1, r);
  inversions += merge_inversions(A, p, q, r);
    
  return inversions;
}

// Test

int main() {
    int n=10; // Test size

    int * A = random_int_array(n);
    
    printf("Array created:\n  ");
    print_int_array(A,n);
    printf("\n\n");
    
    // Count inversions by brute force
    printf("Brute-force listing of all inversions:\n");
    int i,j;
    int inversions=0;
    for (i=0;i<n;i++) {
        for (j=i+1;j<n;j++) {
            if (A[i]>A[j]) {
                printf("  Inversion %d: indexes (%d,%d); values %d > %d\n",(++inversions),i,j,A[i],A[j]);
            }
        }
    }
    printf("\n");
    inversions=merge_sort_inversions( A , 0 , n-1 );
    
    printf("Number of inversions counted by modified MERGE-SORT: %d\n\n",inversions);
    printf("Ordered array:\n\n  ");
    print_int_array(A,n);
    printf("\n");

    free(A);
    
    return 0;
}

///////////////////////////////

void print_int_array(int *v, int n) {
  // Prints an n-sized integer array v

  int i;
  for (i=0;i<n-1;i++) {
        printf("%d , ",v[i]);
  }
  printf("%d",v[i]);
  return;
}

int * random_int_array(size_t n) {
  // Randomly creates an n-sized integer array v

  srand(time(NULL));

  int * A = malloc(n*sizeof(int));
  for (int i = 0; i < n; i++) {
    A[i] = rand() % 100;
  }

  return A;
}
