using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace Program_2_Test
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
        }

        private void ShowStatement_Button_Click(object sender, RoutedEventArgs e)
        {
            String name = "Quentin";
            int x = 3;
            x = x * 17;
            double d = Math.PI / 2;
            MyLabel.Text = "Nazwa to " + name + "\nx jest równe" + x + "\nd jest równe" + d;
        }

        private void IfOrElse_Button_Click(object sender, RoutedEventArgs e)
        {
            int x = 5;
            if (x == 10)
            {
                MyLabel.Text = "x musi być równe 10";
            }
            else
            {
                MyLabel.Text = "x nie jest równe 10";
            }
        }

        private void CheckingNextCondition_Button_Click(object sender, RoutedEventArgs e)
        {
            int SomeValue = 4;
            string name = "Krzysiek";
            if ((SomeValue == 3) && (name.Equals("Janek")))
            {
                MyLabel.Text = "SomeValue jest róne 3 i name jest równe Janek";
            }
            MyLabel.Text = "ten wiersz jest wykorzystywany bez względu na warunki";
        }

        private void Lopp_Button_Click(object sender, RoutedEventArgs e)
        {
            int count = 0;
            while (count < 10)
            {
                count = count + 1;
            }

            for (int i = 0; i <5; i++)
            {
                count = count - 1;
            }
            MyLabel.Text = "Odpowiedź brzmi " + count;
        }
    }
}
