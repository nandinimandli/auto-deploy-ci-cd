pipeline {
  agent any
  environment {
    AWS_REGION = 'ap-south-1'
    SONAR_TOKEN = credentials('SONAR_TOKEN')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/nandinimandli/auto-deploy-ci-cd.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        sh 'sonar-scanner -Dsonar.projectKey=myapp -Dsonar.host.url=http://13.235.55.173:9000 -Dsonar.login=$SONAR_TOKEN'
      }
    }

    stage('Docker Build & Push') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_ECR_CREDENTIAS']]) {
          sh '''
          docker build -t 102080400969.dkr.ecr.ap-south-1.amazonaws.com/expense-backend:latest backend/
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 102080400969.dkr.ecr.ap-south-1.amazonaws.com
          docker push 102080400969.dkr.ecr.ap-south-1.amazonaws.com/expense-backend:latest
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_ECR_CREDENTIAS']]) {
          sh '''
          aws eks update-kubeconfig --region ap-south-1 --name auto-deploy-eks
          kubectl apply -f k8s/
          '''
        }
      }
    }
  }
}
