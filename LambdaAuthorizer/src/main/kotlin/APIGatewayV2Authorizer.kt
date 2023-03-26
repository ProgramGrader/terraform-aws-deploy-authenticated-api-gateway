import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2CustomAuthorizerEvent
import model.AuthPolicy
import model.Config
import model.PolicyDocument
import model.Statement
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest
import javax.inject.Named

@Named("APIGatewayV2Authorizer")
class APIGatewayV2Authorizer: RequestHandler<APIGatewayV2CustomAuthorizerEvent, String> {
    private val config = Config().build()


    /**
     * {
     *   "isAuthorized": true/false,
     *   "context": {
     *     "exampleKey": "exampleValue"
     *   }
     * }
     *
     */

    override fun handleRequest(input: APIGatewayV2CustomAuthorizerEvent?, context: Context?): String {
        val logger = context?.logger


        val denyPolicy = "{\"isAuthorized\": false}"
        val allowPolicy = "{\"isAuthorized\": true}"

        val token = input?.headers?.get("Authorization")

        val secret = getValue(config.AUTHENTICATOR_KEY)

        return if (token != secret) {
            logger?.log(denyPolicy)
            denyPolicy
        }else{
            logger?.log(allowPolicy)
            allowPolicy
        }

    }


    fun getValue(secretName: String?) : String? {

        val valueRequest = GetSecretValueRequest.builder()
            .secretId(secretName)
            .build()

        val secret = SecretsManagerClient.builder()
            .region(Region.of(config.REGION))
            .httpClient((software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient.builder().build()))
            .build()
            .getSecretValue(valueRequest)

        return secret.secretString()
    }
}