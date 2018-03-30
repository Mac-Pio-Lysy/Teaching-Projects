/*
 This is a calculator 
 */
import java.util.Scanner;

public class Test 
{
	//variable declaration
	static int chosing_number;
	
	
	static Scanner take = new Scanner(System.in);
	
	
	public static void main(String[] args)
	{
		begining_function();
		calculator_function();
	}


	public static void begining_function()
	{
		int number;
		int number1 = 0;
		int number2 = 0;
		int secondary_variable = 0;
		int chance = 3;
		int count_if_iteration = 0;
		int i;
			
		System.out.println("Aby uruchomiæ kalkulator nale¿y podaæ dwie liczby tak aby wynik by³ równy 69. \nRównanie musisz sam odgadn¹æ\n");		
		
		for(i = 0; i < chance; i++)			
		{
			number1 = load_number(secondary_variable);
			number2 = load_number(secondary_variable);
			number = number1 + number2;
			count_if_iteration = i + 1;
			
		if(number == 69) 
		{
			System.out.println("Uda³o ci siê odgadn¹æ has³o mo¿esz kontynuaowaæ. \nKalkulator siê uruchomi³");	
			break;
		}
		else
		{
			System.out.println("Próbój jeszcze raz. To by³a twoja: " + count_if_iteration +" szansa z" + chance);
		}		
			
		if(count_if_iteration == chance)
		{
			System.out.println("Nie uda³o ci siê odgadn¹æ program siê zatrzyma³");
			System.out.println("\nJestem programist¹");
			System.exit(0);
		}
		}						
	}
	
	public static void calculator_function() 
	{
		int secondary_variable = 0;
		int number;
		int number1;
		int number2;
		int operation;
		
		number1 = load_number(secondary_variable);
		number2 = load_number(secondary_variable);
		System.out.println("Jak¹ chcesz wykonaæ operacjê na liczbach?");
		System.out.println("\nDla dodawania wpisz cyfrê 0");
		System.out.println("\nDla odejmowania wpisz cyfrê 1");
		System.out.println("\nDla mno¿enia wpisz cyfrê 2");
		System.out.println("\nDla dzielenia wpisz cyfrê 3");
		operation = load_number(secondary_variable);
		
		if(operation == 0)
		{
			System.out.println("Wybra³eœ dodawanie.");
			number = number1 + number2;
			write_number(number);
		}
		else if(operation == 1)
		{
			System.out.println("Wybra³eœ odejmowanie.");
			number = number1 - number2;
			write_number(number);
		}
		else if(operation == 2)
		{
			System.out.println("Wybra³eœ mno¿enie.");
			number = number1 * number2;
			write_number(number);
		}
		else
		{
			System.out.println("Wybra³eœ dzielenie.");
			number = number1 / number2;
			write_number(number);
		}
		repeat();
	}

	static int load_number(int number) 
	{
		System.out.println("Podaj liczbe");
		number = take.nextInt();
		return number;
	}

	static int write_number(int number)
	{
		System.out.println("Wynik to: " + number);
		return number;				
	}

	public static void repeat()
	{
		int number = 0;
		System.out.println("Czy chcesz u¿ywaæ kalkulatora nadal?");
		System.out.println("\nJeœli tak wciœnij 1");
		System.out.println("\nJeœli nie wciœnij podaj dowoln¹ cyfrê");
		number = load_number(number);
		
		if(number != 1 )
		{
			System.exit(0);
		}			
	}

}
