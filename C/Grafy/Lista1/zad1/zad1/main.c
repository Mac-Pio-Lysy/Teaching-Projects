#include <stdio.h>
#include <stdlib.h>
/*          ADJACENCY MATRIX                            */


//Inicjalizacja zmiennych

int k;  //Krawêdzie
int w;  //Wierzcho³ki
int i;
int j;


int tab_macierzy[5][2];
int tab_dane_z_pliku[5][2] = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}};



int main()
{

int ch;
FILE *wp;
long licznik;













    printf("\nKolejny etap przypisanie:\n\n");
}


void wczytaj_plik()
{
    FILE *plik;
    plik = fopen("graf.txt", "r");
    char singleLine[150];

    while(!feof(plik))
    {
        fgets(tab_macierzy, 150, plik);
        puts(tab_macierzy);
    }

    fclose(plik);
}
void pokaz_dane_z_pliku()
{
    w = 4;
    k = 5;
    for(i=0; i<=w; i++)
    {
        for(j=0; j<2; j++)
        {
            printf("%d", tab_dane_z_pliku[i][j]);
        }
        printf("\n");
    }
}
void skierowana_macierz()
{
    int i,j,v1,v2;

    k = 5;
    w = 4;
    for(i=0;i<w;i++)
    {
        for(j=0;j<w;j++)
            tab_macierzy[i][j]=0;
    }
    /*    creating edges :P    */
    for(i=0;i<k;i++)
    {
        printf("Enter the edges (format: V1 V2) : ");
        scanf("%d%d",&v1,&v2);

        tab_macierzy[v1-1][v2-1]=1;

    }

    for(i=0;i<w;i++)
    {
        for(j=0;j<w;j++)
            printf(" %d ",tab_macierzy[i][j]);
        printf("\n");
    }
}
