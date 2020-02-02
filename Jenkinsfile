pipeline {
    agent {
        label "master"
    }
    stages {
        stage("Invoking Guix") {
            steps {
                script {
                    sh "cp /srv/archive/DoorKickers/gog_door_kickers_2.7.0.11.sh ${WORKSPACE}/"
                    def drv = sh (script: "guix build --system=i686-linux -f ./guix.scm",
                                  returnStdout: true).trim()
                    sh "guix install ${drv}"
                }
            }
        }
    }
    post {
        always {
            sendNotifications currentBuild.result
        }
    }
}
