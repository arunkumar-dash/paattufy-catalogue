package com.paattufy.paattufy_native

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * `paattufy/icon_switch` — runtime launcher-icon swap (AP §3.7b, TP §5.8).
 *
 * Android cannot change an app's icon bitmap at runtime, so the app manifest
 * ships one `<activity-alias>` per colourway (IconAlias0..8), all pointing at
 * MainActivity with different icons. Exactly one is enabled; switching means
 * disabling the old alias and enabling the new one. The launcher may take a
 * moment to refresh — an OS-level quirk, not a bug.
 */
class IconSwitchChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    init {
        MethodChannel(messenger, PaattufyChannelNames.ICON_SWITCH).setMethodCallHandler(this)
    }

    private fun alias(i: Int) = ComponentName(context.packageName, "com.paattufy.music.IconAlias$i")

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "current" -> result.success(current())
            "set" -> {
                val variant = call.argument<Number>("variant")?.toInt()
                if (variant == null || variant !in 0 until VARIANTS) {
                    result.error("bad_args", "variant 0..${VARIANTS - 1}", null)
                    return
                }
                result.success(set(variant))
            }
            else -> result.notImplemented()
        }
    }

    private fun current(): Int {
        val pm = context.packageManager
        for (i in 0 until VARIANTS) {
            val state = pm.getComponentEnabledSetting(alias(i))
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return i
            // Default-state alias 0 counts as enabled when nothing else is.
            if (i == 0 && state == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) {
                val anyOther = (1 until VARIANTS).any {
                    pm.getComponentEnabledSetting(alias(it)) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                }
                if (!anyOther) return 0
            }
        }
        return 0
    }

    private fun set(variant: Int): Boolean {
        val pm = context.packageManager
        return try {
            // Enable the new alias first so there is never a moment with no launcher entry.
            pm.setComponentEnabledSetting(
                alias(variant), PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
            )
            for (i in 0 until VARIANTS) {
                if (i != variant) pm.setComponentEnabledSetting(
                    alias(i), PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP
                )
            }
            true
        } catch (_: Throwable) {
            false
        }
    }

    companion object {
        const val VARIANTS = 9
    }
}
