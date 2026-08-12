package com.spartracker.spartracker.widget

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.LinearProgressIndicator
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle

/**
 * Breites Homescreen-Widget mit dem Stand eines Sparziels.
 *
 * Gestaltung nach Material 3: Der Rahmen übernimmt Hintergrund und Radius
 * des Systems ([GlanceTheme] liefert auf Android 12+ die Wallpaper-Farben),
 * die Akzente kommen aus der harmonisierten Farbe des Sparziels - genau die,
 * die auch die Karte in der App verwendet.
 */
class SavingsGoalWidget : GlanceAppWidget() {

    /**
     * Drei Ausbaustufen statt einer skalierten Fassung: Auf kleinen Größen
     * fällt der Name weg, auf großen kommen Betrag und Restsumme dazu.
     */
    override val sizeMode = SizeMode.Responsive(
        setOf(SIZE_SMALL, SIZE_MEDIUM, SIZE_LARGE),
    )

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
                    goal != null -> GoalContent(goal, icon)

                    // Die App lief nach der Installation noch nie.
                    data.goals.isEmpty() -> HintContent(
                        text = data.labels.noData,
                        intent = openAppIntent(context),
                    )

                    // Kein Ziel gewählt oder das gewählte wurde gelöscht.
                    else -> HintContent(
                        text = data.labels.pickGoal,
                        intent = configureWidgetIntent(context, appWidgetId),
                    )
                }
            }
        }
    }

    companion object {
        val SIZE_SMALL = DpSize(140.dp, 100.dp)
        val SIZE_MEDIUM = DpSize(220.dp, 100.dp)
        val SIZE_LARGE = DpSize(220.dp, 170.dp)
    }
}

@Composable
private fun GoalContent(goal: WidgetGoal, icon: Bitmap?) {
    val context = LocalContext.current
    val size = LocalSize.current
    val showName = size.width >= SavingsGoalWidget.SIZE_MEDIUM.width
    val showDetails = size.height >= SavingsGoalWidget.SIZE_LARGE.height

    WidgetSurface(intent = openGoalIntent(context, goal.id)) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(16.dp)
                // Das Widget wird als *ein* Element vorgelesen - sonst hört
                // man Name, Beträge und Prozentzahl als lose Fragmente.
                .semantics {
                    contentDescription =
                        "${goal.name}, ${goal.amountLine}, ${goal.statusLine}"
                },
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                GoalIconBadge(goal, icon)

                if (showName) {
                    Spacer(GlanceModifier.width(12.dp))
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        // md.sys.typescale.title-medium
                        Text(
                            text = goal.name,
                            maxLines = 1,
                            style = TextStyle(
                                color = GlanceTheme.colors.onSurface,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Medium,
                            ),
                        )
                        if (!showDetails) {
                            // md.sys.typescale.body-small
                            Text(
                                text = goal.amountLine,
                                maxLines = 1,
                                style = TextStyle(
                                    color = GlanceTheme.colors.onSurfaceVariant,
                                    fontSize = 12.sp,
                                ),
                            )
                        }
                    }
                } else {
                    Spacer(GlanceModifier.defaultWeight())
                }

                Text(
                    text = goal.percentText,
                    maxLines = 1,
                    style = TextStyle(
                        color = dual(goal.accent),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
            }

            if (showDetails) {
                Spacer(GlanceModifier.height(12.dp))
                // md.sys.typescale.headline-small - der Betrag ist die
                // Kennzahl, auf die der Blick zuerst fallen soll.
                Text(
                    text = goal.savedText,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.onSurface,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )
                Text(
                    text = goal.targetLine,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.onSurfaceVariant,
                        fontSize = 12.sp,
                    ),
                )
            } else if (!showName) {
                Spacer(GlanceModifier.height(8.dp))
                Text(
                    text = goal.savedText,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.onSurface,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
            }

            Spacer(GlanceModifier.defaultWeight())

            LinearProgressIndicator(
                progress = goal.progress,
                modifier = GlanceModifier.fillMaxWidth().height(8.dp).cornerRadius(4.dp),
                color = dual(goal.accent),
                backgroundColor = dual(goal.track),
            )

            if (showDetails) {
                Spacer(GlanceModifier.height(8.dp))
                Text(
                    text = goal.statusLine,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.onSurfaceVariant,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
            }
        }
    }
}
