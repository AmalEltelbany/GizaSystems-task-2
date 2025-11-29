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
                echo 'Building and deploying using Ansible (which calls build.sh)...'
                sh 'cd ${ANSIBLE_DIR} && ansible-playbook petclinic.yml'
            }
        }

        stage('Verify') {
            steps {
                echo 'Running sanity checks...'
                sh '''
                    sleep 15
                    curl -f http://localhost:9090/petclinic/ || exit 1
                    echo "Deployment verified successfully!"
                '''
            }
        }
    }

    post {
        always {
            sh '''
                export JAVA_HOME=/home/pet-clinic/java/jdk-17.0.9
                export CATALINA_HOME=/home/amal/devops/tomcat
                $CATALINA_HOME/bin/startup.sh || true
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}