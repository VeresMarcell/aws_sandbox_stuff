pipeline {
    agent any

    stages {
        stage('Build Package') {
            steps {
                sh "cp Function1/Function1.py Function1/lib/python3.8/site-packages/"
                sh "cp Function2/Function2.py Function2/lib/python3.8/site-packages/"
                zip zipFile:'Function1.zip', dir:'Function1/lib/python3.8/site-packages/', overwrite: true
                zip zipFile:'Function2.zip', dir: 'Function2/lib/python3.8/site-packages/', overwrite: true
            }
        }
    }
    post {
        success {
            archiveArtifacts (artifacts: 'Function*.zip',
                allowEmptyArchive: false,
                onlyIfSuccessful: true,
                caseSensitive: true,
                defaultExcludes: true)
            s3Upload consoleLogLevel: 'INFO',
                dontSetBuildResultOnFailure: false,
                dontWaitForConcurrentBuildCompletion: false,
                entries: [
                        [bucket: 'jenkinsgithub2',
                            excludedFile: '',
                            flatten: true,
                            gzipFiles: false,
                            keepForever: false,
                            managedArtifacts: false,
                            noUploadOnFailure: true,
                            selectedRegion: 'us-east-1',
                            showDirectlyInBrowser: false,
                            sourceFile: 'Function1.zip',
                            storageClass: 'STANDARD',
                            uploadFromSlave: false,
                            useServerSideEncryption: false],
                        [bucket: 'jenkinsgithub2',
                            excludedFile: '',
                            flatten: true,
                            gzipFiles: false,
                            keepForever: false,
                            managedArtifacts: false,
                            noUploadOnFailure: true,
                            selectedRegion: 'us-east-1',
                            showDirectlyInBrowser: false,
                            sourceFile: 'Function2.zip',
                            storageClass: 'STANDARD',
                            uploadFromSlave: false,
                            useServerSideEncryption: false]
                        ],
                pluginFailureResultConstraint: 'FAILURE',
                profileName: 'S3_jenkins',
                userMetadata: []
            deployLambda(
                [alias: '',
                artifactLocation: 's3://jenkinsgithub2/Function1.zip',
                awsAccessKeyId: 'AKIAXTXHHCQHXXMXCEGO',
                awsRegion: 'us-east-1',
                awsSecretKey: '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',
                deadLetterQueueArn: '', 
                description: 'Deployed with AWS Lambda Plugin: ${BUILD_ID}', 
                environmentConfiguration: [kmsArn: ''], 
                functionName: 'Function1', 
                handler: 'Function1.zip', 
                memorySize: '1024', 
                role: 'arn:aws:iam::523397174287:role/InvokeOtherLambdaRole', 
                runtime: 'python3.9', 
                securityGroups: '', 
                subnets: '', 
                timeout: '30', 
                updateMode: 'code'
                ]
            )
            deployLambda(
                [alias: '',
                artifactLocation: 's3://jenkinsgithub2/Function2.zip',
                awsAccessKeyId: 'AKIAXTXHHCQHXXMXCEGO',
                awsRegion: 'us-east-1',
                awsSecretKey: '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',
                deadLetterQueueArn: '', 
                description: 'Deployed with AWS Lambda Plugin: ${BUILD_ID}', 
                environmentConfiguration: [kmsArn: ''], 
                functionName: 'Function2', 
                handler: 'Function2.zip', 
                memorySize: '1024', 
                role: 'arn:aws:iam::523397174287:role/service-role/Function2-role-d9awkhb5', 
                runtime: 'python3.9', 
                securityGroups: '', 
                subnets: '', 
                timeout: '30', 
                updateMode: 'code'
                ]
            )
        }
    }
}
