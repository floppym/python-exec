#!/bin/sh

if [ ${#} -ne 2 ]; then
	echo "Usage: ${0} <python-impls> <test-script>"
	exit 1
fi

# automake codes
SKIP=77
ERROR=99

# common metadata
PYTHON_IMPLS=${1}
TEST=${2}
TEST_DIR=tests
TEST_NAME=${2##*/}
TEST_TMP=${TEST_NAME}.tmp

# helper functions
write_impl() {
	mkdir -p "${TEST_DIR}/${1}" && \
	echo "${2}" > "${TEST_DIR}/${1}/${TEST_TMP}${3}" && \
	chmod -w,+x "${TEST_DIR}/${1}/${TEST_TMP}${3}"
}

do_sym() {
	ln -s "${1}" "${TEST_DIR}/${2}"
}

do_exit() {
	trap - EXIT
	exit "${@}"
}

do_test() {
	if [ ${#} -eq 2 ]; then
		set -- "${1}" "${TEST_DIR}/${2}"
	else
		set -- "${TEST_DIR}/${1}"
	fi

	set +e
	echo "Test command: ${@}" >&2

	"${@}"
	ret=${?}
	echo "Test result: ${ret}" >&2
	do_exit ${ret}
}

get_eselected() {
	set +e

	set -- eselect python show "${@}"
	ret=$("${@}")
	echo "${ret}"

	[ -n "${ret}" ] || ret='(none)'
	echo "${*} -> ${ret}" >&2

	set -e
}

# catch all failures
trap 'exit 99' EXIT
set -e

rm -f "${TEST_DIR}/${TEST_TMP}"* "${TEST_DIR}"/*/"${TEST_TMP}"*
ln -s python-exec "${TEST_DIR}/${TEST_TMP}"
. "${TEST}"
