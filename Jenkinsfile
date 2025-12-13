pipeline {
    agent any
    environment {
        TF_VAR_gcp_project = "qwiklabs-gcp-01-181733942d80"
    }
    stages {
        stage("Configure Cluster") {
            steps {
                script {
                    dir('terraform') {
                        withCredentials([file(credentialsId: 'gcp_credentials', variable:'GCP_CREDENTIALS')]) {
                            sh '''
                            export GOOGLE_APPLICATION_CREDENTIALS=$GCP_CREDENTIALS
                            terraform init
                            terrascan scan -i terraform -t gcp
                            terraform apply -auto-approve
                            '''
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