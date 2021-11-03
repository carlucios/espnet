#!/bin/bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

lang=pt

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# Configuração geral
backend=pytorch
stage=-1	# começa do -1 se você precisa começar da preparação dos dados
stop_stage=100
ngpu=1		# número de gpus (0 usa apenas a cpu)
debugmode=1
dumpdir=dump	# pasta com os parâmetros extraídos
N=0		# número de minibatches a serem usados (principalmente para debbugging). "0" usa todos os minibatches
verbose=0	# opção de verbose
resume=		# Resume o treinamento para snapshot

# Configuração de parâmetros
do_delta=false

train_config=conf/train_asr_transformer.yaml
lm_config=conf/train_lm.yaml
decode_config=conf/decode_asr.yaml

# Relacionado com rnnlm
lm_resume= 	# especifica um arquivo de snapshot para resumir o treinamento da LM
lm_tag=		# tag para administrar LMs

# Parâmetro de decodificação
recog_model=model.acc.best	# seta um modelo a ser usado para decodificação: 'model.acc.best' ou 'model.loss.best'
n_average=10

# exp tag
tag=		# tag para administrar experimentos

./utils/parse_option.sh || exit 1;

# Dados
train_set="alcaim_train tr_pt et_pt"
train_dev="alcaim_dev dt_pt"
recog_set="alcaim"

log "Prepração de dados iniciou"

log "Alcaim"

#mkdir ${ALCAIM}

if [ ${stage} -le -1 ] && [ ${stop_stage} -ge -1 ]; then
	if [ ! -e "${ALCAIM}/download.done" ]; then
		log "Alcaim download não realizado"
		echo "stage -1: Download de dados do ${ALCAIM} 



if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
	# TODO
	# add um check se a preparação de dados é completa ou não
	# Voxforge
	for lang_code in pt; do
		if [ -e ../../voxforge/asr1/data/tr_${lang_code} ]; then
			utils/copy_data_dir.sh --utt-suffix -${lang_code} ../../voxforge/asr1/data/tr_${lang_code} data/tr_${lang_code}
			utils/copy_data_dir.sh --utt-suffix -${lang_code} ../../voxforge/asr1/data/dt_${lang_code} data/dt_${lang_code}
			utils/copy_data_dir.sh --utt-suffix -${lang_code} ../../voxforge/asr1/data/et_${lang_code} data/tr_${lang_code}
		else
			echo "no voxforge ${lang_code} data directory found"
			echo "cd ../../voxforge/asr1; ./run.sh --stop_stage 2 --lang ${lang_code}; cd -"
			exit 1;
		fi
	done

	# Alcaim
	for lang_code in pt; do
                if [ -e data/alcaim_train ]; then
                        utils/copy_data_dir.sh --utt-suffix -${lang_code} data/alcaim_train data/tr_${lang_code}
                        utils/copy_data_dir.sh --utt-suffix -${lang_code} data/alcaim_dev data/dt_${lang_code}
                        utils/copy_data_dir.sh --utt-suffix -${lang_code} data/alcaim data/et_${lang_code}
                else
                        echo "no voxforge ${lang_code} data directory found"
                        echo "cd ../../voxforge/asr1; ./run.sh --stop_stage 2 --lang ${lang_code}; cd -"
                        exit 1;
                fi
        done
fi




train_set="alcaim_train tr_pt dt_pt et_pt"
train_dev="alcaim_dev"
test_set="alcaim"

asr_config=conf/train_asr_transformer_commonvoice.yaml
lm_config=conf/train_lm.yaml
inference_config=conf/decode_asr.yaml

if [[ "zh" == *"${lang}"* ]]; then
  nbpe=2500
elif [[ "fr" == *"${lang}"* ]]; then
  nbpe=350
elif [[ "es" == *"${lang}"* ]]; then
  nbpe=235
else
  nbpe=500
fi

./asr.sh \
    --ngpu 1 \
    --lang "${lang}" \
    --local_data_opts "--lang ${lang}" \
    --use_lm false \
    --lm_config "${lm_config}" \
    --token_type char \
    --nbpe $nbpe \
    --feats_type raw \
    --speed_perturb_factors "0.9 1.0 1.1" \
    --asr_config "${asr_config}" \
    --inference_config "${inference_config}" \
    --train_set "${train_set}" \
    --valid_set "${train_dev}" \
    --test_sets "${test_set}" "$@"

