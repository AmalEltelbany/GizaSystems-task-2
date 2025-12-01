pipeline {
    agent any

    environment {
        JAVA_HOME = '/home/pet-clinic/java/jdk-17.0.9'
        MAVEN_HOME = '/home/amal/devops/maven'
        PATH = "${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${env.PATH}"
        ANSIBLE_DIR = '/home/amal/task-02/ansible'
    }

    stages {
        stage('Build and Deploy') {
            steps {
                echo 'Building and deploying using Ansible...'
                sh 'cd ${ANSIBLE_DIR} && ansible-playbook petclinic.yml'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying PetClinic is running...'
                sh '''
                    sleep 15
                    curl -f http://localhost:9090/petclinic/ || exit 1
                    echo "PetClinic is running!"
                '''
            }
        }

        stage('Verify Monitoring') {
            steps {
                echo 'Verifying Nagios monitoring with real plugins...'
                sh '''
                    /usr/lib/nagios/plugins/check_http -H 127.0.0.1 -p 9090
                    /usr/lib/nagios/plugins/check_tcp -H 127.0.0.1 -p 9090
                    echo "Nagios monitoring verified!"
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
