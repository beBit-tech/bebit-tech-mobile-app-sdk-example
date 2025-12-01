package com.bebit.testApp.Activity;

import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.bebit.testApp.R;
import com.bebittech.omnisegment.OmniSegment;
import com.bebittech.omnisegment.OSGEvent;
import java.util.HashMap;
import java.util.Map;

import com.google.android.gms.tasks.Task;
import com.google.android.play.core.appupdate.AppUpdateManager;
import com.google.android.play.core.appupdate.AppUpdateManagerFactory;
import com.google.android.play.core.appupdate.AppUpdateInfo;
import com.google.android.play.core.install.model.UpdateAvailability;
import com.google.android.play.core.install.model.AppUpdateType;


public class LoginActivity extends AppCompatActivity {

    private EditText usernameEditText;
    private EditText passwordEditText;
    private Button loginButton;
    private Button registerButton;

    private final String uid = "omnisegmentXXXXX";
    private final String email = "XXXX@bebit-tech.com";
    private final String regType = "google";
    private static final int REQUEST_UPDATE_PROFILE = 1001;


    @Override
    protected void onResume() {
        super.onResume();
        // OmniSegment SDK
        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-current-page
        // Purpose: Track current page/screen for user journey analytics
        OmniSegment.setCurrentPage("Login");

        AppUpdateManager appUpdateManager = AppUpdateManagerFactory.create(getApplicationContext());
        Task<AppUpdateInfo> appUpdateInfoTask = appUpdateManager.getAppUpdateInfo();

        appUpdateInfoTask.addOnSuccessListener(appUpdateInfo -> {
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
                && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)) {
                    try {
                        // Request the update.
                        appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            AppUpdateType.IMMEDIATE,
                            this,
                                REQUEST_UPDATE_PROFILE);
                    } catch (IntentSender.SendIntentException e) {
                        e.printStackTrace();
                    }
            }
        });

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        usernameEditText = findViewById(R.id.username);
        passwordEditText = findViewById(R.id.password);
        loginButton = findViewById(R.id.login);
        registerButton = findViewById(R.id.register);

        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = usernameEditText.getText().toString();
                String password = passwordEditText.getText().toString();

                if (!username.isEmpty() && password.equals("Test")) {

                    Intent intent = new Intent(LoginActivity.this, com.bebit.testApp.Activity.MainActivity.class);
                    // OmniSegment SDK
                    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-user
                    // Purpose: Track user login event and associate future events with this user ID
                    OmniSegment.login(username);
                    startActivity(intent);
                    finish();
                } else {

                    Toast.makeText(LoginActivity.this, "帳號或密碼錯誤", Toast.LENGTH_SHORT).show();
                }
            }
        });

        registerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                registerButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        String location = "app://registerActivity";
                        String locationTitle = "註冊";
                        Map<String, Object> label = new HashMap<>();
                        label.put("email", email);
                        label.put("regType", regType);
                        // OmniSegment SDK
                        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#complete-registration
                        // Purpose: Track user registration completion with custom attributes (email, registration type)
                        OSGEvent event = OSGEvent.completeRegistration(label);
                        event.locationTitle = locationTitle;
                        event.location = location;

                        OmniSegment.trackEvent(event);
                        Toast.makeText(LoginActivity.this, "註冊成功", Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });
    }
}
