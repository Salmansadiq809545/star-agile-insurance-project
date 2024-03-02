node{
    stage('Git Code Checkout')
    {
        git 'https://github.com/Salmansadiq809545/star-agile-insurance-project'
    }
    stage('Maven Compile')
    {
         sh 'mvn compile'
    }
   
   
    stage('Maven Package')
    {
         sh 'mvn clean package'
    }
     stage('Docker Image')
    {
        sh 'docker rmi -f salman8095/insuranceproject:v1'
        
        sh 'docker build -t salman8095/insuranceproject:v1 .'
    }
     stage('Docker push')
    {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-pwd', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh 'docker push salman8095/insuranceproject:v1'
                }
    }
     stage('Ansible')
    {
      ansiblePlaybook become: true, credentialsId: 'ansible', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: 'ansible-playbook.yml', vaultTmpPath: ''
    }
}
