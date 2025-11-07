package messaging.sfs.app; 

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.WindowManager;
import androidx.appcompat.app.AppCompatActivity;

public class BrandSplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Use the themes defined in your styles.xml
        int nightModeFlags = getResources().getConfiguration().uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK;
        if (nightModeFlags == android.content.res.Configuration.UI_MODE_NIGHT_YES) {
            setTheme(R.style.LaunchTheme); // Use your LaunchTheme
        } else {
            setTheme(R.style.LaunchTheme); // Use your LaunchTheme (it should handle both light/dark)
        }

        // Fullscreen
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        );

        setContentView(R.layout.activity_brand_splash);

        // Auto dark mode
        boolean isDark = (getResources().getConfiguration().uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES;
        ((android.widget.ImageView) findViewById(R.id.logo_main)).setImageResource(
            isDark ? R.drawable.welcome_logo_light : R.drawable.welcome_logo
        );
        ((android.widget.ImageView) findViewById(R.id.logo_branding)).setImageResource(
            isDark ? R.drawable.logo_branding_light : R.drawable.logo_branding
        );

        // Extended duration - show native splash while Flutter loads data
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MyFlutterActivity.class));
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            finish();
        }, 3000); // Extended to 3 seconds to allow data loading
    }
}
