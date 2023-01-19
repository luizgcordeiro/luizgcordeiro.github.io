/*
    Headers only needed for tests
*/
#include <stdio.h>
#include <time.h>

void insertion_sort(int *A, size_t n) {
  // Insertion sort on an integer array of length n

  int i,j; // Indices
  int key;
  for (j = 1; j < n; j++) {
    key = A[j];
    i = j - 1;
    while (i >= 0 && A[i] > key) {
      A[i + 1] = A[i];
      i--;
    }

    A[i + 1] = key;
  }
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
    
    insertion_sort( A , n );
    printf("Ordered array:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n",A[i]);

    free(A);
    
    return 0;
}

/*
    Headers only needed for tests
*/
#include <stdio.h>
#include <time.h>

void insertion_sort_reversed(int *A, size_t n) {
  int i,j; // Indices
  int key;
  for (j = 1; j < n; j++) {
    key = A[j];
    i = j - 1;
    while (i >= 0 && A[i] < key) {
      A[i + 1] = A[i];
      i--;
    }

    A[i + 1] = key;
  }
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
    
    insertion_sort_reversed( A , n );
    printf("Monotonically decreasing array:\n  ");
    for (i=0;i<n-1;i++) {
        printf("%d, ",A[i]);
    }
    printf("%d.\n",A[i]);

    free(A);
    
    return 0;
}


/*
    Headers only needed for tests
*/
#include <stdio.h>
#include <time.h>

int linear_search(int *A , int n , int x) {
  /*
    Using size_t for indexes and sizes is preferable, but since we want
    -1 as a possible return, we use int instead.
    
    An alternative would be to return the pointer to the entry instead
    of the entry number, which allows for NULL.
  */
    
  int j; // Index
  for (j = 0; j < n; j++) {
    if (x==A[j]) {
      return j;
    }
  }
  return -1;
}

// Test code below

int main() {
    srand(time(NULL));

    int i,index; // Index
    int n=10; // Test size
    int x = rand()%10; // key

    
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
    
    printf("Key: %d\n\n",x);

    index = linear_search(A,n,x);

    if (index==-1) {
      printf("The key was not found.\n");
      return 0;
    }

    printf("The key was found at index %d.\n" , index);
    free(A);
    
    return 0;
}

#include <stdio.h>
#include <time.h>

void add_binary_integers(int *A, int *B, int *C, int n) {
  int carry = 0;
  for (int i = 0; i < n; i++) {
    if (A[i] == B[i]) { // result will be 00 or 01 (little-endian); either way
                        // C[i]=carry
      C[i] = carry;
      if (A[i] == 1) { // result was 01
        carry = 1;
      } else {
        carry = 0;
      }
    } else {            // A[i] and B[i]  are different: one is 0; other is 1
      if (carry == 1) { // A[i]+B[i]+along=01
        C[i] = 0;
      } else { // A[i]+B[i]+along=10
        C[i] = 1;
      }
      // along=0, no need to update
    }
  }

  C[n] = carry;
  return;
}

int main() {
  srand(time(NULL));
  int n = 10;

  // Initialize two n-sized 0-1 strings and their sum.
  int A[n], B[n], C[n + 1];
  for (int i = 0; i < n; i++) {
    A[i] = rand() % 2;
    B[i] = rand() % 2;
  }

  add_binary_integers(A,B,C,n);
  
  // Print the sum
  printf("Testing the sum. Note that numbers are written little endian, with carry to the right.\n");
  printf(" ");
  for (int i = 0; i < n; i++) {
    printf("%d", A[i]);
  }
  printf("\n+");
  for (int i = 0; i < n; i++) {
    printf("%d", B[i]);
  }
  printf("\n ");
  for (int i = 0; i < n + 1; i++) {
    printf("_");
  }
  printf("\n ");

  for (int i = 0; i < n + 1; i++) {
    printf("%d", C[i]);
  }
  printf("\n");

  return 0;
}
