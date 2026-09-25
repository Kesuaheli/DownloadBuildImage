#!/usr/bin/env bash

# TODO:
# - checkout commit
# - just start if already cloned / on correct commit

_exit-on-fail() {
	local code=$1
	local msg=$2
	
	[[ $code -eq 0 ]] && return
	[[ -n $msg ]] && echo "$msg" >&2

	exit $code
}

_setup-ssh() {
	eval $(ssh-agent -s)

	# proper line splitting on key
	GIT_REPO_KEY=${GIT_REPO_KEY% -*}
	GIT_REPO_KEY=${GIT_REPO_KEY#*- }
	GIT_REPO_KEY=$(echo -e "$GIT_REPO_KEY" | tr -d '\r' | tr " " "\n")
	echo -e "-----BEGIN OPENSSH PRIVATE KEY-----\n$GIT_REPO_KEY\n-----END OPENSSH PRIVATE KEY-----" | ssh-add -
	_exit-on-fail $? "adding ssh key failed"

	# create known host of repo host
	ssh-keyscan $GIT_REPO_HOST >> /root/.ssh/known_hosts
	_exit-on-fail $? "scanning git repo host failed: $GIT_REPO_HOST"
}

_setup-repo() {
	local repo_dir="$1"
	if [[ -z $GIT_REPO_HOST ]]; then
		echo "fatal: env GIT_REPO_HOST is empty but must be set" >&2
		exit 1
	fi

	# setup for private repo if key is given
	if [[ -n $GIT_REPO_KEY ]]; then
		_setup-ssh
	fi

	echo "cloning repository '$GIT_REPO_NAME' from '$GIT_REPO_HOST'"
	git clone git@$GIT_REPO_HOST:$GIT_REPO_NAME.git $repo_dir
	_exit-on-fail $? "cloning repo failed"
}

main () {
	# sanity
	if [[ -z $GIT_REPO_RUN ]]; then
		echo "fatal: env GIT_REPO_RUN is empty but must be set" >&2
		exit 1
	fi
	if [[ -z $GIT_REPO_NAME ]]; then
		echo "fatal: env GIT_REPO_NAME is empty but must be set" >&2
		exit 1
	fi

	local repo_dir=$(basename -s .git "$GIT_REPO_NAME")
	if [[ -d $repo_dir ]]; then
		echo "repo '$repo_dir' already exist. "
	else
		_setup-repo "$repo_dir"
	fi
	cd $repo_dir
	pwd
	ls -la

	if [[ -n $GIT_REPO_RUN_DIR ]]; then
		cd $GIT_REPO_RUN_DIR
		pwd
		ls -la
	fi
}

main "$@"

eval "$GIT_REPO_RUN"
_exit-on-fail $? 
