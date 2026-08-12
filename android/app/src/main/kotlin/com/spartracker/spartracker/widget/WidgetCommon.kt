package com.spartracker.spartracker.widget

import android.content.Intent
import android.graphics.Bitmap
import androidx.compose.runtime.Composable
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.spartracker.spartracker.R

/**
 * Bausteine, die sich beide Homescreen-Widgets teilen.
 *
 * Material 3 kommt hier auf zwei Wegen zusammen: Der Rahmen nimmt über
 * [GlanceTheme] die Systemfarben (ab Android 12 aus dem Wallpaper), die
 * Akzente stammen aus der harmonisierten Farbe des jeweiligen Sparziels.
 */

/**
 * Zähler im Glance-Zustand, der eine Neuzusammensetzung erzwingt.
 *
 * Unsere Daten liegen in SharedPreferences, also außerhalb von Glance.
 * `GlanceAppWidget.update()` allein bewirkt damit nichts: Glance vergleicht
 * nur seinen eigenen Zustand und setzt bei Gleichstand nichts neu zusammen -
 * das Widget bliebe auf dem Stand vom Sitzungsbeginn stehen. Erhöht man
 * dagegen diesen Zähler, ändert sich der Glance-Zustand, die Komposition
 * läuft erneut und liest die Sparziele frisch ein.
 */
val WidgetRevisionKey = intPreferencesKey("revision")

/**
 * Wählt je nach Hell-/Dunkelmodus des Launchers den passenden Farbwert.
 *
 * Voll qualifiziert, weil der Name sonst mit dem gleichnamigen Typ aus
 * `androidx.glance.unit` kollidiert.
 */
fun dual(color: DualColor): ColorProvider =
    androidx.glance.color.ColorProvider(
        day = Color(color.light),
        night = Color(color.dark),
    )

/** Gemeinsamer Rahmen: Systemhintergrund, Systemradius, ein Tippziel. */
@Composable
fun WidgetSurface(
    intent: Intent,
    content: @Composable () -> Unit,
) {
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(GlanceTheme.colors.widgetBackground)
            // Entspricht `md.sys.shape.corner.extra-large` und zugleich dem
            // Radius, den Android 12+ für Widget-Hintergründe vorsieht.
            .cornerRadius(28.dp)
            .clickable(actionStartActivity(intent)),
        contentAlignment = Alignment.Center,
        content = { content() },
    )
}

/**
 * Symbol eines Sparziels.
 *
 * Die von Flutter gelieferte Grafik ist eine weiße Maske; die Farbe
 * entsteht erst hier und passt so zu Hell und Dunkel. Fehlt sie, springt
 * das Standardsymbol ein.
 */
@Composable
fun GoalIcon(icon: Bitmap?, tint: ColorProvider, sizeDp: Int) {
    Image(
        provider = if (icon != null) ImageProvider(icon) else ImageProvider(R.drawable.ic_widget_goal),
        contentDescription = null,
        colorFilter = ColorFilter.tint(tint),
        modifier = GlanceModifier.size(sizeDp.dp),
    )
}

/** Symbol auf tonaler Kreisfläche - wie auf der Karte in der App. */
@Composable
fun GoalIconBadge(goal: WidgetGoal, icon: Bitmap?, sizeDp: Int = 40) {
    Box(
        modifier = GlanceModifier
            .size(sizeDp.dp)
            .background(dual(goal.container))
            .cornerRadius((sizeDp / 2).dp),
        contentAlignment = Alignment.Center,
    ) {
        GoalIcon(icon = icon, tint = dual(goal.onContainer), sizeDp = sizeDp * 22 / 40)
    }
}

/** Zustand ohne anzeigbares Sparziel - führt zum passenden Bildschirm. */
@Composable
fun HintContent(text: String, intent: Intent) {
    WidgetSurface(intent = intent) {
        Column(
            modifier = GlanceModifier.fillMaxSize().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            GoalIcon(icon = null, tint = GlanceTheme.colors.onSurfaceVariant, sizeDp = 24)
            Spacer(GlanceModifier.height(8.dp))
            Text(
                text = text,
                maxLines = 3,
                style = TextStyle(
                    color = GlanceTheme.colors.onSurfaceVariant,
                    fontSize = 14.sp,
                    textAlign = TextAlign.Center,
                ),
            )
        }
    }
}
