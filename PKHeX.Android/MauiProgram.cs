using Microsoft.Extensions.Logging;
using PKHeXAndroid.Pages;
using PKHeXAndroid.Services;
using PKHeXAndroid.ViewModels;

namespace PKHeXAndroid;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder.UseMauiApp<App>();

#if DEBUG
        builder.Logging.AddDebug();
#endif

        builder.Services.AddSingleton<SaveService>();
        builder.Services.AddSingleton<AndroidDocumentService>();
        builder.Services.AddSingleton<MainViewModel>();
        builder.Services.AddSingleton<MainPage>();

        return builder.Build();
    }
}
