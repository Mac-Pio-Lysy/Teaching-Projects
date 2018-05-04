import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;


public class Open_Save 
{
	static String string_zmienna;
	private static Scanner in;
	
	
	public static void main(String[] args) throws FileNotFoundException 
	{
		File file = new File("D:\\My Apps\\Teaching Apps\\Java\\Fifi\\bin\\zad_15.txt");
		in = new Scanner(file);
		
		string_zmienna = in.nextLine();
		System.out.println("Pierwsza linijka to " + string_zmienna);
	}

}
