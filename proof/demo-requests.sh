#!/bin/bash
# Live demo for oppia#19904. Every command below really runs; nothing is canned.
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'
type_run() { printf "${G}\$ ${N}"; for ((i=0;i<${#1};i++)); do printf '%s' "${1:i:1}"; sleep 0.02; done; echo; eval "$1"; echo; sleep 1.2; }
say() { echo -e "${C}# $1${N}"; sleep 1.2; }
cd /workspace/gsoc
clear
say "oppia#19904: a malformed JSON payload should give a 400, not a 500"
say "two local oppia dev servers (dev_appserver.py + app_dev.yaml), same datastore/firebase/redis emulators"
type_run "git -C wt-develop log --oneline -1   # develop, served on :8182"
type_run "git -C wt-19904 log --oneline -1     # this PR, served on :8181"
type_run "ss -ltnp | grep -E ':(8181|8182) ' | awk '{print \$4, \$6}'"
echo -e "${Y}=== BEFORE: develop (:8182) ===${N}"; sleep 1
type_run "curl -s -o /dev/null -w 'HTTP %{http_code}\n' -X POST localhost:8182/frontend_errors --data-urlencode 'payload={\"error\": \"x\"}'"
type_run "curl -s -w '\nHTTP %{http_code}\n' -X POST localhost:8182/frontend_errors --data-urlencode 'payload=1}' | sed -n '/<h1>/p;/HTTP/p'"
type_run "tr -d '\000' < /tmp/devapp-develop.log | grep -E 'JSONDecodeError|POST /frontend_errors' | tail -2 | cut -c1-140"
sleep 2
clear
echo -e "${Y}=== AFTER: this PR (:8181) ===${N}"; sleep 1
type_run "curl -s -o /dev/null -w 'HTTP %{http_code}\n' -X POST localhost:8181/frontend_errors --data-urlencode 'payload={\"error\": \"x\"}'"
type_run "curl -s -w '\nHTTP %{http_code}\n' -X POST localhost:8181/frontend_errors --data-urlencode 'payload=1}'"
type_run "curl -s -w '\nHTTP %{http_code}\n' -X POST localhost:8181/frontend_errors --data-urlencode 'payload={\"error\": '"
type_run "tr -d '\000' < /tmp/devapp-fix.log | grep -E 'POST /frontend_errors' | tail -3 | cut -c1-140"
say "valid payloads still return 200; malformed ones now return a clean 400 instead of crashing"
sleep 4
