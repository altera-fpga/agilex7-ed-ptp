
THIS_MK_ABSPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MK_DIR := $(dir $(THIS_MK_ABSPATH))

# Enable pipefail for all commands
SHELL=/bin/bash -o pipefail

# Enable second expansion
.SECONDEXPANSION:

# Clear all built in suffixes
.SUFFIXES:

NOOP :=
SPACE := $(NOOP) $(NOOP)
COMMA := ,
HOSTNAME := $(shell hostname)
export PATH := $(PATH):/usr/sbin

##############################################################################
# Environment check
##############################################################################


##############################################################################
# Configuration
##############################################################################
PROJECT_DIR_ABS := $(abspath $(THIS_MK_DIR))

# Name of all the revisions
PROJECT_NAME :=
REVISION_NAMES :=

# Set defaults
INSTALL_ROOT_BINARIES ?= $(THIS_MK_DIR)/install/binaries
INSTALL_ROOT_DESIGNS ?= $(THIS_MK_DIR)/install/designs
INSTALL_ROOT_ARTIFACTS ?= $(THIS_MK_DIR)/install/artifacts

include $(THIS_MK_DIR)/project_config.mk
ifeq ($(PROJECT_NAME),)
$(error PROJECT_NAME is not defined in project_config.mk)
endif
ifeq ($(REVISION_NAMES),)
$(error REVISION_NAMES is not defined in project_config.mk)
endif
ARCHIVE_NAME ?= $(PROJECT_NAME)

# Hardware is compiled by synth/Makefile; PTP_DESIGN selects both HW and SW variants
SYNTH_DIR := $(PROJECT_DIR_ABS)/synth
SYNTH_REVISION := top
PTP_DESIGN ?= 25G_ANLT

# All rate variants (NON_ANLT + ANLT + DR) for PTP_DESIGN=ALL
PTP_DESIGN_LIST_ALL := 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR

SYNTH_CONFIG_10G       := 10G_NON_ANLT
SYNTH_CONFIG_25G       := 25G_NON_ANLT
SYNTH_CONFIG_50G       := 50G_NON_ANLT
SYNTH_CONFIG_100G      := 100G_NON_ANLT
SYNTH_CONFIG_10G_ANLT  := 10G_ANLT
SYNTH_CONFIG_25G_ANLT  := 25G_ANLT
SYNTH_CONFIG_50G_ANLT  := 50G_ANLT
SYNTH_CONFIG_100G_ANLT := 100G_ANLT
SYNTH_CONFIG_DR        := 10G_25G_NON_ANLT_DR
SYNTH_CONFIG := $(SYNTH_CONFIG_$(PTP_DESIGN))

# Set constants
INSTALL_RPT_NAMES := ipgen.rpt
ifneq ($(USE_ELAB_ONLY_FLOW),1)
INSTALL_RPT_NAMES += \
	syn.rpt \
	fit.rpt \
	sta.rpt \
	asm.rpt \
	pow.rpt \
	flow.rpt \
	tq.drc.signoff.rpt
endif

##############################################################################
# Set default goal before any targets. The default goal here is "test"
##############################################################################
DEFAULT_TARGET := test

.DEFAULT_GOAL := default
.PHONY: default
default: $(DEFAULT_TARGET)


##############################################################################
# Makefile starts here
##############################################################################

# Initialize variables
ALL_TARGET_STEM_NAMES =
ALL_SW_TARGET_STEM_NAMES =
ALL_BUILD_TARGETS =
ALL_SW_BUILD_TARGETS =
ALL_SW_CLEAN_TARGETS =
ALL_SW_INSTALL_TARGETS =
ALL_TEST_TARGETS =
ALL_INSTALL_TARGETS =

# Define function to create targets
define create_targets_on_revisions
ALL_TARGET_STEM_NAMES += $(strip $(1))
ALL_BUILD_TARGETS += $(addsuffix -build,$(strip $(1)))
ALL_TEST_TARGETS += $(addsuffix -test,$(strip $(1)))
ALL_INSTALL_TARGETS += $(addsuffix -install,$(strip $(1)))

