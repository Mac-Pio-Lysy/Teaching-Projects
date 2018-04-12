/**************************************************************************/
/* LabWindows/CVI User Interface Resource (UIR) Include File              */
/*                                                                        */
/* WARNING: Do not add to, delete from, or otherwise modify the contents  */
/*          of this include file.                                         */
/**************************************************************************/

#include <userint.h>

#ifdef __cplusplus
    extern "C" {
#endif

     /* Panels and Controls: */

#define  PANEL                            1       /* callback function: panelCB */
#define  PANEL_Load_Button                2       /* control type: command, callback function: CB_Load_Button */
#define  PANEL_TABLE                      3       /* control type: table, callback function: (none) */
#define  PANEL_Open_Button                4       /* control type: command, callback function: CB_Open_Button */
#define  PANEL_End_Button                 5       /* control type: command, callback function: CB_End_Button */
#define  PANEL_TABLE_2                    6       /* control type: table, callback function: (none) */
#define  PANEL_Show_data_from_file        7       /* control type: command, callback function: CB_S_D_F_F */
#define  PANEL_Show_Vertex_Button         8       /* control type: command, callback function: CB_Show_Vertex_Button */
#define  PANEL_TEXTBOX                    9       /* control type: textBox, callback function: (none) */
#define  PANEL_Show_Edges                 10      /* control type: command, callback function: CB_Show_Edges */
#define  PANEL_Macierz_incydencji_Bu      11      /* control type: command, callback function: CB_M_I_B */
#define  PANEL_Macierz_sasiedzka_B        12      /* control type: command, callback function: CB_M_S_B */


     /* Control Arrays: */

          /* (no control arrays in the resource file) */


     /* Menu Bars, Menus, and Menu Items: */

          /* (no menu bars in the resource file) */


     /* Callback Prototypes: */

int  CVICALLBACK CB_End_Button(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_Load_Button(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_M_I_B(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_M_S_B(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_Open_Button(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_S_D_F_F(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_Show_Edges(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK CB_Show_Vertex_Button(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK panelCB(int panel, int event, void *callbackData, int eventData1, int eventData2);


#ifdef __cplusplus
    }
#endif
