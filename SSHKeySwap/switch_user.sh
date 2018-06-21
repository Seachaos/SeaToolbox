#!/bin/bash

USERS_DIR=~/.switch_user/
SSH_KEY_FOLDER=~/.ssh/
SSH_KEY_PATH=~/.ssh/id_rsa.pub
SSH_KEY_PATH_PRIVATE=~/.ssh/id_rsa

function check_sshkey {
  key=$(cat $SSH_KEY_PATH)
  echo $key
}

function white {
  echo -e "\x1B[97;40m\c"
  echo -e "$@\c"
  echo -e "\x1B[0m"
}

function yellow {
  echo -e "\x1B[33;40m\c"
  echo -e "$@\c"
  echo -e "\x1B[0m"
}

function pause {
  yellow "Press enter to continue, or ctrl+c to cancel"
  read -p ''
}

function bind_user {
  DST="${USERS_DIR}/${1}"
  mkdir -p $DST
  cp $SSH_KEY_PATH $DST
  cp $SSH_KEY_PATH_PRIVATE $DST
}

function create_user {
  white 'Create new user'
  white 'input user name: '
  read NAME
  yellow "user name is ${NAME}"
  white 'will generate new ssh key'
  pause
  ssh-keygen
  bind_user $NAME
}

function list_users {
  mkdir -p $USERS_DIR
  arr=($(ls -ald ${USERS_DIR}* | awk '{n=split($9, a, "/"); print a[n]}'))
  echo "${arr[@]}"
}

function echo_list_users {
  arr=($(list_users))
  yellow 'Users : '
  for i in "${arr[@]}"
  do
    white $i
  done
}

function contains {
  arr=($2)
  for i in "${arr[@]}"
  do
    if [ "${1}" == "${i}" ]; then
      echo 'y'
      return 0
    fi
  done
  echo 'n'
  return 1
}

function check_current_user {
  users=($(list_users))
  _key=$(cat ${SSH_KEY_PATH})
  for user in "${users[@]}"
  do
    key=$(cat ${USERS_DIR}${user}/id_rsa.pub)
    if [ "${_key}" == "${key}" ]; then
      echo $user
      return 0
    fi
  done
  echo '__no__user__'
  return 1
}

current_user=$(check_current_user)

function check_current_key_safe {
  if [ "${current_user}" == "__no__user__" ]; then
    white 'To keep you key, please input your user name: '
    read NAME
    yellow "user name is ${NAME}"
    pause
    bind_user $NAME
    white "key save success. with user name : ${NAME}"
  fi
}

if [ $1 ]; then
  user=$1
  users=$(list_users)
  exists=$(contains $user "${users[@]}")
  if [ "${exists}" == "y" ]; then
    check_current_key_safe
    white "Will switch to user: ${user}"
    pause
    rm $SSH_KEY_PATH
    rm $SSH_KEY_PATH_PRIVATE
    cp -r ${USERS_DIR}${user}/* ${SSH_KEY_FOLDER}

    current_user=$(check_current_user)
    yellow "switch to : ${current_user} ok"
  else
    echo 'user not exists'
    echo 'create it ?'
    create_user
  fi
  exit 0
fi

if [ -f $SSH_KEY_PATH ]; then
  check_current_key_safe
  echo_list_users
  if [ "${current_user}" != "__no__user__" ]; then
    yellow "Current is : ${current_user}"
  fi
else
  white 'There is no ssh key'
  create_user
fi