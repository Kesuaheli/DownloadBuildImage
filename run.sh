#!/usr/bin/env bash

main () {
	# sanity
	if [[ -z $GIT_REPO_HOST || -z $GIT_REPO_NAME || -z $CONTAINER_RUN ]]; then
		echo "fatal: env GIT_REPO_HOST, GIT_REPO_NAME and CONTAINER_RUN must be set (either is empty)" >&2
		exit 1
	fi

	# setup for private repo if key is given
	if [[ -n $GIT_REPO_KEY ]]; then
		echo "${GIT_REPO_KEY}" > /root/.ssh/id_rsa

		# create known host of repo host
		ssh-keyscan $GIT_REPO_HOST >> /root/.ssh/known_hosts
	fi

	echo "cloning repository '$GIT_REPO_NAME' from '$GIT_REPO_HOST'"
	git clone git@$GIT_REPO_HOST:$GIT_REPO_NAME.git
	local result=$?
	[[ $result -ne 0 ]] && exit "$result"

	$CONTAINER_RUN
}

main "$@"
