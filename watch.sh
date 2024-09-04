#!/bin/bash
test -e "${PWD}/log"  &&  echo "This is EACH_BREADCRUMB target example"  |  sed 's/^/ (/'  |  sed 's/$/)/'
