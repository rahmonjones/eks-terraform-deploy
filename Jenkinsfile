pipeline {
    agent { node { label 'terraform-node' } } 
    parameters {
                choice(name: 'Deployment_Type', choices:['apply','destroy'],description:'The deployment type')
                  }
    environment {
        EMAIL_TO = 'rahmon.jay1@gmail.com'
    }
    stages {
        stage('1.Terraform init') {
            steps {
                echo 'terraform init phase'
                sh 'terraform init'
            }
        }
        stage('2.Terraform plan') {
            steps {
                echo 'terraform plan phase'
                sh 'AWS_REGION=us-west-2 terraform plan'
            }
        }
        stage('3.Manual Approval') {
            input {
                message "Should we proceed?"
                ok "Yes, we should."
                parameters{
                    choice (name: 'Manual_Approval', choices: ['Approve','Reject'], description: 'Approve or Reject the deployment')
                }
            }
             steps {
                echo "Deployment ${Manual_Approval}"
            }          
        }
        stage('4.Terraform Deploy') {              
            steps { 
                echo 'Terraform ${params.Deployment_Type} phase'  
                sh "AWS_REGION=us-west-2 terraform ${params.Deployment_Type} --auto-approve"
                sh("""scripts/update-kubeconfig.sh""")
                sh("""scripts/install_helm.sh""") 
                }
                }
        stage ('5. Email Notification') {
            steps {
               mail bcc: 'rahmon.jay1@gmail.com', body: '''Terraform deployment is completed.
               Let me know if the changes look okay.
               Thanks,
               xplur Systemtech world,
              +44 (077) 693 73196''', cc: 'rahmon.jay1@gmail.com', from: '', replyTo: '', subject: 'Terraform Infra deployment completed!!!', to: 'rahmon.jay1@gmail.com'
                          
               }    
          }
     }       
} 
