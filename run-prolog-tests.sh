#!/bin/bash

PROLOG_SRC_DIR=${PROLOG_SRC_DIR:-src/main/prolog}

swipl -f ${PROLOG_SRC_DIR}/test_oops.pl -t run_oops_tests
swipl -f ${PROLOG_SRC_DIR}/test_necro.pl -t run_necro_tests
swipl -f ${PROLOG_SRC_DIR}/test_dragons.pl -t run_dragons_tests
