#! /bin/bash

# ensure setup_devtoolset.sh and setup_python.sh
#

gcc -v
python -V
FULL_JAVA_HOME=$(readlink -f $JAVA_HOME)
echo $FULL_JAVA_HOME
export JAVA_HOME=$FULL_JAVA_HOME
cd /opt/app-root/
./compile.sh
# put /opt/app-root/output/bazel in path
export PATH=/opt/app-root/output/:$PATH
# cp /opt/app-root/output/bazel /usr/local/bin/
bazel version