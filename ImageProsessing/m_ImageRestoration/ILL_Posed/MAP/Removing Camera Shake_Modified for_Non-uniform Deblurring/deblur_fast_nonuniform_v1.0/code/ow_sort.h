#ifndef OW_SORT_H
#define OW_SORT_H

/* Sorting functions */
inline void iswap(mwIndex *x, mwIndex *y) {
	mwIndex temp;
	temp = *x;
	*x = *y;
	*y = temp;
}
inline void dswap(double *x, double *y) {
	double temp;
	temp = *x;
	*x = *y;
	*y = temp;
}

inline int choose_pivot(int i, int j ) { return((i+j)/2); }

/* Sort a list of ints, and also apply that sorting to a list of doubles */
void quicksort(mwIndex *list, int m, int n, double *vallist) {
	mwIndex key;
	int i,j,k;
	if(m < n) {
		k = choose_pivot(m,n);
		iswap(&list[m],&list[k]);
		dswap(&vallist[m],&vallist[k]);
		key = list[m];
		i = m+1;
		j = n;
		while(i <= j) {
			while((i <= n) && (list[i] <= key)) { i++; }
			while((j >= m) && (list[j] >  key)) { j--; }
			if(i < j) {
				iswap(&list[i],&list[j]);
				dswap(&vallist[i],&vallist[j]);
			}
		}
		/* 	swap two elements */
		iswap(&list[m],&list[j]);
		dswap(&vallist[m],&vallist[j]);
		/* 	recursively sort the lesser list */
		quicksort(list,m,j-1,vallist);
		quicksort(list,j+1,n,vallist);
	}
}

#endif
