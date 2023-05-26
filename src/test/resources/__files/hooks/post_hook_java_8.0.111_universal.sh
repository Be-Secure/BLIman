#!/usr/bin/env bash
# passthrough used for zip binaries
function __bliman_post_installation_hook() {
	echo "POST: passthrough $binary_input to $zip_output"
	mv -f "$binary_input" "$zip_output"
}
