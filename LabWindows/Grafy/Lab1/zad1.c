//==============================================================================
//
// Title:		zad1
// Purpose:		A short description of the application.
//
// Created on:	03.04.2018 at 17:49:45 by Piotr Macholak.
// Copyright:	Uniwersytet Zielonogórski: Wydzi­a³ Infor­matyki, Elek­trotech­niki i Automatyki. All Rights Reserved.
//
//==============================================================================

//==============================================================================
// Include files

#include <formatio.h>
#include <ansi_c.h>
#include <cvirte.h>		
#include <userint.h>
#include "zad1.h"
#include "toolbox.h"
#include <stdio.h>
#include <stdlib.h>

//==============================================================================
// Constants

//==============================================================================
// Types

//==============================================================================
// Static global variables

static int panelHandle = 0;

//==============================================================================
// Static functions

//==============================================================================
// Global variables

int security_file = 0;
int plik;
int plik2;
int plik3;
char path_name[MAX_PATHNAME_LEN];

char buffer_lini[500];
int i;
int ilosc;
char liczba[500] = {0};
int liczba_wierzcholkow;
int liczba_krawedzi;
int ilosc_kolumn;

double wierzcholki[1];
double krawedzie[1];

double macierz[5][2] = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}}; 

double tab_wierzcholki[100];
double tab_krawedzie[100];

char tym_wierzcholki[100] = {0};
char tym_krawedzie[100] = {0};
//==============================================================================
// Global functions

/// HIFN The main entry-point function.
int main (int argc, char *argv[])
{
	int error = 0;
	
	/* initialize and load resources */
	nullChk (InitCVIRTE (0, argv, 0));
	errChk (panelHandle = LoadPanel (0, "zad1.uir", PANEL));
	InsertTableRows (panelHandle, PANEL_TABLE, 1, 1, VAL_USE_MASTER_CELL_TYPE);
	InsertTableRows (panelHandle, PANEL_TABLE_2, 1, 100, VAL_USE_MASTER_CELL_TYPE);

	/* display the panel and run the user interface */
	errChk (DisplayPanel (panelHandle));
	errChk (RunUserInterface ());

Error:
	/* clean up */
	if (panelHandle > 0)
		DiscardPanel (panelHandle);
	return 0;
}

//==============================================================================
// UI callback function prototypes

/// HIFN Exit when the user dismisses the panel.
int CVICALLBACK panelCB (int panel, int event, void *callbackData,
		int eventData1, int eventData2)
{
	if (event == EVENT_CLOSE)
		QuitUserInterface (0);
	return 0;
}

int CVICALLBACK CB_Load_Button (int panel, int control, int event,
								void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				 plik = OpenFile (path_name, VAL_READ_ONLY, VAL_OPEN_AS_IS, VAL_ASCII);		//Funkcja otwieraj¹ca plik z danymi
				 
				 for(i=0; i<1; i++)
				 {
				 ReadLine (plik, buffer_lini, -1);
				 sscanf(buffer_lini, "%lf%lf", &wierzcholki[i], &krawedzie[i]);
				 SetTableCellVal (panelHandle, PANEL_TABLE, MakePoint(1, i+1), wierzcholki[i]);
				 SetTableCellVal (panelHandle, PANEL_TABLE, MakePoint(2, i+1), krawedzie[i]);
				 }
				 
			break;
	}
	return 0;
}

int CVICALLBACK CB_Open_Button (int panel, int control, int event,
								void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				security_file = FileSelectPopup ("", "*.txt", "", "Wybierz plik z danymi", VAL_LOAD_BUTTON, 0, 0, 1, 0, path_name);		//Funkcja otwieraj¹ca okienko popup	
				
				if (security_file !=0);		//Zabezpieczenie programu przez zablokowaniem przed wybraniem pliku

			break;
	}
	return 0;
}

int CVICALLBACK CB_End_Button (int panel, int control, int event,
							   void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				QuitUserInterface(0);		//Funkcja zamykaj¹ca aplikacjê.

			break;
	}
	return 0;
}

int CVICALLBACK CB_S_D_F_F (int panel, int control, int event,
							void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
			   	 plik = OpenFile (path_name, VAL_READ_ONLY, VAL_OPEN_AS_IS, VAL_ASCII);		//Funkcja otwieraj¹ca plik z danymi
				 
				 for(i=0; i<20; i++)
				 {
				 ReadLine (plik, buffer_lini, -1);
				 sscanf(buffer_lini, "%lf%lf", &tab_wierzcholki[i], &tab_krawedzie[i]);
				 SetTableCellVal (panelHandle, PANEL_TABLE_2, MakePoint(1, i+1), tab_wierzcholki[i]);
				 SetTableCellVal (panelHandle, PANEL_TABLE_2, MakePoint(2, i+1), tab_krawedzie[i]);
				 }
			break;
	}
	return 0;
}

int CVICALLBACK CB_Show_Vertex_Button (int panel, int control, int event,
									   void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				plik = OpenFile (path_name, VAL_READ_ONLY, VAL_OPEN_AS_IS, VAL_ASCII);		//Funkcja otwieraj¹ca plik z danymi

				liczba_wierzcholkow = wierzcholki[0];
				
				SetCtrlVal (panelHandle, PANEL_TEXTBOX, "\nZbior wierzcholkow V = {");
				
				for(i=0; i<liczba_wierzcholkow; i++)
				{
					double doublei = i+1;
					sprintf (liczba, "%g", doublei);
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, liczba);
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, ",");
				}
				
				SetCtrlVal (panelHandle, PANEL_TEXTBOX, "}");

			break;
	}
	return 0;
}

int CVICALLBACK CB_Show_Edges (int panel, int control, int event,
							   void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				plik = OpenFile (path_name, VAL_READ_ONLY, VAL_OPEN_AS_IS, VAL_ASCII);		//Funkcja otwieraj¹ca plik z danymi

				liczba_krawedzi = krawedzie[0];
				liczba_krawedzi = liczba_krawedzi + 1;
				
				SetCtrlVal (panelHandle, PANEL_TEXTBOX, "\nZbior krawedzi E = {");
				
				for(i=1; i<liczba_krawedzi; i++)
				{
					sprintf (tym_wierzcholki, "%g", tab_wierzcholki[i]);
					sprintf (tym_krawedzie, "%g", tab_krawedzie[i]); 
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, tym_wierzcholki);
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, "-");
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, tym_krawedzie);
					SetCtrlVal (panelHandle, PANEL_TEXTBOX, ", ");
				}
				
				SetCtrlVal (panelHandle, PANEL_TEXTBOX, "}");

			break;
	}
	return 0;
}

int CVICALLBACK CB_M_S_B (int panel, int control, int event,
						  void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			
				plik3 = OpenFile (path_name, VAL_READ_ONLY, VAL_OPEN_AS_IS, VAL_ASCII);
				
				SetCtrlVal (panelHandle, PANEL_TEXTBOX, "\nksefjkvhsrjkvhsiidjfivbi");
				
				for(i-1; i<10; i++)
				{
					
				}
				
				
				
				
				

			break;
	}
	return 0;
}

int CVICALLBACK CB_M_I_B (int panel, int control, int event,
						  void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:

			break;
	}
	return 0;
}
