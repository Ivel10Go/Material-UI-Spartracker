package com.spartracker.spartracker.widget

import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.height
import androidx.glance.layout.size
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Kompaktes 2x2-Widget: nur das Sparziel, umringt vom Fortschritt.
 *
 * Gegenstück zum breiten [SavingsGoalWidget] - hier zählt der Blick aufs
 * Wesentliche, nicht die Zahlen. Symbol und Prozentwert stehen in der
 * Mitte, den Rest erzählt der Ring.
 */
class SavingsGoalRingWidget : GlanceAppWidget() {

    /**
     * Der Ring wird als Bitmap in der jeweils verfügbaren Größe gezeichnet,
     * deshalb braucht die Komposition die tatsächlichen Maße - nicht die
     * gerundeten Stufen von [SizeMode.Responsive].
     */
    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)

        provideContent {
            // Der Zähler ist der Auslöser: Wird er erhöht, läuft die
            // Komposition erneut und liest die Daten unten frisch ein
            // (siehe [WidgetRevisionKey]).
            val revision = currentState(WidgetRevisionKey) ?: 0

            val data = WidgetGoalStore.data(context)
            val selectedId = WidgetGoalStore.selectedGoalId(context, appWidgetId)
            val goal = data.goals.firstOrNull { it.id == selectedId }
            val icon = remember(revision, goal?.iconPath) {
                WidgetGoalStore.loadIcon(goal?.iconPath)
            }

            GlanceTheme {
                when {
                    goal != null -> RingContent(goal, icon)

                    data.goals.isEmpty() -> HintContent(
                        text = data.labels.noData,
                        intent = openAppIntent(context),
                    )

                    else -> HintContent(
                        text = data.labels.pickGoal,
                        intent = configureWidgetIntent(context, appWidgetId),
                    )
                }
            }
        }
    }
}

@Composable
private fun RingContent(goal: WidgetGoal, icon: Bitmap?) {
    val context = LocalContext.current
    val size = LocalSize.current
    // Anders als bei Farben, die als ColorProvider hell/dunkel mitbringen,
    // muss der gezeichnete Ring sich für eine Variante entscheiden.
    val night = context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
    val density = context.resources.displayMetrics.density

    // Der Ring füllt das Widget bis auf einen schmalen Rand.
    val diameterDp = (min(size.width.value, size.height.value) - 2 * EDGE_DP)
        .coerceAtLeast(MIN_DIAMETER_DP)
    val strokeDp = (diameterDp * STROKE_RATIO).coerceIn(6f, 14f)

    val ring = remember(diameterDp, strokeDp, goal.progress, goal.id, night) {
        ProgressRing.draw(
            sizePx = (diameterDp * density).roundToInt(),
            strokePx = strokeDp * density,
            density = density,
            progress = goal.progress,
            indicatorColor = if (night) goal.accent.dark else goal.accent.light,
            trackColor = if (night) goal.track.dark else goal.track.light,
        )
    }

    // Alles innerhalb des Rings skaliert mit dessen Durchmesser mit, damit
    // ein größer gezogenes Widget nicht plötzlich leer wirkt.
    val innerDp = diameterDp - 2 * strokeDp
    val iconDp = (innerDp * 0.30f).coerceIn(20f, 40f).roundToInt()
    val percentSp = (innerDp * 0.22f).coerceIn(16f, 32f)

    WidgetSurface(intent = openGoalIntent(context, goal.id)) {
        Box(
            // Das Widget wird als *ein* Element vorgelesen - Symbol und
            // Prozentzahl allein ergäben keinen brauchbaren Satz.
            modifier = GlanceModifier.semantics {
                contentDescription = "${goal.name}, ${goal.amountLine}, ${goal.statusLine}"
            },
            contentAlignment = Alignment.Center,
        ) {
            Image(
                provider = ImageProvider(ring),
                contentDescription = null,
                modifier = GlanceModifier.size(diameterDp.dp),
            )

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                GoalIcon(icon = icon, tint = dual(goal.accent), sizeDp = iconDp)
                Spacer(GlanceModifier.height(4.dp))
                Text(
                    text = goal.percentText,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.onSurface,
                        fontSize = percentSp.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
            }
        }
    }
}

/** Abstand zwischen Ring und Widget-Rand in dp. */
private const val EDGE_DP = 10f

/** Kleinster sinnvoller Ringdurchmesser in dp. */
private const val MIN_DIAMETER_DP = 72f

/** Strichstärke im Verhältnis zum Durchmesser. */
private const val STROKE_RATIO = 0.09f
