package com.spartracker.spartracker.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.spartracker.spartracker.R
import org.json.JSONObject

/**
 * Ein Farbwert in seiner hellen und seiner dunklen Ausprägung.
 *
 * Beim Schreiben der Daten steht noch nicht fest, ob der Launcher später
 * hell oder dunkel läuft - deshalb reist immer beides mit.
 */
data class DualColor(val light: Int, val dark: Int)

/**
 * Der Stand eines Sparziels, so wie ihn das Widget braucht.
 *
 * Alle Texte kommen fertig formatiert aus der App. Das Widget rechnet also
 * weder Beträge um noch übersetzt es etwas - so kann es gar nicht erst von
 * der Sprache und dem Zahlenformat der App abweichen.
 */
data class WidgetGoal(
    val id: Int,
    val name: String,
    val target: Double,
    val saved: Double,
    /** Dateipfad des von Flutter gerenderten Symbols (weiße Maske). */
    val iconPath: String?,
    /** Gesparter Betrag, z. B. "320,00 €". */
    val savedText: String,
    /** "320,00 € von 800,00 €". */
    val amountLine: String,
    /** "von 800,00 €". */
    val targetLine: String,
    /** "noch 480,00 €" bzw. "Ziel erreicht". */
    val statusLine: String,
    /** "40 %". */
    val percentText: String,
    val accent: DualColor,
    val container: DualColor,
    val onContainer: DualColor,
    val track: DualColor,
) {
    /** Fortschritt zwischen 0 und 1. */
    val progress: Float
        get() = if (target <= 0.0) 0f else (saved / target).coerceIn(0.0, 1.0).toFloat()
}

/**
 * Beschriftungen ohne Bezug zu einem einzelnen Sparziel.
 *
 * Die Android-Ressourcen dienen nur noch als Rückfall für den Fall, dass
 * die App nach der Installation noch nie lief und deshalb nichts geliefert
 * hat.
 */
data class WidgetLabels(
    val pickGoal: String,
    val noData: String,
    val configTitle: String,
    val confirm: String,
    val cancel: String,
    val emptyTitle: String,
    val emptyBody: String,
    val openApp: String,
) {
    companion object {
        fun fromResources(context: Context) = WidgetLabels(
            pickGoal = context.getString(R.string.widget_hint_pick_goal),
            noData = context.getString(R.string.widget_hint_no_data),
            configTitle = context.getString(R.string.widget_config_title),
            confirm = context.getString(R.string.widget_config_confirm),
            cancel = context.getString(R.string.widget_config_cancel),
            emptyTitle = context.getString(R.string.widget_config_empty_title),
            emptyBody = context.getString(R.string.widget_config_empty_body),
            openApp = context.getString(R.string.widget_config_open_app),
        )

        fun parse(context: Context, json: JSONObject?): WidgetLabels {
            val fallback = fromResources(context)
            if (json == null) return fallback
            return WidgetLabels(
                pickGoal = json.optString("pickGoal").ifEmpty { fallback.pickGoal },
                noData = json.optString("noData").ifEmpty { fallback.noData },
                configTitle = json.optString("configTitle").ifEmpty { fallback.configTitle },
                confirm = json.optString("confirm").ifEmpty { fallback.confirm },
                cancel = json.optString("cancel").ifEmpty { fallback.cancel },
                emptyTitle = json.optString("emptyTitle").ifEmpty { fallback.emptyTitle },
                emptyBody = json.optString("emptyBody").ifEmpty { fallback.emptyBody },
                openApp = json.optString("openApp").ifEmpty { fallback.openApp },
            )
        }
    }
}

/** Sparziele und Beschriftungen, wie sie zuletzt aus der App kamen. */
data class WidgetData(val goals: List<WidgetGoal>, val labels: WidgetLabels)

/**
 * Ablage für alles, was das Homescreen-Widget wissen muss.
 *
 * Das Widget wird vom Launcher gezeichnet und hat weder Flutter noch die
 * SQLite-Datenbank der App zur Verfügung. Die App legt den aktuellen Stand
 * deshalb als JSON in SharedPreferences ab; dort liegt außerdem pro Widget-
 * Instanz das gewählte Sparziel.
 */
object WidgetGoalStore {
    private const val PREFS = "spartracker_widget"
    private const val KEY_PAYLOAD = "goals"
    private const val KEY_SELECTION_PREFIX = "selection_"

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** Übernimmt den von Flutter gesendeten Stand. */
    fun savePayload(context: Context, json: String) {
        prefs(context).edit().putString(KEY_PAYLOAD, json).apply()
    }

    /**
     * Sparziele und Beschriftungen.
     *
     * Die Liste ist leer, solange die App nach der Installation noch nie
     * lief - dafür zeigen Widget und Konfiguration einen eigenen Zustand.
     */
    fun data(context: Context): WidgetData {
        val raw = prefs(context).getString(KEY_PAYLOAD, null)
            ?: return WidgetData(emptyList(), WidgetLabels.fromResources(context))

        return runCatching { parse(context, raw) }
            .getOrElse { WidgetData(emptyList(), WidgetLabels.fromResources(context)) }
    }

    /** Das für diese Widget-Instanz gewählte Sparziel. */
    fun selectedGoalId(context: Context, appWidgetId: Int): Int? {
        val id = prefs(context).getInt(KEY_SELECTION_PREFIX + appWidgetId, -1)
        return if (id >= 0) id else null
    }

    fun setSelectedGoalId(context: Context, appWidgetId: Int, goalId: Int) {
        prefs(context).edit().putInt(KEY_SELECTION_PREFIX + appWidgetId, goalId).apply()
    }

    /** Räumt die Zuordnung auf, wenn ein Widget vom Homescreen fliegt. */
    fun clearSelection(context: Context, appWidgetId: Int) {
        prefs(context).edit().remove(KEY_SELECTION_PREFIX + appWidgetId).apply()
    }

    /** Lädt ein von Flutter gerendertes Symbol; `null`, wenn es fehlt. */
    fun loadIcon(path: String?): Bitmap? {
        if (path.isNullOrEmpty()) return null
        return runCatching { BitmapFactory.decodeFile(path) }.getOrNull()
    }

    private fun parse(context: Context, raw: String): WidgetData {
        val root = JSONObject(raw)
        val labels = WidgetLabels.parse(context, root.optJSONObject("labels"))
        val array = root.optJSONArray("goals")
            ?: return WidgetData(emptyList(), labels)

        val goals = (0 until array.length()).map { index ->
            val item = array.getJSONObject(index)
            WidgetGoal(
                id = item.getInt("id"),
                name = item.getString("name"),
                target = item.getDouble("target"),
                saved = item.getDouble("saved"),
                iconPath = item.optString("icon").ifEmpty { null },
                savedText = item.getString("savedText"),
                amountLine = item.getString("amountLine"),
                targetLine = item.getString("targetLine"),
                statusLine = item.getString("statusLine"),
                percentText = item.getString("percentText"),
                accent = DualColor(item.getInt("accentLight"), item.getInt("accentDark")),
                container = DualColor(item.getInt("containerLight"), item.getInt("containerDark")),
                onContainer = DualColor(
                    item.getInt("onContainerLight"),
                    item.getInt("onContainerDark"),
                ),
                track = DualColor(item.getInt("trackLight"), item.getInt("trackDark")),
            )
        }
        return WidgetData(goals, labels)
    }
}
