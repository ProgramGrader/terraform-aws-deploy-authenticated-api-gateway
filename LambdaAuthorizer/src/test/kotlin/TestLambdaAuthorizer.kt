import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2CustomAuthorizerEvent
import model.AuthPolicy
import model.PolicyDocument
import model.Statement

import org.junit.jupiter.api.Test

class TestLambdaAuthorizer {

    @Test
    fun `LambdaAuth Failure`()
    {

        //Request set up
        val request = APIGatewayCustomAuthorizerEvent()
        request.methodArn = "arn:aws:execute-api:us-east-1:123456789012:example/prod/POST/{proxy+}"
        request.httpMethod = "GET"
        request.resource = "input.resource"
        val headerMap = mutableMapOf<String,String>()
        headerMap["authorizationToken"] = "badtoken"
        request.headers = headerMap

        // Calling v1 Authorizer
        val context = DummyContext()
        val v1lambdaResponse = APIGatewayV1Authorizer().handleRequest(request, context)
        val testResponsev1 = AuthPolicy(
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
        assert(v1lambdaResponse == testResponsev1 )

    }


    @Test
    fun `LambdaAuth v2 Success` (){
        val request = APIGatewayV2CustomAuthorizerEvent()
        val context = DummyContext()

        request.routeArn = "arn:aws:execute-api:us-east-1:123456789012:example/prod/POST/{proxy+}"
        request.requestContext.http.method = "POST"


        val headerMap= mutableMapOf<String,String>()
        headerMap["Authorization"] = "badtoken"
        request.headers = headerMap
        val testResponsev2 = "{\"isAuthorized\": false}"
        val v2lambdaResponse = APIGatewayV2Authorizer().handleRequest(request, context)
        assert(v2lambdaResponse == testResponsev2 )
    }
}
