#!/usr/bin/env zsh

abs_script="$(realpath "$0")"
_bin="$(dirname "${abs_script}")"
_scroot="$(dirname "${_bin}")"

# shellcheck source=/dev/null
source "${_scroot}/lib/logging.sh"

# https://github.com/ko1nksm/getoptions#use-as-a-library
# shellcheck disable=SC1091
source "${_scroot}/lib/getoptions.sh"

# Library does all manner of complicated params, options, flags, subcommands etc, and sets them all to an environment variable
# https://github.com/ko1nksm/getoptions
## begin parser
# shellcheck disable=SC1083,SC2016,SC2145
parser_definition() {
  setup REST plus:true help:usage abbr:true -- \
    "Usage: ${2##*/} [options...] [arguments...]" ''
  msg -- 'Example: ansrun.zsh -p $PLAYBOOK' ''
  msg -- 'Run ansible operations with less fuss and muss' ''
  param PLAYBOOK -p --playbook -- "Ansible Playbook to run"
  param TAG -t --tag -- "Tag to run within a playbook"
  param LIMIT -l --limit -- "Limit ansible to a particular host"
  flag DEBUG -d --debug -- "Set debug '-vvvvv'"
  disp :usage -h --help
  disp VERSION --version
}
# https://github.com/ko1nksm/getoptions/blob/master/docs/References.md

eval "$(getoptions parser_definition parse)"
parse "$@"
eval "set -- $REST"
## end parser

# TODO: validate ansible config

if [[ -z "${PLAYBOOK}" ]]; then
  error "At least one playbook needs to be specified"
  exit 1
fi

# TODO: Make this parameter an array
if [[ -n "${TAG}" ]]; then
  _tag="--tag ${TAG}"
fi

# TODO: Make this parameter an array

if [[ -n "${LIMIT}" ]]; then
  _limit="--limit ${LIMIT}"
fi

if [[ -n "${DEBUG}" ]]; then
  _debug="-vvvvv"
fi

ansible-playbook "$HOME/scripts/ansible/playbooks/${PLAYBOOK}.yaml" -i "$HOME/scripts/ansible/inventory/hosts.ini" --vault-password-file ${HOME}/.ansible/vault_token ${_tag} ${_limit} ${_debug}
