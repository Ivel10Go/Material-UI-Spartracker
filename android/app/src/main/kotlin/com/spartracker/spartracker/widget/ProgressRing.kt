package com.spartracker.spartracker.widget

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import kotlin.math.min

/**
 * Zeichnet einen determinierten Fortschrittsring nach Material 3.
 *
 * Glance bringt zwar einen `CircularProgressIndicator` mit, der kennt aber
 * keinen Fortschrittswert - er kann nur unbestimmt kreisen. Für den
 * bestimmten Ring bleibt deshalb nur, ihn selbst in eine Bitmap zu zeichnen
 * und als Bild einzusetzen.
 *
 * Die Form folgt dem aktuellen Material-3-Bild: runde Enden und eine Lücke
 * zwischen Indikator und Spur - genau der Look, den die App über
 * `ProgressIndicatorThemeData(year2023: false)` auch im Balken nutzt.
 */
object ProgressRing {

    /** Lücke zwischen Indikator und Spur in dp (`md.sys` sieht 4dp vor). */
    private const val GAP_DP = 4f

    /**
     * @param sizePx Kantenlänge der erzeugten quadratischen Bitmap.
     * @param strokePx Dicke von Indikator und Spur.
     * @param density Anzeigedichte, um [GAP_DP] in Pixel umzurechnen.
     */
    fun draw(
        sizePx: Int,
        strokePx: Float,
        density: Float,
        progress: Float,
        indicatorColor: Int,
        trackColor: Int,
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val inset = strokePx / 2f
        val bounds = RectF(inset, inset, sizePx - inset, sizePx - inset)
        val radius = bounds.width() / 2f

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = strokePx
            strokeCap = Paint.Cap.ROUND
        }

        val clamped = progress.coerceIn(0f, 1f)

        // Bei 0 % bzw. 100 % gibt es nur einen der beiden Bögen - dann wäre
        // eine Lücke sinnlos und die runden Enden würden störend hervorstehen.
        if (clamped <= 0f) {
            paint.color = trackColor
            canvas.drawArc(bounds, 0f, 360f, false, paint)
            return bitmap
        }
        if (clamped >= 1f) {
            paint.color = indicatorColor
            canvas.drawArc(bounds, 0f, 360f, false, paint)
            return bitmap
        }

        // Die runden Enden ragen um den halben Strich über den Bogen hinaus;
        // das kommt zur Lücke dazu, sonst berühren sie sich optisch.
        val gapPx = GAP_DP * density + strokePx
        val gapDeg = Math.toDegrees((gapPx / radius).toDouble()).toFloat()

        // Zwei Lücken (Anfang und Ende des Indikators) gehen vom Vollkreis ab.
        val usable = 360f - 2f * gapDeg
        val indicatorSweep = min(clamped * usable, usable)
        val trackSweep = usable - indicatorSweep

        // -90° = zwölf Uhr, im Uhrzeigersinn wachsend.
        paint.color = indicatorColor
        canvas.drawArc(bounds, START_ANGLE, indicatorSweep, false, paint)

        paint.color = trackColor
        canvas.drawArc(
            bounds,
            START_ANGLE + indicatorSweep + gapDeg,
            trackSweep,
            false,
            paint,
        )

        return bitmap
    }

    private const val START_ANGLE = -90f
}
