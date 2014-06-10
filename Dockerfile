#
# CannyOS User Storage Dropbox
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

# Pull base image.
FROM intlabs/dockerfile-cannyos-ubuntu-14_04-fuse

# Set environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Set the working directory
WORKDIR /

#CHROOT JAIL:  http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail

#Create our directories
RUN bash -c "\
	mkdir -p /home/jail/{dev,etc,lib,lib64,usr,bin,home} && \
	mkdir -p /home/jail/usr/bin"
 
#Set owner
RUN chown root:root /home/jail
 
#Needed for the OpenSSH ChrootDirectory directive to work
RUN chmod go-w /home/jail

# Get script to pull in binary dependancies for required exectuables within chroot
ADD /CannyOS/Backend/chroot.sh /CannyOS/Backend/chroot.sh
RUN chmod +x /CannyOS/Backend/chroot.sh

#RUN mknod -m 666 /home/jail/dev/null c 1 3

#Copy the binaries we want our chroot user to have
#First the binaries
RUN cd /home/jail/bin && \
	cp /bin/bash . && \
	cp /bin/ls . && \
	cp /bin/cp . && \
	cp /bin/mv . && \
	cp /bin/mkdir .
 
#Now our l2chroot script to bring over dependencies
RUN /CannyOS/Backend/chroot.sh /bin/bash && \
	/CannyOS/Backend/chroot.sh /bin/ls && \
	/CannyOS/Backend/chroot.sh /bin/cp && \
	/CannyOS/Backend/chroot.sh /bin/mv && \
	/CannyOS/Backend/chroot.sh /bin/mkdir

# clear command requires terminal definitions.
RUN cd /home/jail/usr/bin && \
	cp /usr/bin/clear . && \
	/CannyOS/Backend/chroot.sh /usr/bin/clear

#Add terminal info files - so that clear, and other terminal aware commands will work.
RUN cd /home/jail/lib && \
	cp -r /lib/terminfo .

# Create user and jail group
RUN groupadd jail && \
	adduser --disabled-password --gecos "" --home /home/jail/home/username username && \
	echo 'username:acoman' | chpasswd && \
	sed -i 's/\/home\/jail\/home\/username:\/bin\/bash/\/home\/username:..\/..\/bin\/bash/g' /etc/passwd && \
	addgroup username jail

# Update ssh
RUN printf "\nMatch Group jail\n" >> /etc/ssh/sshd_config && \
	printf "    ChrootDirectory /home/jail\n" >> /etc/ssh/sshd_config && \
	printf "    X11Forwarding no\n" >> /etc/ssh/sshd_config && \
	printf "    AllowTcpForwarding no\n" >> /etc/ssh/sshd_config

# Restart ssh
RUN /etc/init.d/ssh restart

# Add startup 
ADD /CannyOS/startup.sh /CannyOS/startup.sh
RUN chmod +x /CannyOS/startup.sh

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
ENTRYPOINT ["/CannyOS/startup.sh"]