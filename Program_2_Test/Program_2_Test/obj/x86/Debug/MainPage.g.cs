﻿#pragma checksum "D:\Programy\Program_2_Test\Program_2_Test\MainPage.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "5C4506A91FD0950ED781E4C2782248C0"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Program_2_Test
{
    partial class MainPage : 
        global::Windows.UI.Xaml.Controls.Page, 
        global::Windows.UI.Xaml.Markup.IComponentConnector,
        global::Windows.UI.Xaml.Markup.IComponentConnector2
    {
        /// <summary>
        /// Connect()
        /// </summary>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.Windows.UI.Xaml.Build.Tasks"," 14.0.0.0")]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public void Connect(int connectionId, object target)
        {
            switch(connectionId)
            {
            case 1:
                {
                    this.ShowStatement_Button = (global::Windows.UI.Xaml.Controls.Button)(target);
                    #line 20 "..\..\..\MainPage.xaml"
                    ((global::Windows.UI.Xaml.Controls.Button)this.ShowStatement_Button).Click += this.ShowStatement_Button_Click;
                    #line default
                }
                break;
            case 2:
                {
                    this.IfOrElse_Button = (global::Windows.UI.Xaml.Controls.Button)(target);
                    #line 21 "..\..\..\MainPage.xaml"
                    ((global::Windows.UI.Xaml.Controls.Button)this.IfOrElse_Button).Click += this.IfOrElse_Button_Click;
                    #line default
                }
                break;
            case 3:
                {
                    this.CheckingNextCondition_Button = (global::Windows.UI.Xaml.Controls.Button)(target);
                    #line 22 "..\..\..\MainPage.xaml"
                    ((global::Windows.UI.Xaml.Controls.Button)this.CheckingNextCondition_Button).Click += this.CheckingNextCondition_Button_Click;
                    #line default
                }
                break;
            case 4:
                {
                    this.Lopp_Button = (global::Windows.UI.Xaml.Controls.Button)(target);
                    #line 23 "..\..\..\MainPage.xaml"
                    ((global::Windows.UI.Xaml.Controls.Button)this.Lopp_Button).Click += this.Lopp_Button_Click;
                    #line default
                }
                break;
            case 5:
                {
                    this.MyLabel = (global::Windows.UI.Xaml.Controls.TextBlock)(target);
                }
                break;
            default:
                break;
            }
            this._contentLoaded = true;
        }

        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.Windows.UI.Xaml.Build.Tasks"," 14.0.0.0")]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public global::Windows.UI.Xaml.Markup.IComponentConnector GetBindingConnector(int connectionId, object target)
        {
            global::Windows.UI.Xaml.Markup.IComponentConnector returnValue = null;
            return returnValue;
        }
    }
}