$(strip $(1))-package-design : $(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip

$(strip $(1))-build : synth-check-config
	rm -f output_files/$(strip $(1)).synth-*.done
	$(MAKE) --no-print-directory output_files/$(strip $(1)).sof

$(strip $(1))-build-sw :

$(strip $(1))-test : $(strip $(1))-build

$(strip $(1))-install-sw: | $(INSTALL_ROOT_BINARIES)

$(strip $(1))-install: $(strip $(1))-install-sof $(strip $(1))-install-rpt $(strip $(1))-install-sw

$(strip $(1))-install-sof : output_files/$(strip $(1)).sof | $(INSTALL_ROOT_BINARIES)
	cp output_files/$(strip $(1)).sof $(INSTALL_ROOT_BINARIES)/$(strip $(1)).sof

$(strip $(1))-install-rpt: output_files/$(strip $(1))-install-rpt.done

output_files/$(strip $(1))-install-rpt.done : output_files/$(strip $(1)).sof | $(INSTALL_ROOT_ARTIFACTS) output_files
	for rpt in $(addprefix output_files/$(strip $(1)).,$(INSTALL_RPT_NAMES)); do \
		if [ -f $$$$rpt ]; then \
			cp -f $$$$rpt $(INSTALL_ROOT_ARTIFACTS)/ && \
			gzip -f $(INSTALL_ROOT_ARTIFACTS)/$$$$(basename $$$$rpt); \
		fi; \
	done
	touch $$@

endef

# Create all targets
$(foreach revision,$(REVISION_NAMES),$(eval $(call create_targets_on_revisions,$(revision))))

# GHRD-style public stem aliases (MAKE_STEM in project_config.mk)
ifneq ($(MAKE_STEM),)
.PHONY: $(MAKE_STEM)-all $(MAKE_STEM)-build $(MAKE_STEM)-software-yocto_linux_sd-build-sw \
	$(MAKE_STEM)-install $(MAKE_STEM)-install-core-rbf
ifeq ($(PTP_DESIGN),ALL)
# Build every rate (HW and/or SW) when PTP_DESIGN=ALL
$(MAKE_STEM)-build : build-all-ptp-hw
$(MAKE_STEM)-software-yocto_linux_sd-build-sw : build-all-ptp-sw
$(MAKE_STEM)-all : build-all-ptp-all
$(MAKE_STEM)-install : $(BASE_REVISION)-install
$(MAKE_STEM)-install-core-rbf : $(BASE_REVISION)-install-core-rbf
else
$(MAKE_STEM)-all : $(BASE_REVISION)-build software-yocto_linux_sd-build-sw
$(MAKE_STEM)-build : $(BASE_REVISION)-build
$(MAKE_STEM)-software-yocto_linux_sd-build-sw : software-yocto_linux_sd-build-sw
$(MAKE_STEM)-install : $(BASE_REVISION)-install
$(MAKE_STEM)-install-core-rbf : $(BASE_REVISION)-install-core-rbf
endif
endif

# Iterate all PTP_DESIGN values (used by PTP_DESIGN=ALL)
.PHONY: build-all-ptp-hw build-all-ptp-sw build-all-ptp-all
build-all-ptp-hw:
	@for d in $(PTP_DESIGN_LIST_ALL); do \
		echo "======== HW PTP_DESIGN=$$d ========"; \
		$(MAKE) $(BASE_REVISION)-build PTP_DESIGN=$$d || exit 1; \
		cp -f output_files/$(BASE_REVISION).sof output_files/$(BASE_REVISION)-$$d.sof; \
		echo "Saved output_files/$(BASE_REVISION)-$$d.sof"; \
	done

# One Yocto build produces all kernel_sed_PTP_*.itb (SOLUTION=PTP_ALL in linux bbappend).
# Do NOT loop per rate — that re-runs full bitbake ~9x.
build-all-ptp-sw:
	@echo "======== SW PTP_DESIGN=PTP_ALL (single Yocto build, all ITBs) ========"
	$(MAKE) software-yocto_linux_sd-build-sw PTP_DESIGN=PTP_ALL

build-all-ptp-all:
	@$(MAKE) build-all-ptp-hw
	@$(MAKE) build-all-ptp-sw

###############################################################################
#                          UTILITY TARGETS
###############################################################################

output_files $(INSTALL_ROOT_BINARIES) $(INSTALL_ROOT_DESIGNS) $(INSTALL_ROOT_ARTIFACTS):
	mkdir -p $@

$(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip: | $(INSTALL_ROOT_DESIGNS)
 	# Add root README.md first so quartus_sh create_metadata always picks it up before any nested README.md files.
	zip $@ README.md
	zip -r -g $@ * -x .gitignore "output_files/*" "qdb/*" "dni/*" "tmp-clearbox/*" "README.md"

.PHONY: package-design
package-design: $(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip

# Support restoring the SOF from the install directory to support
# building the SW outside of building the FPGA design
ifneq ($(RESTORE_INSTALL),1)
.PRECIOUS: output_files/%.synth-$(SYNTH_CONFIG).done

output_files/%.sof: output_files/%.synth-$(SYNTH_CONFIG).done
	@test -f $@ || (echo "Error: $@ not found after synth build!" && exit 1)

# The .done stamp name carries SYNTH_CONFIG so changing PTP_DESIGN forces a rebuild
output_files/%.synth-$(SYNTH_CONFIG).done: | synth-check-config output_files
	$(MAKE) -C $(SYNTH_DIR) all CONFIG=$(SYNTH_CONFIG)
	rm -f output_files/$*.synth-*.done
	touch $@
	cp -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).sof output_files/$*.sof
	for rpt in $(INSTALL_RPT_NAMES); do \
		if [ -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).$$rpt ]; then \
			cp -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).$$rpt output_files/$*.$$rpt; \
		fi; \
	done
