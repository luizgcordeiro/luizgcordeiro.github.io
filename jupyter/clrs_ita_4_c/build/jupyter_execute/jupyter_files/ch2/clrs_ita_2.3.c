#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

void print_int_array(int *v, int n); //Prints an n-sized integer array v
int * random_int_array(size_t n); // Randomly creates an n-sized integer array

void merge(int *A, int p, int q, int r) {
  // Merges A[p:q] and A[q+1:r], where p<=q<r

  int i,j,k; // Loop indices
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

  return;
}

void merge_sort(int *A, int p, int r) {
  // Merge-sort on A[p:r]
  if (p == r) {
    return;
  }

  // Break A[p:q] in two
  int q = (p + r) / 2;
  merge_sort(A, p, q);
  merge_sort(A, q + 1, r);
  merge(A, p, q, r);
}

// Test

int main() {
    int n=10; // Test size

    int * A = random_int_array(n);
    
    printf("Array created:\n  ");
    print_int_array(A,n);
    printf("\n\n");
    
    merge_sort( A , 0 , n-1 );
    printf("Ordered array:\n  ");
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

#include <stdio.h>
#include <time.h>

void insertion_sort_recursive(int *A, size_t n) {
    if (n<=1) return;

    insertion_sort_recursive(A,n-1);

    int key = A[n];
    int i = n-1;     // Index
    while (i >= 0 && A[i] > key) {
      A[i + 1] = A[i];
      i--;
    }

    A[i + 1] = key;
}

// Test code below

int main() {
    int i; // Index
    int n=10; // Test size

    srand(time(NULL));
    
    // Dinamically allocate random integer array
    int * A = malloc(n*sizeof(int));
    for (i=0;i<n;i++) {
        A[i] = rand()%21 - 10;
    }
    
    printf("Array created:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n\n",A[i]);
    
    insertion_sort_recursive( A , n );
    printf("Ordered array:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n",A[i]);

    free(A);
    
    return 0;
}
