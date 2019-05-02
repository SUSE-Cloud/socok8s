pipeline {

    options {
        timestamps()
        timeout(time: 45, unit: 'MINUTES', activity: true)
    }

    agent {
        node {
            label "cloud-ccp-ci"
        }
    }
    environment {
        /* use lowercase SOCOK8S_ENVNAME. CaaSP Velum doesn't like it otherwise */
        SOCOK8S_ENVNAME = "cloud-socok8s-${env.BRANCH_NAME.toLowerCase()}-${env.BUILD_NUMBER}"
        OS_CLOUD = "engcloud-cloud-ci"
        KEYNAME = "engcloud-cloud-ci"
        DELETE_ANYWAY = "YES"
        SOCOK8S_DEVELOPER_MODE = "True"
        DEPLOYMENT_MECHANISM = "openstack"
        ANSIBLE_STDOUT_CALLBACK = "yaml"
    }

    stages {
        stage('Show environment information') {
            steps {
                sh 'printenv'
            }
        }

        stage('Deploy everything') {
            steps {
                sh "./run.sh"
            }
        }
    }

    post {
        failure {
            script {
                if (env.hold_instance_for_debug == 'true') {
                    echo "You can reach this node by connecting to its floating IP as root user, with the default password of your image."
                    timeout(time: 3, unit: 'HOURS') {
                        input(message: "Waiting for input before deleting  env ${SOCOK8S_ENVNAME}.")
                    }
                }
            }
        }
        always {
            script {
                sh './run.sh teardown'
            }
        }
    }
}