else
output_files/%.sof: $(INSTALL_ROOT_BINARIES)/%.sof
	mkdir -p $(dir $@)
	cp $< $@
	@test -f $@ && echo "$@ found after restore!" || (echo "Error: $@ not found after restore!" && exit 1)
endif

# Clean all files
.PHONY: clean
clean : clean-sw
	rm -rf output_files qdb tmp-clearbox dni
ifneq ($(QUARTUS_ROOTDIR),)
	$(MAKE) -C $(SYNTH_DIR) clean
endif

.PHONY: synth-check-config
synth-check-config:
ifeq ($(PTP_DESIGN),ALL)
	@echo "Error: PTP_DESIGN=ALL is only valid on public targets:"
	@echo "  make $(MAKE_STEM)-build PTP_DESIGN=ALL"
	@echo "  make $(MAKE_STEM)-all PTP_DESIGN=ALL"
	@echo "  make $(MAKE_STEM)-software-yocto_linux_sd-build-sw PTP_DESIGN=ALL   # -> one PTP_ALL Yocto build"
	@exit 1
else ifeq ($(SYNTH_CONFIG),)
	@echo "Error: unsupported PTP_DESIGN='$(PTP_DESIGN)'"
	@echo "Valid: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR ALL"
	@exit 1
else
	@echo "PTP_DESIGN=$(PTP_DESIGN) -> Configuration=$(SYNTH_CONFIG)"
endif

# Deep clean using git
.PHONY: dev-clean
dev-clean : clean
	git clean -dfx .

# Build all revisions
.PHONY: build
build : $(ALL_BUILD_TARGETS)

# Run all tests
.PHONY: test
test : $(ALL_TEST_TARGETS)

# Install binaries and designs
.PHONY: install
install : $(ALL_INSTALL_TARGETS)

.PHONY: print-targets
print-targets:
	$(info $(ALL_TARGET_STEM_NAMES))

