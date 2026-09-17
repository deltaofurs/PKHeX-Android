using Android.App;
using Android.Content;
using Android.Content.PM;

namespace PKHeXAndroid.Platforms.Android;

[Activity(
    Label = "PKHeX Android",
    MainLauncher = true,
    Exported = true,
    ConfigurationChanges = ConfigChanges.ScreenSize |
                           ConfigChanges.Orientation |
                           ConfigChanges.UiMode |
                           ConfigChanges.ScreenLayout |
                           ConfigChanges.SmallestScreenSize |
                           ConfigChanges.Density)]
public class MainActivity : MauiAppCompatActivity
{
    public static event Action<int, Result, Intent?>? ActivityResultForwarded;

#pragma warning disable CS0672
    protected override void OnActivityResult(int requestCode, Result resultCode, Intent? data)
#pragma warning restore CS0672
    {
        base.OnActivityResult(requestCode, resultCode, data);
        ActivityResultForwarded?.Invoke(requestCode, resultCode, data);
    }
}
