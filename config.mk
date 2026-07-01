# AOSP-audio devices: everything in common.mk (app, effect library, Enhanced
# processing allowlist) plus the effect registration at the default path
# /vendor/etc/audio_effects_config.xml.
#
# QTI / non-AOSP-audio devices must NOT inherit this: the generic effect config
# below would either be ignored or shadow the per-SKU config. Inherit common.mk
# instead and register the effect in the device's own SKU config (see README).

$(call inherit-product, vendor/JamesDSP/common.mk)

PRODUCT_COPY_FILES += \
	vendor/JamesDSP/proprietary/vendor/etc/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml
