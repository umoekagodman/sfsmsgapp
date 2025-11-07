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

        // Set the content view - THIS IS CRITICAL
        setContentView(R.layout.activity_brand_splash);

        // Fullscreen
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        );

        // Auto dark mode for images
        boolean isDark = (getResources().getConfiguration().uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES;
        
        // Set appropriate logos based on dark/light mode
        android.widget.ImageView logoMain = findViewById(R.id.logo_main);
        android.widget.ImageView logoBranding = findViewById(R.id.logo_branding);
        
        logoMain.setImageResource(
            isDark ? R.drawable.welcome_logo_light : R.drawable.welcome_logo
        );
        logoBranding.setImageResource(
            isDark ? R.drawable.logo_branding_light : R.drawable.logo_branding
        );

        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MyFlutterActivity.class));
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            finish();
        }, 2000);
    }
}
