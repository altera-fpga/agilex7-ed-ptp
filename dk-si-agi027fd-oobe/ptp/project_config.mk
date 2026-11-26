# Define the Quartus project name
PROJECT_NAME := top

#Define the Quartus revision names
REVISION_NAMES := \
	baseline \

# Define the base revision
BASE_REVISION := $(firstword $(REVISION_NAMES))

MAKE_STEM := dk-si-agi027fd-oobe-baseline-ptp
