package com.example.flutter_application_101

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.flutter_application_101/haptics"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "triggerHaptic") {
                val strength = call.argument<String>("strength") ?: "light"
                performHapticFeedback(strength)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun performHapticFeedback(strength: String) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (!vibrator.hasVibrator()) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val hasAmplitude = vibrator.hasAmplitudeControl()

            when (strength) {
                "light" -> {
                    if (hasAmplitude) {
                        vibrator.vibrate(VibrationEffect.createOneShot(35, 150))
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
                    } else {
                        vibrator.vibrate(VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE))
                    }
                }
                "medium" -> {
                    if (hasAmplitude) {
                        vibrator.vibrate(VibrationEffect.createOneShot(75, 230))
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK))
                    } else {
                        vibrator.vibrate(VibrationEffect.createOneShot(75, VibrationEffect.DEFAULT_AMPLITUDE))
                    }
                }
                "heavy", "hard", "strong" -> {
                    if (hasAmplitude) {
                        vibrator.vibrate(VibrationEffect.createOneShot(120, 255))
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK))
                    } else {
                        vibrator.vibrate(VibrationEffect.createOneShot(120, VibrationEffect.DEFAULT_AMPLITUDE))
                    }
                }
                "selection" -> {
                    if (hasAmplitude) {
                        vibrator.vibrate(VibrationEffect.createOneShot(45, 190))
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
                    } else {
                        vibrator.vibrate(VibrationEffect.createOneShot(45, VibrationEffect.DEFAULT_AMPLITUDE))
                    }
                }
                "vibrate", "error" -> {
                    if (hasAmplitude) {
                        val timings = longArrayOf(0, 70, 50, 90)
                        val amplitudes = intArrayOf(0, 255, 0, 255)
                        vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
                    } else {
                        vibrator.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
                    }
                }
                else -> {
                    vibrator.vibrate(VibrationEffect.createOneShot(50, 200))
                }
            }
        } else {
            @Suppress("DEPRECATION")
            when (strength) {
                "light" -> vibrator.vibrate(35)
                "medium" -> vibrator.vibrate(75)
                "heavy", "hard", "strong" -> vibrator.vibrate(120)
                "selection" -> vibrator.vibrate(45)
                "vibrate", "error" -> vibrator.vibrate(200)
                else -> vibrator.vibrate(50)
            }
        }
    }
}
