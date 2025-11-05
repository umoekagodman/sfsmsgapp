package messaging.sfs.app; 

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.WindowManager;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;

public class BrandSplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Fullscreen
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        );

        setContentView(R.layout.activity_brand_splash);

        // Auto dark mode
        boolean isDark = (getResources().getConfiguration().uiMode & 0x30) == 0x20;
        findViewById(R.id.logo_main).setBackgroundResource(
            isDark ? R.drawable.welcome_logo_light : R.drawable.welcome_logo
        );
        findViewById(R.id.logo_branding).setBackgroundResource(
            isDark ? R.drawable.logo_branding_light : R.drawable.logo_branding
        );

        // Go to Flutter
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MyFlutterActivity.class));
            overridePendingTransition(0, 0);
            finish();
        }, 1200);
    }
}
