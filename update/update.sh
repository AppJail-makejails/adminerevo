#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/update.conf"

set -xe
set -o pipefail

cat -- "${BASEDIR}/Makejail.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%PHP_TAG%%/${PHP_TAG}/g" > "${BASEDIR}/../Makejail"

cat -- "${BASEDIR}/README.md.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%TAG2%%/${TAG2}/g" \
        -e "s/%%VERSION%%/${VERSION}/g" \
        -e "s/%%PHP_TAG%%/${PHP_TAG}/g" > "${BASEDIR}/../README.md"

cat -- "${BASEDIR}/install-adminerevo.makejail.template" |\
    sed -E \
        -e "s/%%VERSION%%/${VERSION}/g" > "${BASEDIR}/../install-adminerevo.makejail"
