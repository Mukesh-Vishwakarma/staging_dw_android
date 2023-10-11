package com.mishry.revuer

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.revuer.feed";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            val argument = call.arguments as Map<*, *>
            val message = argument["msg"]
            val type = argument["type"]
            val path = argument["path"]
            if (call.method == "facebook") {
                uploadFbFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }else if (call.method == "instagram") {
                uploadInstagramFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }else if (call.method == "twitter") {
                uploadTwitterFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }else if (call.method == "youtube") {
                uploadYoutubeFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }else if (call.method == "linkedin") {
                uploadLinkedinFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }else if (call.method == "pinterest") {
                uploadPinterestFeed(type.toString(), path.toString())
                // Toast.makeText( this, message.toString(), Toast.LENGTH_LONG).show()
            }
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadYoutubeFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.google.android.youtube")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(context, context.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.google.android.youtube")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.google.android.youtube")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Youtube is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadTwitterFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.twitter.android")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(context, context.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.twitter.android")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.twitter.android")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Twitter is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadLinkedinFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.linkedin.android")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(context, context.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.linkedin.android")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.linkedin.android")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Linkedin is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadPinterestFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.pinterest")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(context, context.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.pinterest")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.pinterest")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Pinterest is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadInstagramFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.instagram.android")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(context, context.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.instagram.android")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.instagram.android")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Instagram App is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    fun uploadFbFeed(type: String, mediaPath: String) {
        val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses("com.facebook.katana")

        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = type
        val media = File(mediaPath)
        val uri = FileProvider.getUriForFile(this, this.packageName + ".provider", media)
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri) // set uri
        shareIntent.setPackage("com.facebook.katana")
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (appInstalledOrNot("com.facebook.katana")) {
            ContextCompat.startActivity(context, shareIntent, null)
        } else {
            Toast.makeText(
                context,
                "Facebook App is not installed",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    private fun appInstalledOrNot(packageName:String): Boolean {
        var app_installed = false
        app_installed = try {
            /*if (clickType == 1) {
                val info: ApplicationInfo =
                    context.packageManager.getApplicationInfo("com.instagram.android", 0)
            } else if (clickType == 1) {

            }
*/
            val info: ApplicationInfo =
                this.packageManager.getApplicationInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
        return app_installed
    }

}
