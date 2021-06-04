#!groovy

node {

    def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    def SF_USERNAME=env.SF_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    
    def TEST_LEVEL='RunLocalTests'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://test.salesforce.com"


    def toolbelt = tool 'toolbelt'


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
		// Deploy metadata and execute unit tests.
		// -------------------------------------------------------------------------
		stage('Install sfpowerkit'){
		   //bat 'start cmd.exe /c C:\\Users\\geetikakagdiyal\\Salesforce\\June2021\\GitHub Repos\\MyPersonalDevOrg\\sfpowerkit.bat'
		     bat 'call C:\\Users\\geetikakagdiyal\\Salesforce\\June2021\\GitHub Repos\\MyPersonalDevOrg\\sfpowerkit.bat'
		}
		
		stage('Delta changes'){
		   //bat ' mkdir config'
		   bat 'sfdx sfpowerkit:project:diff --revisionfrom d59590465bb02c20527ab81c1825774cbe2e9f5d --revisionto 56d0bf9961f19febdfc6b6f774824a828aa8eb99 --output config'
	    }

			    
		stage('Deploy and Run Tests') {
		    rc = command "${toolbelt}/sfdx force:mdapi:deploy --wait 10 -d config/. --targetusername SFDX --testlevel ${TEST_LEVEL}"
		    if (rc != 0) {
			error 'Salesforce deploy and test run failed.'
		    }
		}


		// -------------------------------------------------------------------------
		// Example shows how to run a check-only deploy.
		// -------------------------------------------------------------------------

		stage('Check Only Deploy') {
		    rc = command "${toolbelt}/sfdx force:mdapi:deploy --checkonly --wait 10 -d config/. --targetusername SFDX --testlevel ${TEST_LEVEL}"
		    if (rc != 0) {
		        error 'Salesforce deploy failed.'
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
