#!/bin/bash

# Copyright 2020 Johns Hopkins University (Shinji Watanabe)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

# general configuration
stage=0       # start from 0 if you need to start from data preparation
stop_stage=100
SECONDS=0
lang=en # en de fr cy tt kab ca zh-TW it fa eu es ru tr nl eo zh-CN rw pt zh-HK cs pl uk 

 . utils/parse_options.sh || exit 1;

# base url for downloads.
# Deprecated url:https://voice-prod-bundler-ee1969a6ce8178826482b88e843c335139bd3fb4.s3.amazonaws.com/cv-corpus-3/$lang.tar.gz
data_url=https://voice-prod-bundler-ee1969a6ce8178826482b88e843c335139bd3fb4.s3.amazonaws.com/cv-corpus-5.1-2020-06-22/${lang}.tar.gz

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

mkdir ${COMMONVOICE}
if [ -z "${COMMONVOICE}" ]; then
    log "Fill the value of 'COMMONVOICE' of db.sh"
    exit 1
fi

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

train_set=train_"$(echo "${lang}" | tr - _)"
train_dev=dev_"$(echo "${lang}" | tr - _)"
test_set=test_"$(echo "${lang}" | tr - _)"

log "data preparation started"

log "ALCAIM"

#mkdir ${ALCAIM}

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    #if [ ! -e "${ALCAIM}/download.done" ]; then
    	log "Alcaim download not Done"
	echo "stage 1: Data Download to ${ALCAIM}"
	#for part in lapsbm-val lapsbm-test voxforge-ptbr alcaim sid; do
        #    local/download_and_untar.sh ${ALCAIM} ${data_url} ${part}
	#done
    #touch ${ALCAIM}/download.done
    #else
        log "stage 1: ${ALCAIM}/download.done is already existing. Skip data downloading"
    #fi
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    log "stage 2: Data Preparation"
    local/data_prep_alcaim.sh ${ALCAIM}/alcaim/alcaim data/alcaim
    local/data_prep_alcaim.sh ${ALCAIM}/alcaim/alcaim_dev data/alcaim_dev
    local/data_prep_alcaim.sh ${ALCAIM}/alcaim/alcaim_train data/alcaim_train
fi

if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
    log "stage 3: combine all training and development sets"
    utils/combine_data.sh --extra_files utt2num_frames data/${train_set} data/${test_set}
    test_set=alcaim
fi


log "Successfully finished. [elapsed=${SECONDS}s]"
