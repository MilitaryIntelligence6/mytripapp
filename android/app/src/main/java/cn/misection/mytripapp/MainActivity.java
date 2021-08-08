package cn.misection.mytripapp;

import android.os.Bundle;

import cn.misection.plugin.asr.AsrPlugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        registerPlugins();
    }

    private void registerPlugins() {
        AsrPlugin.registerWith(registrarFor("cn.misection.plugin.asr.AsrPlugin"));
    }
}
