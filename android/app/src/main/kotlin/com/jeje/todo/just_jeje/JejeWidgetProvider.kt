package com.jeje.todo.just_jeje

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class JejeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.jeje_widget_layout).apply {
                // Pending intent to launch MainActivity when clicking the widget
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // 1. Try displaying rendered Flutter card image
                val imagePath = widgetData.getString("jeje_card_image", null)
                var hasRenderedImage = false

                if (!imagePath.isNullOrEmpty()) {
                    val imgFile = File(imagePath)
                    if (imgFile.exists()) {
                        val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath)
                        if (bitmap != null) {
                            setImageViewBitmap(R.id.widget_img_rendered, bitmap)
                            setViewVisibility(R.id.widget_img_rendered, View.VISIBLE)
                            setViewVisibility(R.id.widget_fallback_layout, View.GONE)
                            hasRenderedImage = true
                        }
                    }
                }

                // 2. If image is not rendered or file missing, display clean native fallback
                if (!hasRenderedImage) {
                    setViewVisibility(R.id.widget_img_rendered, View.GONE)
                    setViewVisibility(R.id.widget_fallback_layout, View.VISIBLE)

                    val groupTitle = widgetData.getString("widget_group_title", "JUST JEJE")
                    val summaryText = widgetData.getString("widget_tasks_summary", "To-Do List")
                    val task1 = widgetData.getString("widget_task_1", null)
                    val task2 = widgetData.getString("widget_task_2", null)
                    val task3 = widgetData.getString("widget_task_3", null)

                    setTextViewText(R.id.widget_title, groupTitle)
                    setTextViewText(R.id.widget_summary, summaryText)

                    if (!task1.isNullOrEmpty()) {
                        setTextViewText(R.id.widget_task_text_1, task1)
                        setViewVisibility(R.id.widget_task_row_1, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_task_row_1, View.GONE)
                    }

                    if (!task2.isNullOrEmpty()) {
                        setTextViewText(R.id.widget_task_text_2, task2)
                        setViewVisibility(R.id.widget_task_row_2, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_task_row_2, View.GONE)
                    }

                    if (!task3.isNullOrEmpty()) {
                        setTextViewText(R.id.widget_task_text_3, task3)
                        setViewVisibility(R.id.widget_task_row_3, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_task_row_3, View.GONE)
                    }
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
