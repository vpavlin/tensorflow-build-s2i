#!/bin/bash -e
# Setup Tensorflow build env
# should be run only after setup_devtoolset.sh
# ----------------------------

echo "==============================="
echo "Setup Tensorflow build env..."
major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
minor=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f2)
OSVER=$(cat /etc/redhat-release | cut -d' ' -f1 |  awk '{print tolower($0)}')
echo "OSVER = "$OSVER
OS_VERSION="$OSVER$major"
echo "OS_VERSION = "$OS_VERSION
echo "DEV_TOOLSET_VERSION = "$DEV_TOOLSET_VERSION

# remove gcc/g++/ld to avoid bazel using it
# if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
# 	echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
# 	rm -fr /usr/bin/gcc &&
# 	rm -fr /usr/bin/g++ &&
# 	rm -fr /usr/bin/ld &&
# 	ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/gcc /usr/bin/gcc &&
# 	ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/g++ /usr/bin/g++ &&
# 	ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/ld /usr/bin/ld;
# fi
echo "Ensure all the values below are correct doe the build environment..."
echo | gcc -E -Wp,-v -
# java in path
export PATH=$HOME/bin:$PATH
export JAVA_HOME=$(readlink -f $JAVA_HOME)
ls -l $JAVA_HOME
echo "JAVA_HOME="$JAVA_HOME
echo "PATH="$PATH

echo "which_gcc="`which gcc`
echo "which_g++="`which g++`
echo "which_ld="`which ld`
echo "which_python="`which python`
echo "which_python_link="`ls -l $(which python) | awk '{print  $9 $10 $11}'`
echo "/usr/bin/python_link="`ls -l /usr/bin/python |awk '{print  $9 $10 $11}'`
echo "which_pip="`which pip`
echo "which_pip_version="`pip --version `
echo "which_pip_site="`pip --version |awk '{print $4}' `
echo "which_pip_link="`ls -l $(which pip) | awk '{print  $9 $10 $11}'`
python -V 
gcc -v
pip list 2>&1 | grep -i "YAML\|proto\|numpy\|keras"
echo "==============================="
