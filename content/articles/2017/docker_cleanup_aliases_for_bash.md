Title: Docker cleanup aliases for bash
Category: docker
Tags: docker, bash, linux, containers
Slug: docker-cleanup-aliases-for-bash
Date: Tue Jun  6 16:18:24 EDT 2017
Status: published

As I progress with learning docker I eventually found myself annoyed with how much it leaves behind at the behest of the user to clean up. (That is, it doesn't seem to do a very good job of cleaning up after itself). I wrote these aliases for myself while I learn and explore Docker in order to aid in cleaning my system up during the process of testing and using many containers and images.

I personally use this merged with my [`.aliases`](https://github.com/xenithorb/dotfiles/blob/master/.aliases) file which is a part of my [dotfiles repo](https://github.com/xenithorb/dotfiles). I use this simple dotfiles "framework" to keep a consistent set of configs between systems I want to customize.

<script src="https://gist.github.com/xenithorb/c0fdae80878a010759b2a3d1d76cf608.js"></script>

<!-- ```bash
# These should go in ~/.bashrc or an equivalent area that is sourced into your shell environmemnt

# Remove all docker containers running and exited
alias docker-rma='__drma() { docker ps -aq "$@" | xargs -r docker rm -f; }; __drma'
# Remove all docker images
alias docker-rmia='__drmia() { docker images -q "$@" | xargs -r docker rmi -f; }; __drmia'
# Remove all custom docker networks
alias docker-rmnet='__drmnet() { docker network ls -q -f type=custom "$@" | xargs -r docker network rm; }; __drmnet'
# Remove all unused volumes
alias docker-rmvol='__drmvol() { docker volume ls -q "$@" | xargs -r docker volume rm; }; __drmvol'
# Remove all docker containers and all docker images
alias docker-rmall='docker-rma && docker-rmia'
# Remove all docker containers, images, custom networks, and volumes
alias docker-nuke='docker-rmall; docker-rmnet; docker-rmvol'
# Remove only exited containers, unused images, unused networks, and unused volumes
alias docker-clean='docker-rma -f status=exited; docker-rmia -f dangling=true; docker-rmnet; docker-rmvol -f dangling=true'
``` -->
