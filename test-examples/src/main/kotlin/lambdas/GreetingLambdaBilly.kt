package lambdas


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent
import javax.inject.Named



// https://docs.aws.amazon.com/lambda/latest/dg/java-handler.html
@Named("GreetingLambdaBilly")
class GreetingLambdaBilly : RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    override fun handleRequest(input: APIGatewayProxyRequestEvent, context: Context): APIGatewayProxyResponseEvent {
        
        val name = input.queryStringParameters["name"]
        return APIGatewayProxyResponseEvent()
            .withBody("Hello $name")
            .withStatusCode(200)
    }
}