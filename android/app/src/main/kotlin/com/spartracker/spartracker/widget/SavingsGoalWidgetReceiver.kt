package com.spartracker.spartracker.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.state.updateAppWidgetState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/** Bindeglied zwischen Android und dem breiten [SavingsGoalWidget]. */
class SavingsGoalWidgetReceiver : GlanceAppWidgetReceiver() {

    override val glanceAppWidget: GlanceAppWidget = SavingsGoalWidget()

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        // Sonst bliebe die Zuordnung Widget -> Sparziel für immer stehen.
        appWidgetIds.forEach { WidgetGoalStore.clearSelection(context, it) }
    }
}

/** Bindeglied zwischen Android und dem 2x2-[SavingsGoalRingWidget]. */
class SavingsGoalRingWidgetReceiver : GlanceAppWidgetReceiver() {

    override val glanceAppWidget: GlanceAppWidget = SavingsGoalRingWidget()

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { WidgetGoalStore.clearSelection(context, it) }
    }
}

/**
 * Stößt Neuzeichnungen an.
 *
 * `GlanceAppWidget.update` ist eine Suspend-Funktion, die Aufrufer hier
 * (Flutter-Kanal, Konfigurations-Activity) sind es nicht - deshalb der
 * eigene, an nichts gebundene Scope. Fehler bleiben bewusst folgenlos: Ein
 * nicht aktualisiertes Widget zeigt alte Zahlen, mehr passiert nicht.
 */
object SavingsGoalWidgetUpdater {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    /** Aktualisiert alle Instanzen beider Bauarten - nach neuen Daten. */
    fun updateAll(context: Context) {
        val appContext = context.applicationContext
        scope.launch {
            runCatching {
                val manager = GlanceAppWidgetManager(appContext)
                refresh(
                    appContext,
                    SavingsGoalWidget(),
                    manager.getGlanceIds(SavingsGoalWidget::class.java),
                )
                refresh(
                    appContext,
                    SavingsGoalRingWidget(),
                    manager.getGlanceIds(SavingsGoalRingWidget::class.java),
                )
            }
        }
    }

    /** Aktualisiert eine Instanz - nach dem Wechsel des Sparziels. */
    fun update(context: Context, appWidgetId: Int) {
        val appContext = context.applicationContext
        scope.launch {
            runCatching {
                // Beim erstmaligen Ablegen ist das Widget noch nicht
                // gebunden; dann gibt es keine ID und nichts zu tun - die
                // erste Komposition liest die Auswahl ohnehin frisch.
                val glanceId = GlanceAppWidgetManager(appContext).getGlanceIdBy(appWidgetId)
                refresh(appContext, widgetFor(appContext, appWidgetId), listOf(glanceId))
            }
        }
    }

    /**
     * Erhöht den Revisionszähler und lässt neu zeichnen.
     *
     * Die Reihenfolge ist wichtig: Erst muss sich der Glance-Zustand
     * ändern, sonst hält `update()` die Komposition für unverändert und
     * tut nichts (siehe [WidgetRevisionKey]).
     */
    private suspend fun refresh(
        context: Context,
        widget: GlanceAppWidget,
        glanceIds: List<GlanceId>,
    ) {
        glanceIds.forEach { glanceId ->
            updateAppWidgetState(context, glanceId) { prefs ->
                prefs[WidgetRevisionKey] = (prefs[WidgetRevisionKey] ?: 0) + 1
            }
            widget.update(context, glanceId)
        }
    }

    /**
     * Ermittelt die Bauart einer Widget-Instanz.
     *
     * Beide teilen sich die Konfigurations-Activity; welche Instanz gerade
     * eingestellt wird, verrät nur der zugehörige Provider.
     */
    private fun widgetFor(context: Context, appWidgetId: Int): GlanceAppWidget {
        val provider = AppWidgetManager.getInstance(context)
            ?.getAppWidgetInfo(appWidgetId)
            ?.provider
        return if (provider?.className == SavingsGoalRingWidgetReceiver::class.java.name) {
            SavingsGoalRingWidget()
        } else {
            SavingsGoalWidget()
        }
    }
}
