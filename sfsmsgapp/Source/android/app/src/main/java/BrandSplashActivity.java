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

        // Fullscreen
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        );

        setContentView(R.layout.activity_brand_splash);

        // Auto dark mode
        boolean isDark = (getResources().getConfiguration().uiMode & 0x30) == 0x20;
        ((android.widget.ImageView) findViewById(R.id.logo_main)).setImageResource(
            isDark ? R.drawable.welcome_logo_light : R.drawable.welcome_logo
        );
        ((android.widget.ImageView) findViewById(R.id.logo_branding)).setImageResource(
            isDark ? R.drawable.logo_branding_light : R.drawable.logo_branding
        );

        // Short duration - just for branding, then let Flutter handle loading
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MyFlutterActivity.class));
            overridePendingTransition(0, 0);
            finish();
        }, 1200); // Back to original 1200ms
    }
}
