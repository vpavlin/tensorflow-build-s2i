#! /bin/bash

source scl_source enable devtoolset-7
if [ "$PYTHON_VERSION" = "3.6" ] ; then echo "enabling Python 3.6" && source scl_source enable rh-python36 ; fi
gcc -v
python -V
FULL_JAVA_HOME=$(readlink -f $JAVA_HOME)
echo $FULL_JAVA_HOME
export JAVA_HOME=$FULL_JAVA_HOME
cd /opt/app-root/
./compile.sh
cp /opt/app-root/output/bazel /usr/local/bin/
bazel version