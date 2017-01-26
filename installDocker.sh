#!/bin/bash -e
readonly DOCKER_VERSION=1.9.1
export DEBIAN_FRONTEND=noninteractive

exec_cmd() {
  cmd=$@
  eval $cmd
  cmd_status=$?
  if [ "$2" ]; then
    echo $2;
  fi
  return $cmd_status
}

_run_update() {
  is_success=false
  update_cmd="sudo -E apt-get update"
  exec_cmd "$update_cmd"
  is_success=true
}

docker_install() {
  is_success=false
  exec_cmd "echo Installing docker"

  _run_update

  add_docker_repo_keys='sudo -E apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
  exec_cmd "$add_docker_repo_keys"

  local docker_repo_entry="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
  local docker_sources_file="/etc/apt/sources.list.d/docker.list"
  local add_docker_hosts=true

  if [ -f "$docker_sources_file" ]; then
    local docker_source_present=""
    {
      docker_source_present=$(grep "$docker_repo_entry" $docker_sources_file)
    } || {
      true
    }

    if [ "$docker_source_present" != "" ]; then
      ## docker hosts entry already present in file
      add_docker_hosts=false
    fi
  fi

  if [ $add_docker_hosts == true ]; then
    add_docker_repo="echo $docker_repo_entry | sudo tee -a $docker_sources_file"
    exec_cmd "$add_docker_repo"
  else
    exec_cmd "echo 'Docker sources already present, skipping'"
  fi

  _run_update

  install_kernel_extras='sudo -E apt-get install -y -q linux-image-extra-$(uname -r) linux-image-extra-virtual'
  exec_cmd "$install_kernel_extras"

  local docker_version=$DOCKER_VERSION"-0~trusty"
  install_docker="sudo -E apt-get install -q --force-yes -y -o Dpkg::Options::='--force-confnew' docker-engine=$docker_version"
  exec_cmd "$install_docker"

  get_static_docker_binary="wget https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz -P /tmp/docker"
  exec_cmd "$get_static_docker_binary"

  extract_static_docker_binary="sudo tar -xzf /tmp/docker/docker-$DOCKER_VERSION.tgz --directory /opt"
  exec_cmd "$extract_static_docker_binary"

  remove_static_docker_binary='rm -rf /tmp/docker'
  exec_cmd "$remove_static_docker_binary"

  is_success=true
}

docker_install
