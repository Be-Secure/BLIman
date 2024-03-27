#!/bin/bash

function __bli_launchlab()
{
    if [[ "$BLIMAN_LAB_MODE" == "host" ]]; then
        __bliman_launch_host_mode
    elif [[ "$BLIMAN_LAB_MODE" == "bare" ]]; then
        __bliman_launch_bare_mode
    elif [[ "$BLIMAN_LAB_MODE" == "lite" ]]; then
        __bliman_launch_lite_mode
    fi
}


