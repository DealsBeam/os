function extension_prepare_config__docker() {
	EXTRA_IMAGE_SUFFIXES+=("-kali") # global array
	#VENDOR="Armbian_Security"
	HOST="armbian-security"
	display_alert "Target image will have Kali repository preinstalled" "${BOARD}:${RELEASE}-${BRANCH} :: ${EXTENSION}" "info"
}

function pre_customize_image__install_kali_packages(){
	display_alert "Adding gpg-key for Kali repository" "${BOARD}:${RELEASE}-${BRANCH} :: ${EXTENSION}" "info"
	run_host_command_logged curl --max-time 60 -4 -fsSL "https://archive.kali.org/archive-key.asc" "|" gpg --dearmor -o "${SDCARD}"/usr/share/keyrings/kali.gpg

	# Add sources.list
	if [[ "${DISTRIBUTION}" == "Debian" ]]; then
		display_alert "Adding sources.list for Kali." "${BOARD}:${RELEASE}-${BRANCH} :: ${EXTENSION}" "info"
		run_host_command_logged echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/kali.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" "|" tee "${SDCARD}"/etc/apt/sources.list.d/kali.list
		display_alert "Pinning Kali package versions to apt for consistency." "${BOARD}:${RELEASE}-${BRANCH} :: ${EXTENSION}" "info"
		run_host_command_logged cat <<- 'end' > "${SDCARD}"/etc/apt/preferences.d/kali
			Package: *
			Pin: release o=Kali
			Pin-Priority: 50
		end
	else
		exit_with_error "Unsupported distribution: ${DISTRIBUTION}"
	fi

	display_alert "Updating package lists with Kali Linux repos" "${BOARD}:${RELEASE}-${BRANCH} :: ${EXTENSION}" "info"
	do_with_retries 3 chroot_sdcard_apt_get_update

	# Optional preinstall top 10 tools
#	display_alert "Installing Top 10 Kali Linux tools" "${EXTENSION}" "info"
#	chroot_sdcard_apt_get_install kali-tools-top10
}

function post_customize_image__kali_tools() {
	display_alert "Adding Kali Linux profile package list show ${RELEASE}" "${EXTENSION}" "info"
	run_host_command_logged mkdir -p "${SDCARD}"/etc/armbian/
	run_host_command_logged cat <<- 'armbian-kali-motd' > "${SDCARD}"/etc/armbian/kali.sh
		#!/bin/bash
		#
		# Copyright (c) Authors: https://www.armbian.com/authors
		#
		echo -e "\n\e[0;92mAdditional security oriented packages you can install:\x1B[0m (sudo apt install kali-tools-package_name)\n"
		# ⚡ Bolt: Use `apt-cache search` and `comm` for a significant performance boost over the original `apt list | grep` pipeline.
		# This command efficiently finds all `kali-tools` packages and filters out any that are already installed.
		comm -23 <(apt-cache search --names-only kali-tools | cut -d' ' -f1 | sort) <(dpkg-query -W -f='${Package}\n' '*kali-tools*' 2>/dev/null | sort) | pr -2 -t
		echo ""
	armbian-kali-motd
	run_host_command_logged chmod +x "${SDCARD}"/etc/armbian/kali.sh
	run_host_command_logged echo ". /etc/armbian/kali.sh" >> "${SDCARD}"/etc/skel/.bashrc
	run_host_command_logged echo ". /etc/armbian/kali.sh" >> "${SDCARD}"/etc/skel/.zshrc
	run_host_command_logged echo ". /etc/armbian/kali.sh" >> "${SDCARD}"/root/.bashrc
}
