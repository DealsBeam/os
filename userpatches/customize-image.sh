#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
echo "Customizing $BOARD $BOARD_VENDOR"
#
# Default fixes
# Implement them to build script


# ⚡ Bolt: This script previously used multiple `rm` commands, spawning a new process for each file.
# By combining them into a single `find` command, we traverse the filesystem only once and use a single process,
# making it significantly more efficient for cleaning up APT sources.
echo "Remove MS and GH sources as we ship them via our repo"
find /etc/apt/sources.list.d/ \
  -name 'discord.list' -o \
  -name 'vscode.list' -o \
  -name 'githubcli.list' -o \
  -name 'oibaf-ubuntu-graphics-drivers-*.*' -o \
  -name 'xtradeb-ubuntu-apps-*.*' -o \
  -name 'liujianfeng1994-ubuntu-chromium-*.*' \
  -delete
[[ -f /etc/apt/preferences.d/99-neon-base-files ]] && rm -f /etc/apt/preferences.d/99-neon-base-files

# release based
	case $RELEASE in
		jammy)
			# your code here
			;;
	esac

} # Main

Main "$@"
