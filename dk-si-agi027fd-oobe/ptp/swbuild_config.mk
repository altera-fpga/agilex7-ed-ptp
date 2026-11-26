################################################
#
# SPDX-License-Identifier: MIT-0
# SPDX-FileCopyrightText: Copyright (C) 2025 Altera Corporation
#
################################################
MACHINE_YML_PATH := software/yocto_linux/kas/machine.yml
BSP_YML_PATH := software/yocto_linux/kas/bsp.yml

# Extract MACHINE
KAS_MACHINE := $(shell grep -A 10 "machine:" $(MACHINE_YML_PATH) | grep "MACHINE" | sed -E 's/.*MACHINE = "([^"]+)".*/\1/')

# Extract LINUX_DTS_FILE (.dts)
KAS_LINUX_DTS_FILE := $(shell grep -A 10 "machine:" $(MACHINE_YML_PATH) | grep -E '^\s*LINUX_DTS_FILE\s*=' | sed -E 's/.*LINUX_DTS_FILE = "([^"]+)".*/\1/')

# Extract CUSTOM_LINUX_DTS_FILE (optional)
KAS_CUSTOM_LINUX_DTS_FILE := $(shell grep -A 10 "machine:" $(MACHINE_YML_PATH) | grep "CUSTOM_LINUX_DTS_FILE" | sed -E 's/.*CUSTOM_LINUX_DTS_FILE = "([^"]+)".*/\1/')

ifeq ($(strip $(KAS_MACHINE)),)
  $(error ERROR: MACHINE not found in $(MACHINE_YML_PATH))
endif

ifeq ($(strip $(KAS_LINUX_DTS_FILE)),)
  $(error ERROR: LINUX_DTS_FILE not found in $(MACHINE_YML_PATH))
endif

# Only convert .dts → .dtb if the variable is set
ifeq ($(strip $(KAS_CUSTOM_LINUX_DTS_FILE)),)
  KAS_CUSTOM_LINUX_DTB :=
else
  KAS_CUSTOM_LINUX_DTB := $(basename $(KAS_CUSTOM_LINUX_DTS_FILE)).dtb
endif

# Required DTS → DTB
KAS_LINUX_DTB := $(basename $(KAS_LINUX_DTS_FILE)).dtb

# Yocto deploy image path
KAS_YOCTO_IMAGE_DIR := software/yocto_linux/build/tmp/deploy/images/$(KAS_MACHINE)

ifeq ($(strip $(INSTALL_ROOT_BINARIES)),)
  $(error ERROR: INSTALL_ROOT_BINARIES was not defined before swconfig.mk was parsed)
endif

# Get the first revision name from REVISION_NAMES (defined in Makefile/project_config.mk)
REVISION := $(firstword $(REVISION_NAMES))

#
# Optional DTS installation files (so Make does not error when empty)
#
ifdef KAS_CUSTOM_LINUX_DTB
  YOCTO_SD_OPTIONAL_DTB   := $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/$(KAS_CUSTOM_LINUX_DTB)
else
  YOCTO_SD_OPTIONAL_DTB   :=
endif

###############################################################################
#                           Generic Targets
###############################################################################
# Create the core RBF files from the SOF files
output_files/%.core.rbf : output_files/%.sof
	quartus_pfg -c $< $@ -o hps=ON -o hps_core_only=ON

###############################################################################
#                           SW Build Targets
###############################################################################

# HPS Debug Software Build
###############################################################################
RBF_NAME := ghrd
PTP_CORE_RBF_FILENAME_10G       := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ.core.rbf
PTP_CORE_RBF_FILENAME_10G_ANLT  := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ_ANLT.core.rbf
PTP_CORE_RBF_FILENAME_25G       := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf
PTP_CORE_RBF_FILENAME_25G_ANLT  := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf
PTP_CORE_RBF_FILENAME_50G       := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ.core.rbf
PTP_CORE_RBF_FILENAME_50G_ANLT  := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ_ANLT.core.rbf
PTP_CORE_RBF_FILENAME_100G      := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf
PTP_CORE_RBF_FILENAME_100G_ANLT := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ_ANLT.core.rbf
PTP_CORE_RBF_FILENAME_DR        := agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P_MCQ_DR.core.rbf
PTP_CORE_RBF_FILENAME := $(PTP_CORE_RBF_FILENAME_$(PTP_DESIGN))
PTP_ARTIFACT_STEM := $(patsubst %.core.rbf,%,$(PTP_CORE_RBF_FILENAME))
ifeq ($(strip $(PTP_ARTIFACT_STEM)),)
PTP_ARTIFACT_STEM := $(REVISION)
endif
PTP_CORE_SOF_FILENAME := $(patsubst %.core.rbf,%.sof,$(PTP_CORE_RBF_FILENAME))
PTP_CORE_RBF_FILES_DIR := software/yocto_linux/meta-custom/recipes-fpga/fpga-bitstream/files

