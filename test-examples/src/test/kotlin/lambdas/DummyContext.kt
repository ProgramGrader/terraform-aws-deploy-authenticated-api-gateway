package lambdas

import com.amazonaws.services.lambda.runtime.ClientContext
import com.amazonaws.services.lambda.runtime.CognitoIdentity
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.LambdaLogger

// From AWS example docs:
// https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/java-basic/src/test/java/example/TestContext.java

class DummyContext : Context {
    constructor()

    override fun getAwsRequestId() : String {
        return ("test-id")
    }

    override fun getLogGroupName() : String {
        return("main/lambda/my-function")
    }

    override fun getLogStreamName() : String {
        return("It-is-2022")
    }

    override fun getFunctionName() : String {
        return("my-function")
    }

    override fun getFunctionVersion() : String {
        return("TEST")
    }

    override fun getInvokedFunctionArn() : String {
        return("this:is:a:testing:arn")
    }

    override fun getIdentity() : CognitoIdentity? {
        return null
    }

    override fun getClientContext() : ClientContext? {
        return null
    }

    override fun getRemainingTimeInMillis() : Int {
        return 420
    }

    override fun getMemoryLimitInMB() : Int {
        return 69
    }

    override fun getLogger() : LambdaLogger? {
        // Implement LambdaLogger if this causes issues?
        return null
    }
}
