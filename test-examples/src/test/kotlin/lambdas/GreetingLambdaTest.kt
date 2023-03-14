import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import io.quarkus.test.junit.QuarkusTest
import lambdas.DummyContext
import lambdas.GreetingLambda
import org.junit.jupiter.api.Test

@QuarkusTest
class GreetingLambdaTest {
    // private final val localstackImage: DockerImageName = DockerImageName.parse("localstack/localstack:0.11.3");

//    @Rule
//    @JvmField
//    final var localstack: LocalStackContainer = LocalStackContainer(localstackImage)
//        .withServices(LocalStackContainer.Service.DYNAMODB);

    @Test
    fun `Greeting Success`() {

        val map = mutableMapOf<String,String>()
        map["name"]="Ed"
        val request = APIGatewayProxyRequestEvent().withQueryStringParameters(map)
        val context = DummyContext()
        val response = GreetingLambda().handleRequest(request, context)
        assert(response.statusCode == 200)
    }
}