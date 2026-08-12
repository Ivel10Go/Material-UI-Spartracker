package com.spartracker.spartracker

import android.content.Intent
import com.spartracker.spartracker.widget.SavingsGoalWidgetUpdater
import com.spartracker.spartracker.widget.WidgetGoalStore
import com.spartracker.spartracker.widget.goalIdFrom
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Einstiegspunkt der App - und zugleich Vermittler zum Homescreen-Widget.
 *
 * In eine Richtung nimmt sie den aktuellen Stand der Sparziele von Flutter
 * entgegen und legt ihn dort ab, wo das Widget ihn lesen kann. In die andere
 * meldet sie einen Widget-Tipp an Flutter, damit die App direkt das
 * passende Sparziel öffnet.
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null

    /**
     * Ziel-ID aus einem Widget-Tipp, der eintraf, bevor Flutter bereit war.
     *
     * Beim Kaltstart über das Widget existiert die Dart-Seite noch gar
     * nicht; sie holt die ID ab, sobald sie läuft.
     */
    private var pendingGoalId: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pendingGoalId = goalIdFrom(intent)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "publishGoals" -> {
                        WidgetGoalStore.savePayload(
                            this@MainActivity,
                            call.argument<String>("goals") ?: "{}",
                        )
                        SavingsGoalWidgetUpdater.updateAll(this@MainActivity)
                        result.success(null)
                    }

                    "consumeLaunchGoalId" -> {
                        result.success(pendingGoalId)
                        pendingGoalId = null
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        val goalId = goalIdFrom(intent) ?: return
        val target = channel
        if (target != null) {
            target.invokeMethod("openGoal", goalId)
        } else {
            pendingGoalId = goalId
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val CHANNEL = "com.spartracker.spartracker/widget"
    }
}
