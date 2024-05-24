#!/bin/bash

set -euxo pipefail

bun install

just enable_bash_completions
just genenv
