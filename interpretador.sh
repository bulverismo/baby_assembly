#!/bin/bash

#### instruções suportadas ####
# 0     NOP     nenhuma operação
# 32    LDA end carrega acumulador - (load)
# 240   HLT     término de execução - (halt)

# TODO:
# usar os arquivos de memória como read only
# criar uma memoria vazia e modificar ela
# e na saida salvar ela com nome:
# arquivo_de_entrada_execução_$DATA


function principal() {

    PC=0
    AC=0
    instr=0
    instr_type=0
    data_loc=0
    data=0
    run_bit=true


    tratar_parametros "$@"
    ler_arquivo_de_memoria "$arquivo_memoria"
    interpret 0
}

function tratar_parametros() {
    
    arquivo_memoria="$1"
    DEBUG="$2"

    parar_se_algum_comando_falhar
    parar_se_arquivo_de_memoria_nao_existe "$arquivo_memoria"
    executar_em_modo_debug "$DEBUG"

}

function parar_se_algum_comando_falhar() {
    set -e
}

function parar_se_arquivo_de_memoria_nao_existe() {
    local arquivo_memoria="$1"

    if ! [ -a "./$arquivo_memoria" ]
    then
        echo "
              Informe arquivo de memória a ser interpretado:
              $0 nome_do_arquivo.txt
              " >&2
        exit 1
    fi
}

function executar_em_modo_debug() {
    local DEBUG="$1"

    if [ "$DEBUG" == "violento" ]
    then
        set -x
    fi
}

function ler_arquivo_de_memoria() {
    local arquivo_memoria="$1"
    memory=( $(tr '\n' ' ' < $arquivo_memoria) )
}

function imprimir_dados() {
    echo ${data_loc/-1/}
}

function interpret() {
    #local memory=( "${1[]}")
    local starting_address="$1"

    PC="$starting_address"
    while [ "$run_bit" == "true" ]
    do

        instr=${memory[$PC]}

        incrementar_PC

        instr_type=$(get_instr_type $instr)
        data_loc=$(find_data $instr $instr_type)

        if [ "$data_loc" -ge 0 ]
        then
            data=${memory[$data_loc]}
        fi

        execute $instr_type $data

        if [ "$DEBUG" == "debug_calmo" ]
        then
            imprimir_registradores_e_instrucao
            imprimir_variaveis
        fi

    done
    echo ${memory[@]} | tr ' ' '\n'
    if [ "$DEBUG" == "debug_registradores" ]
    then
        echo "registradores ao fim $(imprimir_registradores)"
    fi

}

function get_instr_type() {
    local instr="$1"

    case $instr in
        16 | 32) echo $instr;;
        0 | 240) echo $instr;;
        *)   exit 2;;
    esac
}

function find_data() {
    local instr="$1"
    local instr_type="$2"

    case $instr_type in
        16 | 32) { echo ${memory[$PC]}; };;
        *)   echo -1;;
    esac
}

function get_data() {
    if [ "$data_loc" -ge 0 ]
    then
        data=${memory[$data_loc]}
    fi
}

function execute() {
    local instr_type="$1"
    local data="$2"

    case $instr_type in
        0)      
            fazer_nada
            ;;
        16)     
            incrementar_PC
            memory[$data_loc]=$AC
            ;;
        32)     
            incrementar_PC
            AC=$data
            ;;
        240)    
            run_bit="false"
            ;;
        *)  
            echo Erro: execução recebeu instrução inválida
            exit 3
            ;;
    esac
}

function fazer_nada() {
    :
}

function incrementar_PC() {
    let PC=$PC+1
}

function imprimir_variaveis() {
    echo "
                PC=$PC
                AC=$AC
             instr=$instr
        instr_type=$instr_type
          data_loc=$data_loc
              data=$data
           run_bit=$run_bit

    memory[$data_loc]=${memory[$data_loc]}
    "
}

function imprimir_registradores() {
    echo "AC = $AC PC = $PC"
}

function imprimir_instrucao() {
    echo "instrução $instr_type $(imprimir_dados)"
}

function imprimir_registradores_e_instrucao() {
    echo "$(imprimir_registradores) | $(imprimir_instrucao)"
}

function testa_cabecalho_memoria() {
    #TODO: generalizar
    [ "$(ler_cabecalho '/home/jose/ufrgs/2021-2/arq 1/NEANDER/exemplos/nop nop hlt.mem')" = "$( echo -n -e '\x03\x4e\x44\x52' )" ] ; echo $?
}

principal "$@"
