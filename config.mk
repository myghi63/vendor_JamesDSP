PRODUCT_SOONG_NAMESPACES += \
    vendor/JamesDSP

PRODUCT_PACKAGES += \
    JamesDSP \
    libjamesdspaidl

PRODUCT_COPY_FILES += \
	vendor/JamesDSP/proprietary/vendor/etc/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml

# Privileged-app permission allowlist: grant DUMP for Enhanced processing
PRODUCT_COPY_FILES += \
	vendor/JamesDSP/permissions/privapp-permissions-jamesdsp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-jamesdsp.xml
