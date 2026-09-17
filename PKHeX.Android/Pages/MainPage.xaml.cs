using PKHeXAndroid.ViewModels;

namespace PKHeXAndroid.Pages;

public partial class MainPage : ContentPage
{
    public MainPage(MainViewModel viewModel)
    {
        InitializeComponent();
        BindingContext = viewModel;
    }
}
