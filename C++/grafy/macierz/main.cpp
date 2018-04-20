/* #include <iostream>
#include <fstream>
#include <string>

using namespace std;

const int VMAX=32;

typedef bool Matrix[VMAX+1][VMAX+1];

ifstream fp("graf.txt");

bool readMatrix(const string &macierz_sasiedztwa, Matrix &matrix)
{
string line;
   if (!fp)
   {
       printf("Nie moge otworzyc pliku ");
       return false;
   }
   for (int i=0;i<VMAX;i++)
   {
      if (!getline(fp,line) || line.length()<VMAX)
       {
         cout<<"B?a;d podczas odczytu pliku (plik za krótki?)"<<endl;
         return false;
       }
      for (int j=0;j<VMAX;j++)
        matrix[i][j] = line[j]-'0';
   }
    return true;
}

void printMatrix(const Matrix &matrix)
{
   for (int i=0; i<VMAX; i++)
   {
      for (int j=0; j<VMAX; j++)
         cout<<matrix[i][j]<<' ';
      cout<<endl;
   }
}

int main()
{
   Matrix MS;
   if (readMatrix("graf.txt",MS))
      printMatrix(MS);
}
*/
