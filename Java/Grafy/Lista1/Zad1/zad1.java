
public class zad1 
{

	//Variables declaration
	
	static double [][] macierz = {{1,2}, {2,3}, {3,4}, {1,4}, {2,4}}; 	
	static int i;
	static int j;
	static int wierzcholki = 4;
	
	
	public static void main(String[] args) 
	{
		show_data();
	}



	public static void show_data() 
	{
		System.out.println("Dane jakie wczytales: \n");
		for (i=0; i<wierzcholki; i++)
		{
			for (j=0; j<wierzcholki; j++)
			{			
				System.out.println(macierz[i][j]);
			}
		}		
	}
	
	
	
}
