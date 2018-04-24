#include <stdio.h>
#include <stdlib.h>

long OpenFile(FILE** File);
void GetSize(FILE* File,int* Width,int* Height);
int CreateMatrix(int*** Matrix,int Width,int Height);
void LoadMatrix(FILE* File,int*** Matrix,int Width,int Height);
void ShowMatrix(int** Matrix,int Width,int Height);


int main()
{
  FILE* File=NULL;
  long FileLength=0;
  int** Matrix=NULL;
  int Width=0;
  int Height=0;
  int w;
  int k;
  int macierz[10][10] = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}};
  if((FileLength=OpenFile(&File))==-1)
    return 0;

  GetSize(File,&Width,&Height);

  //w=Width;
  //k=Height-1;

  k=GetW(File, w);
  w=GetK(File, k);
  printf("ilosc wierzcholki to: %d\n", w);
  printf("ilosc krawedzi to: %d\n", k);

  printf("\n");

  if(CreateMatrix(&Matrix,Width,Height)==-1)
    return 0;

  printf("Dane z pliku: \n");
  LoadMatrix(File,&Matrix,Width,Height);
  ShowMatrix(Matrix,Width,Height);
  showAdGraph(Matrix,w,k);
  showInGraph(Matrix,w,k);
  showZbiorWierzcholkow(Matrix,w);
  showZbiorKrawedzi(Matrix,Height);
  return 0;
}



long OpenFile(FILE** File)      //Funkcja odpowiadaj¹ca za otwieranie pliku
{
  char FileName[30]={0};
  long FileLength=0;
  *File=NULL;

  printf("Podaj nazwe pliku do otwarcia: ");
  scanf("%29s",FileName);


  *File=fopen(FileName,"rt");
  if(!(*File))
  {
    printf("Nie mozna otworzyc pliku %s.",FileName);
    return -1;
  }

  fseek(*File,0,SEEK_END);
  FileLength=ftell(*File);
  fseek(*File,0,SEEK_SET);

  return FileLength;
}
int GetK(FILE* File, int k)
{
  int WidthRead=0;
  char Tmp=0;

  int w=-1;
  k=1;
  while(1)
  {
    if(feof(File))
      break;
    Tmp=fgetc(File);

    if(WidthRead==0)
    {
      if(Tmp=='\n')
      {
        WidthRead=1;
        ++(w);
      }
      else if(Tmp!=' ')
        ++(k);
    }
    else if(Tmp=='\n')
      ++(w);
  }

  fseek(File,0,SEEK_SET);
  return k;
}
int GetW(FILE* File, int w)
{
  int WidthRead=0;
  char Tmp=0;

  w=0;
  int k=0;
  while(1)
  {
    if(feof(File))
      break;
    Tmp=fgetc(File);

    if(WidthRead==0)
    {
      if(Tmp=='\n')
      {
        WidthRead=1;
        ++(w);
      }
      else if(Tmp!=' ')
        ++(k);
    }
    else if(Tmp=='\n')
      ++(w);
  }

  fseek(File,0,SEEK_SET);
  return w;
}
void GetSize(FILE* File,int* Width,int* Height)
{
  int WidthRead=0;
  char Tmp=0;

  *Width=-1;
  *Height=1;
  while(1)
  {
    if(feof(File))
      break;
    Tmp=fgetc(File);

    if(WidthRead==0)
    {
      if(Tmp=='\n')
      {
        WidthRead=1;
        ++(*Height);
      }
      else if(Tmp!=' ')
        ++(*Width);
    }
    else if(Tmp=='\n')
      ++(*Height);
  }

  fseek(File,0,SEEK_SET);
}
int CreateMatrix(int*** Matrix,int Width,int Height)
{
  int i=0;

  *Matrix=(int**) malloc(Width*sizeof(int*));
  if(!(*Matrix))
  {
    printf("Blad allokacji pamieci.");
    return -1;
  }

 for(i=0;i<Width;++i)
    (*Matrix)[i]=NULL;

  for(i=0;i<Width;++i)
    (*Matrix)[i]=(int*) malloc(Height*sizeof(int));

  for(i=0;i<Width;++i)
    if((*Matrix)[i]==NULL)
      return -1;


  return 0;
}
void LoadMatrix(FILE* File,int*** Matrix,int Width,int Height)
{
  int i=0;
  int j=0;
  char Tmp=0;

  if(!File || !(*Matrix) || Width<0 || Height<0)
    return;

  for(i=0;i<Height;++i)
    for(j=0;j<Width*2;++j)
    {
      Tmp=fgetc(File);
      if(j%2==0)
        (*Matrix)[j/2][i]=Tmp-'0';
    }

}
void ShowMatrix(int** Matrix,int Width,int Height)
{
  int i=0;
  int j=0;

  for(i=1;i<Height;++i)
  {
    for(j=0;j<Width;++j)
      printf("%d ",Matrix[j][i]);
    printf("\n");
  }
}
int showAdGraph(int** Matrix, int w, int k)
{
    int i,j,v1,v2;
    int G[20][20];
    int macierz[10][10] = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}};

    printf("Macierz sasiedztwa: ");
    for(i=0;i<w;i++)
    {
        for(j=0;j<w;j++)
            G[i][j]=0;
    }
    /*    creating edges :P    */



    for(i=0;i<k;i++)
    {
        j=0;
        v1=macierz[i][j];
        j=1;
        v2=macierz[i][j];
        G[v1-1][v2-1]=1;

    }
    printf("\n");
    for(i=0;i<w;i++)
    {
        for(j=0;j<w;j++)
            printf(" %d ",G[i][j]);
        printf("\n");
    }
    return 0;
}
int showUndirAdGraph(int** Matrix, int w, int k)
{

}
int showInGraph(int** Matrix, int w, int k)
{
    int i,j,v1,v2;
    int G[20][20];
    int macierz[10][10] = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}};

    printf("Macierz incydencji: ");
    for(i=0;i<w;i++)
    {
        for(j=0;j<k;j++)
            G[i][j]=0;
    }
    /*    creating edges :P    */



    for(i=0;i<k;i++)
    {
        j=0;
        v1=Matrix[j][i];
        j=1;
        v2=Matrix[j][i];
        G[v1-1][v2-1]=1;
        G[v2-1][v1-1]=1;


    }
    printf("\n");
    for(i=0;i<w;i++)
    {
        for(j=0;j<w;j++)
            printf(" %d ",G[j][i]);
            printf(" %d ",G[i][j]);
        printf("\n");
    }
    return 0;
}
int showZbiorWierzcholkow(int** Matrix, int w)
{
    int liczbaW=1;
    int z=0;
    int j=0;
    int i=0;

    printf("\nzbior wierzcholkow: ");
    for(i=0;i<w;i++)
    {
    printf("%d", liczbaW);
    liczbaW=liczbaW+1;
    }
}
int showZbiorKrawedzi(int** Matrix, int Height)
{
    int i=0;
    int j=0;
    int z=0;
    int k1=0;
    int k2=0;

    printf("\nZbior krawedzi: ");
    for(i=1;i<Height;i++)
    {
        k1=Matrix[0][i];
        k2=Matrix[1][i];
        printf("%d",k1,k2);
    }
}






















