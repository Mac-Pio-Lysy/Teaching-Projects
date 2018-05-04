import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.PrintWriter;


public class Open_Save 
{
	static String string_zmienna;
	private static Scanner in;
	static int zmienna;
	static int i;
	static int tab[];
	
	
	public static void main(String[] args) throws FileNotFoundException 
	{
		tab = new int [15];
		
		File file = new File("D:\\My Apps\\Teaching Apps\\Java\\Fifi\\bin\\zad_15.txt");
		in = new Scanner(file);
		
		for(i=0; i<15; i++)
		{
		string_zmienna = in.nextLine();
		zmienna = Integer.parseInt(string_zmienna);
		tab[i] = zmienna;
		}
		for(i=0; i<15; i++)
		{
			System.out.println("Element tablicy " + i + " to " + tab[i]);
		}
		
		////////////////////////////////////    ZAPIS    ///////////////////////////
		
		PrintWriter zapis = new PrintWriter("D:\\My Apps\\Teaching Apps\\Java\\Fifi\\bin\\wykonane.txt");
		for(i=0; i<15; i++)
		{
		zapis.println(tab[i]);
		}
		zapis.close();
		
	
	
	
	
	}

}
