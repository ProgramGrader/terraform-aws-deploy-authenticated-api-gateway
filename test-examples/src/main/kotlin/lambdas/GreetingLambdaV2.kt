package lambdas


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse
import javax.inject.Named



// https://docs.aws.amazon.com/lambda/latest/dg/java-handler.html
@Named("GreetingLambdaV2")
class GreetingLambdaV2 : RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {
    override fun handleRequest(input: APIGatewayV2HTTPEvent, context: Context): APIGatewayV2HTTPResponse {
        
        val name = input.queryStringParameters["name"]
        val response = APIGatewayV2HTTPResponse()
        response.body = "Hello $name"
        response.statusCode = 200
        return response
    }
}