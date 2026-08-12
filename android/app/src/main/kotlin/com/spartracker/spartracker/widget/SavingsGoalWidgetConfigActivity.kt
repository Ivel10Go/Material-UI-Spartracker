package com.spartracker.spartracker.widget

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.LargeTopAppBar
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.spartracker.spartracker.R

/**
 * Widget-Einstellungen: Auswahl des Sparziels für eine Widget-Instanz.
 *
 * Android startet diesen Bildschirm beim Ablegen des Widgets und - weil im
 * Widget-Info `reconfigurable` gesetzt ist - später auch über "Einstellungen"
 * im Widget-Kontextmenü.
 */
class SavingsGoalWidgetConfigActivity : ComponentActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        appWidgetId = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        // Bricht der Nutzer ab, darf kein halbfertiges Widget stehen bleiben.
        setResult(RESULT_CANCELED, resultIntent())

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val data = WidgetGoalStore.data(this)
        val preselected = WidgetGoalStore.selectedGoalId(this, appWidgetId)
            ?: data.goals.firstOrNull()?.id

        setContent {
            WidgetConfigTheme {
                GoalPickerScreen(
                    goals = data.goals,
                    labels = data.labels,
                    initialSelection = preselected,
                    onConfirm = ::confirm,
                    onCancel = ::finish,
                    onOpenApp = ::openApp,
                )
            }
        }
    }

    private fun confirm(goalId: Int) {
        WidgetGoalStore.setSelectedGoalId(this, appWidgetId, goalId)
        // Beim erstmaligen Ablegen zeichnet Android das Widget ohnehin neu;
        // beim späteren Umkonfigurieren tut es das nicht - daher hier.
        SavingsGoalWidgetUpdater.update(this, appWidgetId)
        setResult(RESULT_OK, resultIntent())
        finish()
    }

    private fun openApp() {
        startActivity(openAppIntent(this))
        finish()
    }

    private fun resultIntent(): Intent =
        Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
}

/**
 * Material-3-Theme des Bildschirms.
 *
 * Auf Android 12+ kommen die Farben aus dem Wallpaper - dieselbe Quelle,
 * aus der sich auch das App-Theme speist.
 */
@Composable
private fun WidgetConfigTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val context = LocalContext.current

    val colorScheme = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
            if (dark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        dark -> darkColorScheme()
        else -> lightColorScheme()
    }

    MaterialTheme(colorScheme = colorScheme, content = content)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GoalPickerScreen(
    goals: List<WidgetGoal>,
    labels: WidgetLabels,
    initialSelection: Int?,
    onConfirm: (Int) -> Unit,
    onCancel: () -> Unit,
    onOpenApp: () -> Unit,
) {
    var selectedId by rememberSaveable { mutableStateOf(initialSelection) }
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        containerColor = MaterialTheme.colorScheme.surface,
        topBar = {
            LargeTopAppBar(
                title = { Text(labels.configTitle) },
                scrollBehavior = scrollBehavior,
            )
        },
        bottomBar = {
            if (goals.isNotEmpty()) {
                ActionBar(
                    labels = labels,
                    confirmEnabled = selectedId != null,
                    onConfirm = { selectedId?.let(onConfirm) },
                    onCancel = onCancel,
                )
            }
        },
    ) { insets ->
        if (goals.isEmpty()) {
            EmptyState(
                labels = labels,
                onOpenApp = onOpenApp,
                modifier = Modifier.fillMaxSize().padding(insets),
            )
            return@Scaffold
        }

        LazyColumn(
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = insets.calculateTopPadding() + 8.dp,
                bottom = insets.calculateBottomPadding() + 8.dp,
            ),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(goals, key = { it.id }) { goal ->
                GoalRow(
                    goal = goal,
                    selected = goal.id == selectedId,
                    onSelect = { selectedId = goal.id },
                )
            }
        }
    }
}

/** Ein Sparziel zur Auswahl - Symbol, Name, Betrag und Fortschritt. */
@Composable
private fun GoalRow(goal: WidgetGoal, selected: Boolean, onSelect: () -> Unit) {
    val dark = isSystemInDarkTheme()
    val accent = Color(if (dark) goal.accent.dark else goal.accent.light)
    val container = Color(if (dark) goal.container.dark else goal.container.light)
    val onContainer = Color(if (dark) goal.onContainer.dark else goal.onContainer.light)
    val track = Color(if (dark) goal.track.dark else goal.track.light)

    Card(
        onClick = onSelect,
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (selected) {
                MaterialTheme.colorScheme.secondaryContainer
            } else {
                MaterialTheme.colorScheme.surfaceContainerLow
            },
        ),
        modifier = Modifier
            .fillMaxWidth()
            // Die Karte wird als *ein* Element vorgelesen - sonst hört man
            // Name, Beträge und Prozentzahl als lose Fragmente.
            .semantics(mergeDescendants = true) {
                this.selected = selected
                contentDescription = "${goal.name}, ${goal.amountLine}, ${goal.percentText}"
            },
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            RadioButton(selected = selected, onClick = null)
            Spacer(Modifier.width(4.dp))

            Box(
                modifier = Modifier.size(40.dp).background(container, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                GoalIcon(goal, tint = onContainer)
            }

            Spacer(Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = goal.name,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(
                    text = goal.amountLine,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(Modifier.height(8.dp))
                LinearProgressIndicator(
                    progress = { goal.progress },
                    color = accent,
                    trackColor = track,
                    modifier = Modifier.fillMaxWidth().height(6.dp),
                )
            }

            Spacer(Modifier.width(12.dp))

            Text(
                text = goal.percentText,
                style = MaterialTheme.typography.titleMedium,
                color = accent,
            )
        }
    }
}

/** Symbol des Sparziels; fällt auf das Standardsymbol zurück. */
@Composable
private fun GoalIcon(goal: WidgetGoal, tint: Color) {
    val bitmap = remember(goal.iconPath) { WidgetGoalStore.loadIcon(goal.iconPath) }

    Icon(
        painter = if (bitmap != null) {
            BitmapPainter(bitmap.asImageBitmap())
        } else {
            painterResource(R.drawable.ic_widget_goal)
        },
        contentDescription = null,
        tint = tint,
        modifier = Modifier.size(22.dp),
    )
}

/** Abbrechen / Übernehmen, tonal abgesetzt über der Navigationsleiste. */
@Composable
private fun ActionBar(
    labels: WidgetLabels,
    confirmEnabled: Boolean,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
) {
    Surface(color = MaterialTheme.colorScheme.surfaceContainer) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.End,
        ) {
            TextButton(onClick = onCancel) { Text(labels.cancel) }
            Spacer(Modifier.width(8.dp))
            Button(onClick = onConfirm, enabled = confirmEnabled) {
                Text(labels.confirm)
            }
        }
    }
}

/** Es gibt noch keine Sparziele - hier hilft nur der Weg in die App. */
@Composable
private fun EmptyState(
    labels: WidgetLabels,
    onOpenApp: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_widget_goal),
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(48.dp),
        )
        Spacer(Modifier.height(16.dp))
        Text(
            text = labels.emptyTitle,
            style = MaterialTheme.typography.titleMedium,
        )
        Spacer(Modifier.height(8.dp))
        Text(
            text = labels.emptyBody,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.widthIn(max = 320.dp),
        )
        Spacer(Modifier.height(24.dp))
        FilledTonalButton(onClick = onOpenApp) { Text(labels.openApp) }
    }
}
