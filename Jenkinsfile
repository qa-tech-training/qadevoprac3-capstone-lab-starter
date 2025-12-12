pipeline {
    agent any
    environment {
        TF_VAR_gcp_project = "<your GCP project ID here>" // REPLACE WITH YOUR PROJECT ID FROM QWIKLABS
    }
    stages {
        stage("Configure Cluster") {
            steps {
                script {
                    dir('terraform') {
                        withCredentials([file(credentialsId: 'gcp_credentials', variable:'GCP_CREDENTIALS')]) {
                            // TODO: fill in the steps necessary to:
                            // - initialise terraform
                            // - scan the terraform files
                            // - provision the defined resources
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}