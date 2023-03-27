import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2CustomAuthorizerEvent
import model.*
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest
import javax.inject.Named

@Named("APIGatewayV2Authorizer")
class APIGatewayV2Authorizer: RequestHandler<APIGatewayV2CustomAuthorizerEvent, AuthPolicyV2> {
    private val config = Config().build()

    override fun handleRequest(input: APIGatewayV2CustomAuthorizerEvent?, context: Context?): AuthPolicyV2 {
        val logger = context?.logger

        logger?.log(input?.headers.toString())

       // logger?.log(input?.)

        val denyPolicy = AuthPolicyV2(
            isAuthorized = false
        )

        val allowPolicy = AuthPolicyV2(
            isAuthorized = true
        )

        var token = input?.headers?.get("Authorization") // case.. sensitive...
        if (token== null ){
            token = input?.headers?.get("authorization")
        }

        val secret = getValue(config.AUTHENTICATOR_KEY)

        var policy = denyPolicy
        if (token == secret) {
            policy = allowPolicy
        }else
            logger?.log("Failure")

        logger?.log(policy.toString())
        return policy

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