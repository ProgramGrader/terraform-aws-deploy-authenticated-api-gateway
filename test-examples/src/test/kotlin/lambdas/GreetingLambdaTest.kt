import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent
import io.quarkus.test.junit.QuarkusTest
import lambdas.DummyContext
import lambdas.GreetingLambdaV1
import lambdas.GreetingLambdaV2
import org.junit.jupiter.api.Test

class GreetingLambdaTest {
    // private final val localstackImage: DockerImageName = DockerImageName.parse("localstack/localstack:0.11.3");

//    @Rule
//    @JvmField
//    final var localstack: LocalStackContainer = LocalStackContainer(localstackImage)
//        .withServices(LocalStackContainer.Service.DYNAMODB);

    @Test
    fun `Greeting APIGWV1 Success`() {

        val map = mutableMapOf<String,String>()
        map["name"]="Ed"
        val request = APIGatewayProxyRequestEvent().withQueryStringParameters(map)
        val context = DummyContext()
        val response = GreetingLambdaV1().handleRequest(request, context)
        assert(response.statusCode == 200)
    }

    @Test
    fun `Greeting APIGWV2 Success`() {

        val map = mutableMapOf<String,String>()
        map["name"]="Ed"
        val request = APIGatewayV2HTTPEvent.builder().withQueryStringParameters(map).build()
        val context = DummyContext()
        val response = GreetingLambdaV2().handleRequest(request, context)
        assert(response.statusCode == 200)
    }
}