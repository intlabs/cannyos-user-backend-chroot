#!/bin/sh
#
# CannyOS cannyos-user-backend-chroot container build script
#
# https://github.com/intlabs/cannyos-user-backend-chroot
#
# Copyright 2014 Pete Birley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
clear
curl https://raw.githubusercontent.com/intlabs/cannyos-user-backend-chroot/master/CannyOS/CannyOS.splash
#     *****************************************************
#     *                                                   *
#     *        _____                    ____  ____        *
#     *       / ___/__ ____  ___  __ __/ __ \/ __/        *
#     *      / /__/ _ `/ _ \/ _ \/ // / /_/ /\ \          *
#     *      \___/\_,_/_//_/_//_/\_, /\____/___/          *
#     *                         /___/                     *
#     *                                                   *
#     *                                                   *
#     *****************************************************
echo "*                                                   *"
echo "*         Ubuntu docker container builder           *"
echo "*                                                   *"
echo "*****************************************************"
echo ""

# Build base container image
sudo docker build -t="intlabs/cannyos-user-backend-chroot" github.com/intlabs/cannyos-user-backend-chroot

echo ""
echo "*****************************************************"
echo "*                                                   *"
echo "*         Built base container image                *"
echo "*                                                   *"
echo "*****************************************************"
echo ""

# Make shared directory on host
sudo mkdir -p "/CannyOS/build/cannyos-user-backend-chroot"
# Ensure that there it is clear
sudo rm -r -f "/CannyOS/build/cannyos-user-backend-chroot/*"

# Remove any old containers
sudo docker rm cannyos-user-backend-chroot

echo ""
echo "*****************************************************"
echo "*                                                   *"
echo "*         Launching container image                 *"
echo "*                                                   *"
echo "*****************************************************"
echo ""

# Launch built base container image
sudo docker run -i -t -rm \
 --privileged=true --lxc-conf="native.cgroup.devices.allow = c 10:229 rwm" \
 --volume "/CannyOS/build/cannyos-user-backend-chroot":"/CannyOS/Host" \
 --name "cannyos-user-backend-chroot" \
 --hostname "cannyos-user-backend-chroot" \
 --user "root" \
 -p 226:22
 intlabs/cannyos-user-backend-chroot
