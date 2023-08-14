pipeline {
	agent any

	environment {
        registryCredential = 'ecr:us-east-1:aws-ecr-creds'
        appRegistry = "187424272464.dkr.ecr.us-east-1.amazonaws.com/tomcat-onlinebookstore"
        registry = "https://187424272464.dkr.ecr.us-east-1.amazonaws.com"
    }

	stages {

		stage('Git Checkout') {
			steps {
				// If we have to clone from orivate git repo
				// git credentialsId: 'github-PAT', branch: 'master', url: 'https://github.com/aravind-etagi/Movie_recommendation_system.git'
				git branch: 'master', url: 'https://github.com/aravind-etagi/onlinebookstore.git'
			}
		}

		stage('Build'){
        	steps{
                sh 'mvn clean install'
            }
        }

		stage('Publish to Artifactory') {
            steps {
				rtUpload (
                 	serverId:"artifactory-server" ,
                	spec: '''{
                		"files": [
							{
								"pattern": "*.war",
								"target": "libs-release-local/"
							}
                    	]
                	}''',
                )
				rtPublishBuildInfo (
                    serverId: "artifactory-server"
                )
            }
        }

        stage('Pull the Artifact') {
            //agent {label 'tomcat-slave-2'}
			// agent {label 'docker-instance'}
            steps {
                rtDownload (
                    serverId: 'artifactory-server',
                    spec: '''{
                        "files": [
                            {
                                "pattern": "libs-release-local/onlinebookstore.war",
                                "target": "onlinebookstore.war"
                            }
                        ]
                    }''',
                )
                // sh 'sudo mv ${WORKSPACE}/onlinebookstore.war /opt/tomcat/apache*/webapps/'
            }                     
        }

		stage('Build App Image') {
    		steps {
				script {
                	dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", ".")
             	}
			}
    	}

		stage('Upload App Image') {
        	steps{
				script {
					docker.withRegistry( registry, registryCredential ) {
						dockerImage.push("$BUILD_NUMBER")
						dockerImage.push('latest')
					}
				}
        	}
     	}

		stage('Deploy image') {
			agent {label 'docker-instance'}
			steps {
				sh 'docker stop --time=0 tomcat-app && docker rm tomcat-app'
				sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 187424272464.dkr.ecr.us-east-1.amazonaws.com'
				sh "docker run -itd -p 8080:8080 --name tomcat-app 187424272464.dkr.ecr.us-east-1.amazonaws.com/tomcat-onlinebookstore:$BUILD_NUMBER"
				sh 'echo "Accplication is deployed at http://$(curl -s ifconfig.me):8080/onlinebookstore/"'
			}
		}
	}
}