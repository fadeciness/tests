pipeline {

    agent any

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [], submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: 'fadeciness',
                        url: 'https://github.com/fadeciness/tests.git'
                    ]]
                ])
            }
        }
        stage('Build') {
            steps {
                echo '========== Build stage! =========='
                sh 'mvn clean compile'
            }
        }
        stage('End') {
            environment {
                PATH_TO_DEPENDENCIES_FILE="pom.xml"
                SCRIPTS_DIR="environment/rb_dev/scripts"
                TIMEOUT_IN_MIN=15
                CORE_SERVICES_ARTIFACT_ID="jenkins-test"
            }
            steps {
                timeout(time: TIMEOUT_IN_MIN, unit: 'MINUTES') {
                    script {
                        simple = sh (
                            script: "cat pom.xml",
                            returnStdout: true
                        ).trim()
                        println(simple)
                        core_services_version = sh (
                            script: "/bin/bash ${SCRIPTS_DIR}/version-detector.sh $CORE_SERVICES_ARTIFACT_ID, $PATH_TO_DEPENDENCIES_FILE",
                            returnStdout: true
                        ).trim()
                        println("core_services_version = " + core_services_version)
                        if (core_services_version != "") {
                            println("SECOND SCRIPT WILL BE")
                            result = sh (
                                script: "/bin/bash $SCRIPTS_DIR/jenkins-job-runner.sh $core_services_version",
                                returnStdout: true
                            ).trim()
                            println(result)
                        }
                    }
                }
            }
        }
    }

}