## JamesDSP

System-wide JamesDSP integration for Android device trees. Ships the app, the
AIDL-native effect library (`libjamesdspaidl.so`, which exports the AIDL effect
C ABI `createEffect`/`queryEffect`/`destroyEffect`), the effect registration,
and the privileged-permission allowlist that unlocks Enhanced processing.

### AOSP-audio devices (the easy path)

If your device uses the stock AOSP audio effect config path
(`/vendor/etc/audio_effects_config.xml`), inherit the bundled config from your
**`device.mk`** or **`common.mk`**:

    # JamesDSP
    $(call inherit-product, vendor/JamesDSP/config.mk)

That pulls in everything automatically:

- `JamesDSP` app + `libjamesdspaidl` effect library
- the effect registration (`audio_effects_config.xml` → `/vendor/etc/`)
- `privileged: true` on the app + the DUMP privapp allowlist (Enhanced processing)

Nothing else to do.

### QTI / non-AOSP-audio devices (e.g. POCO F7 / Xiaomi "onyx", sm8735)

Qualcomm devices that run the QTI effect HAL (`libaudioeffecthal.qti.so`) do
**not** read `/vendor/etc/audio_effects_config.xml`. They read a per-SKU config,
e.g. `/vendor/etc/audio/sku_tuna/audio_effects_config.xml`, and that file is a
full QTI effect list (offload bundle, quasar, volume listener, …). So you must
**not** inherit `config.mk` on these devices — its generic effect config would
either be ignored, or worse, shadow the SKU config and break the QTI effects.

Wire it by hand instead:

**1. Do not inherit `config.mk`.** Add the pieces manually to `device.mk`:

    # JamesDSP (AIDL audio effect)
    PRODUCT_SOONG_NAMESPACES += \
        vendor/JamesDSP

    PRODUCT_PACKAGES += \
        JamesDSP \
        libjamesdspaidl

**2. Find the effect config your HAL actually reads.** On QTI trees it is the
copy landed at the SKU path, e.g. in `device.mk`:

    $(AUDIO_HAL_DIR)/configs/sun/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_tuna/audio_effects_config.xml \

(Confirm the live path with `adb shell getprop | grep -i effect` or by watching
`logcat` for the factory loading its config at boot.)

**3. Register the effect in that config.** Copy the SKU config into your device
tree (e.g. `configs/audio/audio_effects_config.xml`) and add the JamesDSP
library + effect. The QTI factory needs a **`type`** attribute to resolve the
effect type UUID, so include it:

    <libraries>
        ...
        <library name="jdsp" path="libjamesdspaidl.so"/>
    </libraries>

    <effects>
        ...
        <effect name="jamesdsp" library="jdsp"
                uuid="f27317f4-c984-4de6-9a90-545759495bf2"
                type="f98765f4-c321-5de6-9a45-123459495ab2"/>
    </effects>

Then repoint the SKU copy in `device.mk` to your patched file:

    $(LOCAL_PATH)/configs/audio/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_tuna/audio_effects_config.xml \

**4. Add the Enhanced-processing allowlist.** Since you skipped `config.mk`,
copy the privapp allowlist yourself so the privileged app is granted DUMP:

    PRODUCT_COPY_FILES += \
        vendor/JamesDSP/permissions/privapp-permissions-jamesdsp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-jamesdsp.xml

The app is built `privileged: true`, so this allowlist is **required** — a
privileged app requesting DUMP without an allowlist entry fails to boot on user
builds.

### Verifying

- Effect registered: `adb shell dumpsys media.audio_flinger | grep -i jamesdsp`,
  or check the app no longer reports "no driver found".
- Enhanced processing: it needs `android.permission.DUMP`. With the allowlist in
  place it is granted at build time. To test without a rebuild:

      adb shell pm grant james.dsp android.permission.DUMP

  (`DUMP` carries the `development` protection flag, so `pm grant` works. The
  grant persists until the app is reinstalled/updated.)

### Notes

- The installed package id is **`james.dsp`** (used for the allowlist and any
  `pm grant`).
- Legacy effect libraries that export only the old `AELI`
  (`audio_effect_library_t`) entry — e.g. ViPER4Android, or JamesDSP builds
  that ship a non-AIDL `libjamesdsp.so` — do **not** work on Android 16, which
  removed the legacy effect HAL. Use the AIDL library (`libjamesdspaidl.so`)
  shipped here.
