package com.colorflow.watersort;

import android.content.res.AssetFileDescriptor;
import android.media.AudioAttributes;
import android.media.SoundPool;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.FlutterInjector;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.colorflow.watersort/audio";
    private SoundPool soundPool;
    private final Map<String, Integer> soundMap = new HashMap<>();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        initSoundPool();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if ("playSound".equals(call.method)) {
                        String soundName = call.arguments();
                        playSound(soundName);
                        result.success(true);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private void initSoundPool() {
        AudioAttributes audioAttributes = new AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build();

        soundPool = new SoundPool.Builder()
            .setMaxStreams(8)
            .setAudioAttributes(audioAttributes)
            .build();

        loadSound("click", "assets/sounds/click.wav");
        loadSound("select", "assets/sounds/select.wav");
        loadSound("pour", "assets/sounds/pour.wav");
        loadSound("error", "assets/sounds/error.wav");
        loadSound("win", "assets/sounds/win.wav");
    }

    private void loadSound(String name, String assetPath) {
        try {
            String key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetPath);
            AssetFileDescriptor afd = getAssets().openFd(key);
            int soundId = soundPool.load(afd, 1);
            soundMap.put(name, soundId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void playSound(String name) {
        Integer soundId = soundMap.get(name);
        if (soundId != null && soundId != 0 && soundPool != null) {
            soundPool.play(soundId, 1.0f, 1.0f, 1, 0, 1.0f);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (soundPool != null) {
            soundPool.release();
            soundPool = null;
        }
    }
}
