// SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: MIT

pipeline {
    agent {
        label 'docker'
    }
    // Define HOME environment for every stage separately to avoid clashes with the vscode containers
    options {
        gitlabBuilds(builds: [
            'Install dependencies',
            'Audit dependencies',
            'Generate JSON Schemas',
            'Validate OpenAPI',
            'Build OpenAPI UI'
            ])
    }
    stages {
        stage("uc-hub-api") {
            agent {
                dockerfile {
                    dir './'
                    label 'docker'
                    reuseNode true
                    additionalBuildArgs  '\
                        --build-arg=USER_UID=$(id -u) \
                        --build-arg=USER_GID=$(id -g) \
                    '
                }
            }
            environment {
                HOME = '/home/node'
            }
            stages {
                stage('Install dependencies') {
                    steps {
                        gitlabCommitStatus(name:"$STAGE_NAME") {
                            sh 'npm ci'
                        }
                    }
                }
                stage('Audit dependencies') {
                    // Handle production and dev dependencies differently.
                    // Because dev dependencies will not end up in the final dist they will not fail the build.
                    steps {
                        gitlabCommitStatus(name:"$STAGE_NAME") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                sh 'npm audit --audit-level=high'
                            }
                            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                                sh 'npm audit --audit-level=high --omit=dev'
                            }
                        }
                    }
                }
                stage ('Generate JSON Schemas'){
                    steps {
                        gitlabCommitStatus(name:"$STAGE_NAME") {
                            sh 'npm run generateJsonSchemas'
                        } 
                    }
                }
                stage ('Validate OpenAPI'){
                    steps {
                        gitlabCommitStatus(name:"$STAGE_NAME") {
                            sh 'npm run validateOpenApi'
                        } 
                    }
                }
                stage ('Build OpenAPI UI'){
                    steps {
                        gitlabCommitStatus(name:"$STAGE_NAME") {
                            sh 'npm run generateOpenApiSite'
                        } 
                    }
                }
            }
        }
    }
}
