#include <stdio.h>
#include <stdlib.h>


const int MAX_N = 100; // maksymalna iloœæ wierzcho³ków w grafie

main()
{
  int i,j,wmax,n,x,y;
  char A[MAX_N][MAX_N]; // macierz s¹siedztwa

  for(i = 0; i < MAX_N; i++)
    for(j = 0; j < MAX_N; j++) A[i][j] = 0;
  wmax = 0;
  cin >> n; // odczytujemy iloœæ krawêdzi
  for(i = 0; i < n; i++)
  {
    cin >> x >> y; // odczytujemy krawêdŸ
    wmax = (x > wmax) ? x : wmax;
    wmax = (y > wmax) ? y : wmax;
    A[x-1][y-1] = 1;
    A[y-1][x-1] = 1;
  }
  cout << endl;
  for(i = 0; i < wmax; i++)
  {
    for(j = 0; j < wmax; j++) cout << (int)A[i][j] << " ";
    cout << endl;
  }
  char s[1];
  cin.getline(s,1);
  cin.getline(s,1);
}
