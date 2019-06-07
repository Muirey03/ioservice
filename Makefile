GO_EASY_ON_ME = 1

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = ioservice
ioservice_FILES = $(wildcard *.mm *.m *.c)
ioservice_CODESIGN_FLAGS = -Sent.xml
ioservice_PRIVATE_FRAMEWORKS = IOKit
ioservice_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
