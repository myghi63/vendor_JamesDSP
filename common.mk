# Device-path-agnostic JamesDSP integration: the app, the AIDL effect library,
# and the privileged-permission allowlist that unlocks Enhanced processing (DUMP).
#
# Inherit this directly on devices that register the effect in a non-default
# audio_effects_config (e.g. Qualcomm/QTI per-SKU configs). AOSP-audio devices
# should inherit config.mk instead, which additionally copies the effect
# registration to the default /vendor/etc/audio_effects_config.xml path.

PRODUCT_SOONG_NAMESPACES += \
    vendor/JamesDSP

PRODUCT_PACKAGES += \
    JamesDSP \
    libjamesdspaidl

# Privileged-app permission allowlist: grant DUMP for Enhanced processing.
# default-permissions: pre-grant the runtime perms (RECORD_AUDIO,
# POST_NOTIFICATIONS) so nothing has to be granted by hand.
PRODUCT_COPY_FILES += \
	vendor/JamesDSP/permissions/privapp-permissions-jamesdsp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-jamesdsp.xml \
	vendor/JamesDSP/permissions/default-permissions-jamesdsp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions-jamesdsp.xml

# SystemConfig: exempt JamesDSP from Doze / app-standby (Unrestricted battery)
PRODUCT_COPY_FILES += \
	vendor/JamesDSP/sysconfig/jamesdsp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/jamesdsp.xml
