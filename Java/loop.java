package loopp;

import java.util.Scanner;

public class loop
{
	static int load_number;
	static Scanner in = new Scanner(System.in);
	int number;
	static int tablica[];
	static int i;
	static int x = 0;
	
	static int load_number(int number) 
	{		
		number = in.nextInt();
		return number;
	}
	
	public static void main(String args[])
	{
		tablica = new int [10];
		
		tablica[0] = 1;
		tablica[1] = 10;
		tablica[2] = 100;
		tablica[3] = 1000;
		tablica[4] = 2;
		tablica[5] = 20;
		tablica[6] = 200;
		tablica[7] = 2000;
		tablica[8] = 30;
		tablica[9] = 300;
		
		System.out.println("Podaj nazwę jaki element tablicy chcesz abym pokazal");	
		wypisywanie_danych();
		
	}	
		
	public static void wypisywanie_danych() 
	{
		int x = 0;
		i = load_number(x);		
		System.out.println("wybrales element : " + tablica[i]);				
	}	
}	
	
