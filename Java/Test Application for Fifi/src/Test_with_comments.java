/*
 This is a calculator 
 */
import java.util.Scanner;			//Import library to read data from keyboard

public class Test_with_comments			// main program class
{
		
	static Scanner take = new Scanner(System.in);		//Create new class type scanner named take
		
	public static void main(String[] args)				//Main method of application
	{
		begining_function();							//Initialize method
		calculator_function();							//Initialize method
	}

	public static void begining_function()				//Declaration of begining_function
	{
		//Variable declaration
		int number;										//Variable storing the result of arithmetic operations 
		int number1 = 0;								//Variable storing first number
		int number2 = 0;								//Variable storing second number
		int secondary_variable = 0;						//Variable using to temporary operations
		int chance = 3;									//Variable storing the number of chance 
		int count_if_iteration = 0;						//Variable storing count of iterations
		int i;											//Variable for iterations
			
		System.out.println("Aby uruchomiæ kalkulator nale¿y podaæ dwie liczby tak aby wynik by³ równy 69. \nRównanie musisz sam odgadn¹æ\n");		
		
		for(i = 0; i < chance; i++)						//For loop
		{
			number1 = load_number(secondary_variable);	//Attribution the result of method to variable number1
			number2 = load_number(secondary_variable);	//Attribution the result of method to variable number2
			number = number1 + number2;					//Attribution the result of adding variables number1 and number2 to variable number
			count_if_iteration = i + 1;					//Attribution the result of adding number "1" to variable "i"
			
		if(number == 69) 								//Condition If
		{
			System.out.println("Uda³o ci siê odgadn¹æ has³o mo¿esz kontynuaowaæ. \nKalkulator siê uruchomi³");	
			break;										//Breaking the loop
		}
		else											//Condition else
		{
			System.out.println("Próbój jeszcze raz. To by³a twoja: " + count_if_iteration +" szansa z" + chance);
		}		
			
		if(count_if_iteration == chance)				//Condition If
		{
			System.out.println("Nie uda³o ci siê odgadn¹æ program siê zatrzyma³");
			System.out.println("\nJestem programist¹");
			System.exit(0);								//Ending the application
		}
		}						
	}
	
	public static void calculator_function() 			//Declaration of calculator_function
	{
		//Variable declaration
		int secondary_variable = 0;
		int number;
		int number1;
		int number2;
		int operation;
		
		number1 = load_number(secondary_variable);		//Attribution the result of method to variable number1
		number2 = load_number(secondary_variable);		//Attribution the result of method to variable number2
		System.out.println("Jak¹ chcesz wykonaæ operacjê na liczbach?");
		System.out.println("\nDla dodawania wpisz cyfrê 0");
		System.out.println("\nDla odejmowania wpisz cyfrê 1");
		System.out.println("\nDla mno¿enia wpisz cyfrê 2");
		System.out.println("\nDla dzielenia wpisz cyfrê 3");
		operation = load_number(secondary_variable);	//Attribution the result of method to variable operation
		
		if(operation == 0)								//Condition If
		{
			System.out.println("Wybra³eœ dodawanie.");
			number = number1 + number2;
			write_number(number);
		}
		else if(operation == 1)							//Condition else if
		{
			System.out.println("Wybra³eœ odejmowanie.");
			number = number1 - number2;
			write_number(number);
		}
		else if(operation == 2)							//Condition else if
		{
			System.out.println("Wybra³eœ mno¿enie.");
			number = number1 * number2;
			write_number(number);
		}
		else											//condition else
		{
			System.out.println("Wybra³eœ dzielenie.");
			number = number1 / number2;
			write_number(number);
		}
		repeat();										//Initialize method repeat
	}

	static int load_number(int number) 					//Declaration method load_number
	{
		System.out.println("Podaj liczbe");
		number = take.nextInt();						//Attribution pushed key to variable number
		return number;
	}

	static int write_number(int number)					//Declaration method write_number
	{
		System.out.println("Wynik to: " + number);
		return number;				
	}

	public static void repeat()							//Declaration method repeat
	{
		int number = 0;									//Declaration variable number
		System.out.println("Czy chcesz u¿ywaæ kalkulatora nadal?");
		System.out.println("\nJeœli tak wciœnij 1");
		System.out.println("\nJeœli nie wciœnij podaj dowoln¹ cyfrê");
		number = load_number(number);
		
		if(number != 1 )								//Condition If
		{
			System.exit(0);								//Ending the application
		}			
	}

}
