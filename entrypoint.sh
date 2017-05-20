#!/bin/bash
set -ex

cp /etc/docksterisk/asterisk/* /etc/asterisk

exec "$@"
