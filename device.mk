#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/tecno/TECNO_LE7x

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Enable APEX updating
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Virtual A/B
ENABLE_VIRTUAL_AB := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Configure compression
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_retrofit.mk)

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    system \
    vendor \
    product \
    system_ext \
    boot \
    vbmeta_vendor \
    vbmeta_system

# Virtual A/B OTA
PRODUCT_VIRTUAL_AB_OTA := true
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.enabled=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

# MTK PlPath Utils
PRODUCT_PACKAGES += \
    mtk_plpath_utils \
    mtk_plpath_utils.recovery

# Set VNDK & API level
PRODUCT_TARGET_VNDK_VERSION := 30
PRODUCT_SHIPPING_API_LEVEL := 30

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.security_patch=2099-12-31

# Health Hal
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.1-mtkimpl.recovery \
    android.hardware.boot@1.1-mtkimpl

PRODUCT_PACKAGES_DEBUG += \
    bootctrl \
    update_engine_client

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

#OTA related
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

#KeyMaster (KeyMint) related
PRODUCT_PACKAGES += \
    keystore2 \
    libpuresoftkeymasterdevice \
    libpuresoftkeymasterdevice.recovery

# Additional binaries & libraries
TARGET_RECOVERY_DEVICE_MODULES += \
    libgatekeeper \
    libgatekeeper_aidl \
    libkeymaster41 \

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libgatekeeper.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libgatekeeper_aidl.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster41.so \

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
