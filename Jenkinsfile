#!groovy

node {

    def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    def SF_USERNAME=env.SF_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    def DEPLOYDIR='.'
    
    //def TEST_LEVEL='RunLocalTests'
    def TEST_LEVEL='RunSpecifiedTests'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://test.salesforce.com"


    def toolbelt = tool 'toolbelt'

    stage('Clean Workspace') {
        try {
            deleteDir()
        }
        catch (Exception e) {
            println('Unable to Clean WorkSpace.')
        }
    }
    // -------------------------------------------------------------------------
    // Check out code from source control.
    // -------------------------------------------------------------------------

    stage('checkout source') {
        checkout scm
    }


    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------

 	withEnv(["HOME=${env.WORKSPACE}"]) {	
	
	    withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'server_key_file')]) {
		// -------------------------------------------------------------------------
		// Authenticate to Salesforce using the server key.
		// -------------------------------------------------------------------------

		stage('Authorize to Salesforce') {
			rc = command "${toolbelt}/sfdx auth:jwt:grant --instanceurl ${SF_INSTANCE_URL} --clientid ${SF_CONSUMER_KEY} --jwtkeyfile ${server_key_file} --username ${SF_USERNAME} --setalias SFDX"
		    if (rc != 0) {
			error 'Salesforce org authorization failed.'
		    }
		}


		// -------------------------------------------------------------------------
		// Generate metadata.
		// -------------------------------------------------------------------------
		stage('Install sfpowerkit'){
			bat 'sfpowerkit.bat'
		}
		// -------------------------------------------------------------------------
		// Install sfpowerkit.
		// -------------------------------------------------------------------------
		stage('Delta changes'){
		   //bat ' mkdir config'
		   bat 'sfdx sfpowerkit:project:diff --revisionfrom %PreviousCommitId% --revisionto %LatestCommitId% --output DeltaChanges'
		   //bat 'sfdx sfpowerkit:project:diff --revisionfrom 5baec5ec4bb213ff615946d21ca108cd3c8ea965 --revisionto 8649a5eca981ece8e869bb73c7d84eecce7a79c6 --output config'
	    }
           
	     // -------------------------------------------------------------------------
	    // Example shows how to run a check-only deploy.
	   // -------------------------------------------------------------------------

		stage('Check Only Deploy') {
			rc = command "${toolbelt}/sfdx force:source:deploy -p config/force-app --checkonly --wait 10 --targetusername SFDX --testlevel ${TEST_LEVEL} -r BatchLeadConvertTest,InstallationTests --verbose --loglevel fatal"
		    //rc = command "${toolbelt}/sfdx force:source:deploy --deploydir ${DEPLOYDIR} --checkonly --wait 10 --targetusername SFDX --testlevel ${TEST_LEVEL}"
		      //rc = command "${toolbelt}/sfdx force:source:deploy -p config/force-app --checkonly --wait 10 --targetusername SFDX --testlevel ${TEST_LEVEL}"
		    if (rc != 0) {
		        error 'Salesforce deploy failed.'
		   }
		}
            // -------------------------------------------------------------------------
		// Deploy metadata and execute unit tests.
		// -------------------------------------------------------------------------
			    
		stage('Deploy and Run Tests') {
		    rc = command "${toolbelt}/sfdx force:source:deploy -p config/force-app --wait 10 --targetusername SFDX --testlevel ${TEST_LEVEL} -r BatchLeadConvertTest,InstallationTests --verbose --loglevel fatal"
		    //rc = command "${toolbelt}/sfdx force:source:deploy --deploydir ${DEPLOYDIR} --wait 10 --targetusername SFDX --testlevel ${TEST_LEVEL}"
		    //rc = command "${toolbelt}/sfdx force:source:deploy -l RunLocalTests -c -d ./config --targetusername SFDX -w 10
			
		    if (rc != 0) {
			error 'Salesforce deploy and test run failed.'
		    }
		}


		
	    }
	}
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}
