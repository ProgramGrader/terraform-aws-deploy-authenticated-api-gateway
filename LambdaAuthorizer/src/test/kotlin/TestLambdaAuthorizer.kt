import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import model.AuthPolicy
import model.PolicyDocument
import model.Statement

import org.junit.jupiter.api.Test

class TestLambdaAuthorizer {

    @Test
    fun `LambdaAuth Failure`()
    {

        val request = APIGatewayCustomAuthorizerEvent()
        request.methodArn = "arn:aws:execute-api:us-east-1:123456789012:example/prod/POST/{proxy+}"
        request.httpMethod = "GET"
        request.resource = "input.resource"
        val headerMap = mutableMapOf<String,String>()
        headerMap["authorizationToken"] = "badtoken"
        request.headers = headerMap
        val context = DummyContext()
        val lambdaResponse = LambdaAuthorizer().handleRequest(request, context)

        val testResponse = AuthPolicy(
        principalId = "0",
        policyDocument = PolicyDocument(
            version = "2012-10-17",
            statement = listOf(
                Statement(
                    action = "execute-api:Invoke",
                    effect = "Deny",
                    resource = request.methodArn!!
                )
            )
        )
    )
        assert(lambdaResponse == testResponse)

    }
}
