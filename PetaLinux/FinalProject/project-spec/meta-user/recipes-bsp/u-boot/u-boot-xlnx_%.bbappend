FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://platform-top.h file://bsp.cfg"
SRC_URI += "file://user_2025-11-09-06-19-00.cfg \
            file://user_2025-11-09-07-22-00.cfg \
            "

