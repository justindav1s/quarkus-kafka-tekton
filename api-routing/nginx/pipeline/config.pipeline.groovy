#!groovy
//imput vars :

// project : the name of the project hosting the nginx-proxy, eg alfa-dev
// config file type : cloud or onprem

node('maven') {

    echo "Project : ${project}"
    echo "Config File Path : ${config_file}"

    stage('Checkout Source') {
        git url: "${git_url}", branch: 'master'
    }

    dir("api-routing/nginx/config/${project}") {

        // Deploy the configMap
        stage('Deploy to ConfigMap') {
            echo "Deploying ConfigMap"
            echo "Project : ${project}"

            openshift.withCluster() {
                openshift.withProject(project) {

                    def configmap_name  = sh(returnStdout: true, script: "echo ${config_file} | sed 's/\\./-/'").trim()
                    echo "configmap_name : ${configmap_name}"
                    sh(returnStdout: true, script: "echo ${config_file}")
                    sh "oc create configmap ${configmap_name} --from-file=proxy.conf=${config_file}"
                    

                }
            }
            echo "Deploying ConfigMap : FINISHED"
        }

    }
}


