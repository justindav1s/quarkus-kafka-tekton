#!groovy
//import groovy.transform.Field

node('maven') {

    def mvn          = "/opt/apache-maven-3.6.3/bin/mvn -U -B -q -s settings.xml"
    def dev_project  = "${org}-quarkus"
    def app_url_dev  = "http://${app_name}.${dev_project}.svc:8080"
    def sonar_url    = "http://sonarqube.cicd.svc:9000"
    def nexus_url    = "http://nexus.cicd.svc:8081/repository/maven-snapshots"
    def registry     = "quay.io/justindav1s"
    def groupId, version, packaging = null
    def artifactId = null

    stage('Checkout Source') {
        git url: "${git_url}", branch: 'master'
    }

    stage('Check Maven Version') {           
            sh "${mvn} -version"
            echo "GRAALVM_HOME : ${GRAALVM_HOME}"
            echo "PATH : ${PATH}"
    }

    def commitId  = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
    def commitmsg  = sh(returnStdout: true, script: "git log --format=%B -n 1 ${commitId}").trim()

    dir("quarkus/${app_name}") {

        groupId      = getGroupIdFromPom("pom.xml")
        artifactId   = getArtifactIdFromPom("pom.xml")
        version      = getVersionFromPom("pom.xml")
        packaging    = getPackagingFromPom("pom.xml")

        stage ('Maven native build'){
            echo 'Building and test native binary'
            sh "${mvn} package -Pnative -DskipTests"   
        }

         //Build the OpenShift Image in OpenShift and tag it.
        stage('Build and Tag OpenShift Image') {
            echo "Building OpenShift container image ${app_name}:${devTag}"
            echo "Project : ${dev_project}"
            echo "App : ${app_name}"
            echo "Group ID : ${groupId}"
            echo "Artifact ID : ${artifactId}"
            echo "Version : ${version}"
            echo "Packaging : ${packaging}"

            sh "ls -ltr target"

            openshift.withCluster() {
                openshift.withProject("${dev_project}") {

                    echo "Building ...."
                    def bc = openshift.selector( "bc/${app_name}-native" ).object()
                    bc.spec.output.to.name="${registry}/${app_name}-native:${commitId}"
                    openshift.apply(bc)

                    def nb = openshift.startBuild("${app_name}-native", "--from-dir=.")
                    nb.logs('-f')

                }
            }
        }

        // Deploy the built image to the Development Environment.
        stage('Deploy to Dev') {
            echo "Deploying container image to Development Project"
            echo "Project : ${dev_project}"
            echo "App : ${app_name}"
            echo "Dev Tag : ${devTag}"
            def container = "${app_name}"
            def config_name = "${app_name}-native-config"
            app_name = "${app_name}-native"
            def app_label = "${app_name}"

            openshift.withCluster() {
                openshift.withProject(dev_project) {
                    //remove any triggers
                    openshift.set("triggers", "dc/${app_name}", "--remove-all")

                    //update app config
                    openshift.delete("configmap", "${config_name}", "--ignore-not-found=true")
                    openshift.create("configmap", "${config_name}", "--from-file=${config_file}")

                    //update deployment config with new image
                    openshift.set("image", "dc/${app_name}", "${container}=${registry}/${app_name}:${commitId}")

                    //trigger a rollout of the new image
                    rm = openshift.selector("dc", [app:app_label]).rollout().latest()
                    //wait for rollout to start
                    timeout(5) {
                        openshift.selector("dc", [app:app_label]).related('pods').untilEach(1) {
                            return (it.object().status.phase == "Running")
                        }
                    }
                    //rollout has started

                    //wait for deployment to finish and for new pods to become active
                    def latestDeploymentVersion = openshift.selector('dc',[app:app_label]).object().status.latestVersion
                    def rc = openshift.selector("rc", "${app_name}-${latestDeploymentVersion}")
                    rc.untilEach(1) {
                        def rcMap = it.object()
                        return (rcMap.status.replicas.equals(rcMap.status.readyReplicas))
                    }
                    //deployment finished
                }
            }
            echo "Deploying container image to Development Project : FINISHED"
        }
    }
}

// Convenience Functions to read variables from the pom.xml
// Do not change anything below this line.
// --------------------------------------------------------
def getVersionFromPom(pom) {
    def matcher = readFile(pom) =~ '<version>(.+)</version>'
    matcher ? matcher[0][1] : null
}
def getGroupIdFromPom(pom) {
    def matcher = readFile(pom) =~ '<groupId>(.+)</groupId>'
    matcher ? matcher[0][1] : null
}
def getArtifactIdFromPom(pom) {
    def matcher = readFile(pom) =~ '<artifactId>(.+)</artifactId>'
    matcher ? matcher[0][1] : null
}
def getPackagingFromPom(pom) {
    def matcher = readFile(pom) =~ '<packaging>(.+)</packaging>'
    matcher ? matcher[0][1] : null
}