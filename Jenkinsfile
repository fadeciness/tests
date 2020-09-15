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
            steps {
                echo '========== End stage! TESTS =========='
            }
        }
    }

}