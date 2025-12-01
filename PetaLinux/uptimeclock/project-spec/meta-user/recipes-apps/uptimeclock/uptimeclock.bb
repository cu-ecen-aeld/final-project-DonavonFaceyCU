#
# This file is the uptimeclock recipe.
# It was generated using the petalinux-create command and modified by ChatGPT
#

SUMMARY = "Simple uptimeclock application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "libgpiod"
RDEPENDS:${PN} += "libgpiod"

SRC_URI = "file://uptimeclock.c \
           file://Makefile \
           file://uptimeclock-start-stop \
          "

S = "${WORKDIR}"

inherit update-rc.d

INITSCRIPT_NAME = "uptimeclock"
INITSCRIPT_PARAMS = "defaults 99"

do_compile() {
    oe_runmake
}

do_install() {
    # Install binary
    install -d ${D}${bindir}
    install -m 0755 uptimeclock ${D}${bindir}

    # Install SysV init script
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/uptimeclock-start-stop ${D}${sysconfdir}/init.d/uptimeclock
}

