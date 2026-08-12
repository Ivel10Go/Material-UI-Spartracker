package com.spartracker.spartracker.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import com.spartracker.spartracker.MainActivity

/** Extra, über das ein angetipptes Widget sein Sparziel an die App meldet. */
const val EXTRA_GOAL_ID = "com.spartracker.spartracker.extra.GOAL_ID"

/**
 * Öffnet die App direkt beim angetippten Sparziel.
 *
 * Die `data`-Uri trägt nichts zur Auswertung bei, macht den Intent aber
 * eindeutig: Ohne sie hielte Android alle Widget-Instanzen für denselben
 * PendingIntent und jedes Widget öffnete dasselbe Ziel.
 */
fun openGoalIntent(context: Context, goalId: Int): Intent =
    Intent(context, MainActivity::class.java).apply {
        action = Intent.ACTION_VIEW
        data = Uri.parse("spartracker://goal/$goalId")
        putExtra(EXTRA_GOAL_ID, goalId)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
            Intent.FLAG_ACTIVITY_SINGLE_TOP
    }

/** Startet die App ohne bestimmtes Ziel. */
fun openAppIntent(context: Context): Intent =
    Intent(context, MainActivity::class.java).apply {
        action = Intent.ACTION_MAIN
        addCategory(Intent.CATEGORY_LAUNCHER)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }

/** Öffnet die Widget-Einstellungen für genau diese Widget-Instanz. */
fun configureWidgetIntent(context: Context, appWidgetId: Int): Intent =
    Intent(context, SavingsGoalWidgetConfigActivity::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_CONFIGURE
        data = Uri.parse("spartracker://widget/$appWidgetId")
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK
    }

/** Liest die Ziel-ID aus einem Widget-Intent; `null`, wenn keine drinsteht. */
fun goalIdFrom(intent: Intent?): Int? {
    val goalId = intent?.getIntExtra(EXTRA_GOAL_ID, -1) ?: -1
    return if (goalId >= 0) goalId else null
}
