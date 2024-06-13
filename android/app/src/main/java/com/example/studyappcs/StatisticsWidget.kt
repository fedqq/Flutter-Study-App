package com.example.studyappcs

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.icu.text.DateFormat
import android.util.Log
import android.widget.RemoteViews
import java.time.Instant
import java.util.Date
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Implementation of App Widget functionality.
 */
class StatisticsWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val data = HomeWidgetPlugin.getData(context)
    val date = data.getString("lastdate", "")
    val currentDate = android.text.format.DateFormat.format(DateFormat.YEAR_NUM_MONTH_DAY, Date.from(
        Instant.now()))
    var streak = 0
    streak = data.getInt("laststreak", 0)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.statistics_widget)
    views.setTextViewText(R.id.appwidget_text, "$streak days")

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}