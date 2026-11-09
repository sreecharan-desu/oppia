#!/bin/bash
# Backend test run for oppia#19904. Real pytest runs, nothing canned.
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'
type_run() { printf "${G}\$ ${N}"; for ((i=0;i<${#1};i++)); do printf '%s' "${1:i:1}"; sleep 0.02; done; echo; eval "$1"; echo; sleep 1.5; }
say() { echo -e "${C}# $1${N}"; sleep 1.2; }
PY=/workspace/gsoc/oppia-venv/bin/python
clear
echo -e "${Y}=== new test against develop (base.py unchanged) ===${N}"
cd /workspace/gsoc/wt-develop
type_run "git checkout fix-19904-malformed-payload -- core/controllers/base_test.py && git status --short"
type_run "$PY -m pytest core/controllers/base_test.py -k MalformedPayloadTests -p no:cacheprovider -q 2>&1 | grep -E 'AssertionError|JSONDecodeError: |passed|failed' | cut -c1-150"
type_run "git checkout HEAD -- core/controllers/base_test.py && git status --short"
clear
echo -e "${Y}=== this PR: full base_test.py ===${N}"
cd /workspace/gsoc/wt-19904
type_run "git log --oneline -1"
type_run "$PY -m pytest core/controllers/base_test.py -p no:cacheprovider -q 2>&1 | tail -4"
type_run "$PY -m pytest core/controllers/base_test.py -k MalformedPayloadTests -p no:cacheprovider -v 2>&1 | grep -E 'PASSED|FAILED|passed'"
sleep 4
