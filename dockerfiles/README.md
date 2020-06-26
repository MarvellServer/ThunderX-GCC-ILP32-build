This directory contains all the dockerfiles to build gcc-ilp32 in different OS's docker container.

Here is the example if you want to build gcc-ilp32 on centos:

1) cd centos/centos_8
2) You need to have your id_rsa file ready, this should be the file you use to access https://github.com/MarvellServer
   copy the id_rsa file to centos/centos_8/data/ directory
3) docker build -t centos_8_gcc_ilp32 ./
4) it will start to load the OS and install different packages, ... 1.5 hours later
5) It will finish with the error message:
======
hello worldgcc (GCC) 11.0.0 20200618 (experimental)
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Removing intermediate container 1b3b44983ad1
 ---> a11cb66c0c0a
Step 49/50 : RUN echo "We stop here so that you can copy the rpm file out of docker container" &&     echo "You can find the package at /root/rpmbuild/RPMS/aarch64" &&     gcc
 ---> Running in d9f6993b09f1
We stop here so that you can copy the rpm file out of docker container
You can find the package at /root/rpmbuild/RPMS/aarch64
gcc: fatal error: no input files
compilation terminated.
======

6) use the following command to copy the rmp package out of the container
docker cp a11cb66c0c0a(this is the container ID before step 49/50 above):/root/rpmbuild/RPMS/aarch64/${PKG_NAME}-${TODAY}-0.el8.aarch64.rpm ./

You can easily find out the ${PKG_NAME} and ${TODAY} string form the docker printout on your screen.

The rpm package has been reinstalled and tested by a simple "hello world" test program.