###############################################################################
#                           SW Build Targets
###############################################################################
-include $(THIS_MK_DIR)/swbuild_config.mk
ALL_SW_BUILD_TARGETS += $(addsuffix -build-sw, $(ALL_SW_TARGET_STEM_NAMES))
ALL_SW_CLEAN_TARGETS += $(addsuffix -clean-sw, $(ALL_SW_TARGET_STEM_NAMES))
ALL_SW_INSTALL_TARGETS += $(addsuffix -install-sw, $(ALL_SW_TARGET_STEM_NAMES))

# Build all SW projects
.PHONY: build-sw
build-sw : $(ALL_SW_BUILD_TARGETS)

.PHONY: clean-sw
clean-sw: $(ALL_SW_CLEAN_TARGETS)

.PHONY: install-sw
install-sw: $(ALL_SW_INSTALL_TARGETS)

.PHONY: print-sw-targets
print-sw-targets:
	$(info $(ALL_SW_TARGET_STEM_NAMES))


###############################################################################
#                                HELP
###############################################################################
.PHONY: help
help:
	@echo "Agilex 7 PTP SED build ($(MAKE_STEM))"
	@echo ""
	@echo "Usage:"
	@echo "  make [target] PTP_DESIGN=<design>"
	@echo ""
	@echo "PTP_DESIGN selects both hardware and software (same name in synth/ and Yocto)."
	@echo "  Default: $(PTP_DESIGN)  ->  Configuration=$(SYNTH_CONFIG)"
	@echo "  Valid:   10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR ALL"
	@echo "  Mapping: 10G/25G/50G/100G -> *_NON_ANLT; DR -> 10G_25G_NON_ANLT_DR"
	@echo "  ALL:     $(PTP_DESIGN_LIST_ALL)"
	@echo ""
	@echo "Public targets:"
	@echo "  $(MAKE_STEM)-build"
	@echo "      Hardware only: make -C synth all CONFIG=\$$(SYNTH_CONFIG), then copy"
	@echo "      synth/output_files/top.sof -> output_files/$(BASE_REVISION).sof"
	@echo "  $(MAKE_STEM)-software-yocto_linux_sd-build-sw"
	@echo "      Software only: software/yocto_linux/build.sh \$$(PTP_DESIGN) sd"
	@echo "  $(MAKE_STEM)-all"
	@echo "      Hardware then software (same PTP_DESIGN for both)"
	@echo "  $(MAKE_STEM)-install"
	@echo "      Install SOF, reports, and software artifacts under install/"
	@echo "  $(MAKE_STEM)-install-core-rbf"
	@echo "      Build SOF if needed, then quartus_pfg core RBF -> install/binaries/"
	@echo ""
	@echo "Common targets:"
	@echo "  build / $(BASE_REVISION)-build   Hardware compile (same as *-build)"
	@echo "  test                            Same as build (default goal)"
	@echo "  build-sw                        All software build targets"
	@echo "  install / install-sw            Install hardware / software artifacts"
	@echo "  clean                           Clean Yocto + output_files (+ synth if Quartus set)"
	@echo "  package-design                  Zip design sources to install/designs/"
	@echo "  help                            Show this message"
	@echo ""
	@echo "Examples:"
	@echo "  make $(MAKE_STEM)-build PTP_DESIGN=100G"
	@echo "  make $(MAKE_STEM)-software-yocto_linux_sd-build-sw PTP_DESIGN=100G"
	@echo "  make $(MAKE_STEM)-all PTP_DESIGN=25G_ANLT"
	@echo "  make $(MAKE_STEM)-all PTP_DESIGN=ALL"
	@echo "  make $(MAKE_STEM)-build PTP_DESIGN=ALL"
	@echo "  make $(MAKE_STEM)-install-core-rbf PTP_DESIGN=100G"
	@echo ""
	@echo "Project directory : $(PROJECT_DIR_ABS)"
	@echo "Synth directory   : $(SYNTH_DIR)"
	@echo "HW build targets  : $(ALL_BUILD_TARGETS)"
	@echo "HW install targets: $(ALL_INSTALL_TARGETS)"
	@echo "SW build targets  : $(ALL_SW_BUILD_TARGETS)"
	@echo "SW install targets: $(ALL_SW_INSTALL_TARGETS)"
