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
			
		System.out.println("Aby uruchomi� kalkulator nale�y poda� dwie liczby tak aby wynik by� r�wny 69. \nR�wnanie musisz sam odgadn��\n");		
		
		for(i = 0; i < chance; i++)			
		{
			number1 = load_number(secondary_variable);
			number2 = load_number(secondary_variable);
			number = number1 + number2;
			count_if_iteration = i + 1;
			
		if(number == 69) 
		{
			System.out.println("Uda�o ci si� odgadn�� has�o mo�esz kontynuaowa�. \nKalkulator si� uruchomi�");	
			break;
		}
		else
		{
			System.out.println("Pr�b�j jeszcze raz. To by�a twoja: " + count_if_iteration +" szansa z" + chance);
		}		
			
		if(count_if_iteration == chance)
		{
			System.out.println("Nie uda�o ci si� odgadn�� program si� zatrzyma�");
			System.out.println("\nJestem programist�");
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
		System.out.println("Jak� chcesz wykona� operacj� na liczbach?");
		System.out.println("\nDla dodawania wpisz cyfr� 0");
		System.out.println("\nDla odejmowania wpisz cyfr� 1");
		System.out.println("\nDla mno�enia wpisz cyfr� 2");
		System.out.println("\nDla dzielenia wpisz cyfr� 3");
		operation = load_number(secondary_variable);
		
		if(operation == 0)
		{
			System.out.println("Wybra�e� dodawanie.");
			number = number1 + number2;
			write_number(number);
		}
		else if(operation == 1)
		{
			System.out.println("Wybra�e� odejmowanie.");
			number = number1 - number2;
			write_number(number);
		}
		else if(operation == 2)
		{
			System.out.println("Wybra�e� mno�enie.");
			number = number1 * number2;
			write_number(number);
		}
		else
		{
			System.out.println("Wybra�e� dzielenie.");
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
		System.out.println("Czy chcesz u�ywa� kalkulatora nadal?");
		System.out.println("\nJe�li tak wci�nij 1");
		System.out.println("\nJe�li nie wci�nij podaj dowoln� cyfr�");
		number = load_number(number);
		
		if(number != 1 )
		{
			System.exit(0);
		}			
	}

}
