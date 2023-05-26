#!/usr/bin/env bash
# convert tar.gz to zip
function __bliman_post_installation_hook() {
	echo "POST: converting $binary_input to $zip_output"
	mkdir -p "$BLIMAN_DIR/tmp/out"
	/usr/bin/env tar zxvf "$binary_input" -C "${BLIMAN_DIR}/tmp/out"
	cd "${BLIMAN_DIR}/tmp/out"
	/usr/bin/env zip -r "$zip_output" .
}
