#!/bin/bash

PC=0
AC=0
instr=0
instr_type=0
data_loc=0
data=0
run_bit=true


function interpret() {
    local memory="$1"
    local starting_address="$2"

    PC="$starting_address"
    while [ "$run_bit" == "true" ]
    do

        instr=${memory[$PC]}



    done

}

function get_instr_type() {
    local addr="$1"

}

function find_data() {
    local instr="$1"
    local instr_type="$2"

}

function execute() {
    local instr_type="$1"
    local data="$2"

}