ifneq ($(strip $(PTP_CORE_RBF_FILENAME)),)
output_files/$(PTP_CORE_SOF_FILENAME):
	$(MAKE) --no-print-directory output_files/$(REVISION).sof
	cp -f output_files/$(REVISION).sof $@

output_files/$(PTP_CORE_RBF_FILENAME): output_files/$(PTP_CORE_SOF_FILENAME)
	quartus_pfg -c $< $@ -o hps=ON -o hps_core_only=ON
endif

# Only the full base revision(s) carry the HPS/SDM region. Exclude PR persona
# revisions (alternate_persona), whose partial SOF cannot take an HPS image.
HPS_DEBUG_REVISIONS := $(filter-out alternate_persona,$(REVISION_NAMES))

# Do not add HPS to the SW build target. Instead make it a part of the SOF install
# target. This is because other SW builds require this SOF
ifneq ($(strip $(PTP_CORE_RBF_FILENAME)),)
define create_hps_debug_targets_on_revisions
$(strip $(1))-install-sof : $(strip $(1))-install-core-rbf

.PHONY: $(strip $(1))-install-core-rbf
$(strip $(1))-install-core-rbf : output_files/$(PTP_CORE_RBF_FILENAME)  | $(INSTALL_ROOT_BINARIES)
	cp -f $$< output_files/ghrd.rbf
	cp -f $$< $(INSTALL_ROOT_BINARIES)/$(RBF_NAME).core.rbf
	@if [ -n "$(PTP_CORE_RBF_FILENAME)" ]; then \
		cp -f $$< $(INSTALL_ROOT_BINARIES)/$(PTP_CORE_RBF_FILENAME) && \
		cp -f $$< $(PTP_CORE_RBF_FILES_DIR)/$(PTP_CORE_RBF_FILENAME); \
	fi
endef
$(foreach revision,$(HPS_DEBUG_REVISIONS),$(eval $(call create_hps_debug_targets_on_revisions,$(revision))))
endif

# Yocto Linux Software Build for SD
###############################################################################
SW_YOCTO_LINUX_SD_TARGET := software-yocto_linux_sd
ALL_SW_TARGET_STEM_NAMES += $(SW_YOCTO_LINUX_SD_TARGET)

YOCTO_SD_IMAGE_DIR := $(KAS_YOCTO_IMAGE_DIR)
YOCTO_SD_WIC       := $(YOCTO_SD_IMAGE_DIR)/gsrd-console-image-$(KAS_MACHINE).rootfs.wic
YOCTO_SD_SPL_HEX   := $(YOCTO_SD_IMAGE_DIR)/u-boot-spl-dtb.hex

ifneq ($(strip $(PTP_CORE_SOF_FILENAME)),)
YOCTO_SD_INPUT_SOF := output_files/$(PTP_CORE_SOF_FILENAME)
else
YOCTO_SD_INPUT_SOF := output_files/$(REVISION).sof
endif
YOCTO_SD_POSTPROCESS_SOF := $(patsubst %.sof,%_yocto_linux_sd.sof,$(YOCTO_SD_INPUT_SOF))
YOCTO_SD_POSTPROCESS_SOF_NAME := $(notdir $(YOCTO_SD_POSTPROCESS_SOF))

# Single-design builds generate and stage selected core RBF before Yocto.
.PHONY: $(SW_YOCTO_LINUX_SD_TARGET)-build-sw
ifneq ($(strip $(PTP_CORE_RBF_FILENAME)),)
$(SW_YOCTO_LINUX_SD_TARGET)-build-sw : $(REVISION)-install-core-rbf
endif
$(SW_YOCTO_LINUX_SD_TARGET)-build-sw:
	cd software/yocto_linux && ./build.sh $(PTP_DESIGN) sd

#FSBL insertion into SOF
output_files/%_yocto_linux_sd.sof : output_files/%.sof $(YOCTO_SD_WIC)
	quartus_pfg -c -o hps_path=$(YOCTO_SD_SPL_HEX) $< $@

#Copy SOF files to install dir
$(INSTALL_ROOT_BINARIES)/%_yocto_linux_sd.sof : output_files/%_yocto_linux_sd.sof | $(INSTALL_ROOT_BINARIES)
	cp -f $< $@

