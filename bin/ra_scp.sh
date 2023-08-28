#!/bin/bash

function do_scp {
    scp -i ${userpath}/${useridentity} -o ProxyJump=${username}@qaspvpilnxjmp01 "${username}@${hostname}:${1}" "${2}"
}