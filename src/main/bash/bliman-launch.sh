#!/bin/bash

function __bli_launch()
{
    if [[ "$BLIMAN_LAB_MODE" == "host" ]]; then
        __bliman_launch_host_mode
    elif [[ "$BLIMAN_LAB_MODE" == "bare" ]]; then
        __bliman_launch_bare_mode
    elif [[ "$BLIMAN_LAB_MODE" == "light" ]]; then
        __bliman_launch_light_mode
    fi



}


