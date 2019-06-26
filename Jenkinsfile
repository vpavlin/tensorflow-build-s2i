def operatingSystem = env.OPERATING_SYSTEM ?: "fedora28"
def s2iImage = env.S2I_IMAGE ?: "registry.fedoraproject.org/f28/s2i-core"
def pythonVersion = env.PYTHON_VERSION ?: "3.6"
def pythonVersionNoDecimal = pythonVersion.replaceAll("[^a-zA-Z0-9]+","")
def bazelVersion = env.BAZEL_VERSION ?: "0.15.0"
def tfBranch = env.TF_GIT_BRANCH ?: "r1.10"
def customBuild = env.CUSTOM_BUILD ?: "bazel build -c opt --cxxopt='-D_GLIBCXX_USE_CXX11_ABI=0' --verbose_failures //tensorflow/tools/pip_package:build_pip_package"
def cpuLimit = env.CPU_LIMIT ?: "32"
def cpuRequests = env.CPU_REQUESTS?: "32"
def memLimit = env.MEMORY_LIMIT ?: "50Gi"
def memRequests = env.MEMORY_REQUESTS ?: "50Gi"
def enableCleanup = env.CLEANUP ?: false
def pipList = env.PIP_LIST ?: ""
def buildScript = env.BUILD_SCRIPT ?: ""

// Name of project in OpenShift
def project = "tensorflow"

node {
  def builderImageStream = ''
  def buildJob = ''
  def uuid = UUID.randomUUID().toString()
  def jobPods = ''

  openshift.withCluster() {
    openshift.withProject(project) {
      withCredentials([[$class: 'StringBinding', credentialsId: 'GIT_TOKEN', variable: 'GIT_TOKEN']]) {
        try {
          // This stage builds the base image to be used later for testing Tensorflow
          stage("Build Image") {
            def tensorflowImageTemplate = openshift.selector("template", "tensorflow-build-image").object()
            builderImageStream = openshift.process(
              tensorflowImageTemplate,
              "-p", "APPLICATION_NAME=tf-${operatingSystem}-${pythonVersionNoDecimal}-image-${uuid}",
              "-p", "BAZEL_VERSION=${bazelVersion}",
              "-p", "DOCKER_FILE_PATH=Dockerfile.${operatingSystem}",
              "-p", "PYTHON_VERSION=${pythonVersion}",
              "-p", "PIP_LIST=${pipList}",
              "-p", "S2I_IMAGE=${s2iImage}"
            )
            def createdImageStream = openshift.create(builderImageStream)
            createdImageStream.describe()
            def imageStreamBuildConfig = createdImageStream.narrow('bc')
            // Check OpenShift to make sure the pod is running before trying to tail the logs
            def builds = imageStreamBuildConfig.related('builds')
            timeout(5) {
              builds.untilEach {
                echo "builds Status: ${it.object().status.phase}"
                // Pending --> Running
                return (it.object().status.phase == "Running")
              }
            }
            imageStreamBuildConfig.logs('-f')

            // Check OpenShift to see if the build has completed
            def imageBuildCompleted = false
            timeout(10) {
              imageStreamBuildConfig.related('builds').untilEach {
                if (it.object().status.phase == "Complete") {
                  echo "Status0 imageBuildCompleted"
                  imageBuildCompleted = true
                }
                return imageBuildCompleted
              }
            }
            echo "Status0 Done"
            // If build is not completed after 1 minuete, we are assuming there was an error
            // And throwing to the catch block
            if (!imageBuildCompleted) {
              error("An error has occured in tf-${operatingSystem}-${pythonVersionNoDecimal}-image-${uuid}")
            }
          } //end of stage

          // This stage uses the image built previously and runs the s2i/bin/run script to verify Tensorflow
          stage("Build Job") {
            def tensorflowJobTemplate = openshift.selector("template", "tensorflow-build-job").object()
            buildJob = openshift.process(
              tensorflowJobTemplate,
              "-p", "APPLICATION_NAME=tf-${operatingSystem}-${pythonVersionNoDecimal}-job-${uuid}",
              "-p", "BAZEL_VERSION=${bazelVersion}",
              "-p", "BUILDER_IMAGESTREAM=tf-${operatingSystem}-${pythonVersionNoDecimal}-image-${uuid}",
              "-p", "CUSTOM_BUILD=${customBuild}",
              "-p", "PYTHON_VERSION=${pythonVersion}",
              "-p", "GIT_TOKEN=${env.GIT_TOKEN}",
              "-p", "TF_GIT_BRANCH=${tfBranch}",
              "-p", "CPU_LIMIT=${cpuLimit}",
              "-p", "CPU_REQUESTS=${cpuRequests}",
              "-p", "MEMORY_LIMIT=${memLimit}",
              "-p", "MEMORY_REQUESTS=${memRequests}",
              "-p", "BUILD_SCRIPT=${buildScript}"
            )
            def createdJob = openshift.create(buildJob)
            jobPods = createdJob.related('pods')

            // Check OpenShift to make sure the pod is running before trying to tail the logs
            timeout(5) {
              jobPods.untilEach {
                echo "Status1: ${it.object().status.phase}"
                return (it.object().status.phase == "Running")
              }
            }
            echo "Status1 done"
            jobPods.logs("-f")
            // Check OpenShift to see if the build has Succeeded
            def jobDone = false
            def jobSucceededflag = false
            timeout(35) {
              jobPods.untilEach {
                echo "Status2: ${it.object().status.phase}"
                if (it.object().status.phase == "Succeeded") {
                  jobDone = true
                  jobSucceeded = true
                } else if (it.object().status.phase == "Failed") {
                  jobDone = true
                  jobSucceeded = false
                }
                return jobDone
              }
            }
            echo "Status2 done"
            // If build is not completed after 35 minute, we are assuming there was an error
            // And throwing to the catch block
            if (jobDone && !jobSucceeded) {
              error("===An error has occurred in tf-${operatingSystem}-${pythonVersionNoDecimal}-job-${uuid}")
            }
          }//end of stage
        } catch (e) {
          echo e.toString()
          throw e
        } finally {
          // Delete all resources related to the current build
          stage("Cleanup") {
            //def resultlog = jobPods.logs()
            //echo resultlog.toString()
            if (enableCleanup) {
              openshift.delete(builderImageStream)
              openshift.delete(buildJob)
            }
          }
        }
      }
    }
  }
}