#Create sdimage.tar.gz from the WIC
$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/sdimage.tar.gz: $(YOCTO_SD_WIC) | $(INSTALL_ROOT_BINARIES)
	mkdir -p $(dir $@)
	tar -chzf $@ -C $(dir $<) $(notdir $<)

# Create MD5 checksum
$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/sdimage.tar.gz.md5sum: \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/sdimage.tar.gz
	cd $(dir $@) && md5sum $(notdir $(basename $@)) > $(notdir $@)

#Copy Yocto artifacts to install dir
$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/%: $(YOCTO_SD_IMAGE_DIR)/% | $(INSTALL_ROOT_BINARIES)
	mkdir -p $(dir $@)
	cp -f $< $@

# Copy required files to artifacts directory
YOCTO_SD_ARTIFACT_FILES := \
	u-boot-spl \
	u-boot-spl.dtb \
	u-boot-spl.map \
	u-boot \
	u-boot.dtb \
	$(KAS_LINUX_DTB) \
	console-image-minimal-$(KAS_MACHINE).rootfs.cpio.gz.u-boot \
	gsrd-console-image-$(KAS_MACHINE).rootfs.cpio.gz.u-boot

$(INSTALL_ROOT_ARTIFACTS)/software/yocto_linux_sd/%: $(YOCTO_SD_IMAGE_DIR)/% | $(INSTALL_ROOT_ARTIFACTS)
	mkdir -p $(dir $@)
	cp -f $< $@

.PHONY: sd-postprocess
sd-postprocess: $(YOCTO_SD_POSTPROCESS_SOF)
	cp -f software/yocto_linux/scripts/* $(YOCTO_SD_IMAGE_DIR)
	cp -f $(YOCTO_SD_POSTPROCESS_SOF) $(YOCTO_SD_IMAGE_DIR)

	# run uboot script and quartus_pfg to generate uboot only JIC
	cd $(YOCTO_SD_IMAGE_DIR) && \
		./uboot_bin.sh && \
		cp $(YOCTO_SD_POSTPROCESS_SOF_NAME) ghrd.sof && \
		quartus_pfg -c qspi_helper.pfg && \
		quartus_pfg -c ghrd.sof $(PTP_ARTIFACT_STEM).jic -o device=MT25QU02G -o flash_loader=AGIB027R31B1E1VC -o hps_path=u-boot-spl-dtb.hex -o mode=ASX4 -o hps=1 && \
		quartus_pfg -o hps=ON -c -o hps_path=u-boot-spl-dtb.hex $(YOCTO_SD_POSTPROCESS_SOF_NAME) $(PTP_ARTIFACT_STEM).rbf

	mkdir -p $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd
	cp -f $(YOCTO_SD_IMAGE_DIR)/qspi_helper.pfg $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/uboot_bin.sh $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/u-boot.bin $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/u-boot-spl $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/qspi_helper.hps.jic $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/$(PTP_ARTIFACT_STEM).hps.jic $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/$(PTP_ARTIFACT_STEM).core.rbf $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/
	cp -f $(YOCTO_SD_IMAGE_DIR)/$(PTP_ARTIFACT_STEM).hps.rbf $(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/

# Clean target
.PHONY: $(SW_YOCTO_LINUX_SD_TARGET)-clean-sw
$(SW_YOCTO_LINUX_SD_TARGET)-clean-sw:
	cd software/yocto_linux && ./clean_build.sh

# Install target
.PHONY: $(SW_YOCTO_LINUX_SD_TARGET)-install-sw
$(SW_YOCTO_LINUX_SD_TARGET)-install-sw : \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/sdimage.tar.gz \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/sdimage.tar.gz.md5sum \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/console-image-minimal-$(KAS_MACHINE).rootfs.tar.gz \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/console-image-minimal-$(KAS_MACHINE).rootfs.manifest \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/gsrd-console-image-$(KAS_MACHINE).rootfs.tar.gz \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/gsrd-console-image-$(KAS_MACHINE).rootfs.manifest \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/Image \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/kernel.itb \
	$(YOCTO_SD_OPTIONAL_DTB) \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/u-boot-spl-dtb.bin \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/u-boot-spl-dtb.hex \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/boot.scr.uimg \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/u-boot.itb \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/u-boot.txt \
	$(INSTALL_ROOT_BINARIES)/software/yocto_linux_sd/uboot.env \
	$(INSTALL_ROOT_BINARIES)/$(YOCTO_SD_POSTPROCESS_SOF_NAME) \
	sd-postprocess \
	$(addprefix $(INSTALL_ROOT_ARTIFACTS)/software/yocto_linux_sd/, $(YOCTO_SD_ARTIFACT_FILES))
