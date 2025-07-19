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
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'AWS_ECR_CREDENTIAS'
        ]]) {
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
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'AWS_ECR_CREDENTIAS',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
          aws eks update-kubeconfig --region ap-south-1 --name auto-deploy-eks

          export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
          export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

          kubectl apply -f k8s/
          '''
        }
      }
    }
  }
}
