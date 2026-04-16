# Global settings
MNML_OK_COLOR="${MNML_OK_COLOR:-2}"
MNML_ERR_COLOR="${MNML_ERR_COLOR:-1}"

MNML_USER_CHAR="${MNML_USER_CHAR:-λ}"
MNML_INSERT_CHAR="${MNML_INSERT_CHAR:-›}"
MNML_NORMAL_CHAR="${MNML_NORMAL_CHAR:-·}"
MNML_ELLIPSIS_CHAR="${MNML_ELLIPSIS_CHAR:-..}"
MNML_BGJOB_MODE=${MNML_BGJOB_MODE:-4}

[ "${+MNML_PROMPT}" -eq 0 ] && MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)
[ "${+MNML_RPROMPT}" -eq 0 ] && MNML_RPROMPT=('mnml_cwd 2 0' mnml_git)
[ "${+MNML_INFOLN}" -eq 0 ] && MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)

[ "${+MNML_MAGICENTER}" -eq 0 ] && MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)

# ...rest of theme code...
