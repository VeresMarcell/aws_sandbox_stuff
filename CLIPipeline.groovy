pipeline{
    agent any
    
    stages{
        stage('Build Package'){
            steps {
                sh "cp Function1/Function1.py Function1/lib/python3.8/site-packages/"
                sh "cp Function2/Function2.py Function2/lib/python3.8/site-packages/"
                zip zipFile:'Function1.zip', dir:'Function1/lib/python3.8/site-packages/', overwrite: true
                zip zipFile:'Function2.zip', dir: 'Function2/lib/python3.8/site-packages/', overwrite: true
            }
        }
        stage('Upload to S3'){
            steps{
                withAWS(credentials: "S3_jenkins", region: "us-east-1"){
                sh "aws s3 cp --recursive --exclude '*' --include '*.zip' . s3://jenkinsgithub2"
                }
            }
        }
        stage('Deploy to Lambda'){
            steps{
                withAWS(credentials: "S3_jenkins", region: "us-east-1"){
                sh "aws lambda update-function-code --function-name Function1 --s3-bucket jenkinsgithub2 --s3-key Function1"
                sh "aws lambda update-function-code --function-name Function2 --s3-bucket jenkinsgithub2 --s3-key Function2"
                }
            }
        }
    }
}