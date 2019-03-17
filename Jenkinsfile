pipeline {
    agent any
    stages {
        stage('Set Terraform path') {
 steps {
 script {
 def tfHome = tool name: 'terraform'
 env.PATH = "${tfHome}:${env.PATH}"
 }
 sh 'terraform --version'
 
 }
 }
        stage ('Version'){
            steps{
                echo 'terraform'
                sh 'terraform --version -input=false'
                
            }
        }
               stage('Initialize Terraform') {
      
            steps {
                echo 'Parsing Terraform command'
                sh 'terraform init'
                
            }
        }
        stage('Terraform Plan') {
      
            steps {
                echo 'Terrafrom Plan Command'
                sh 'terraform plan'
                
            }
        }

        stage('Terraform apply') {
           
            steps {
                echo 'Terraform apply command'
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
