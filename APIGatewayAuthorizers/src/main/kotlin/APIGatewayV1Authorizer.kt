import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import model.*
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest
import javax.inject.Named


@Named("APIGatewayV1Authorizer")
class APIGatewayV1Authorizer: RequestHandler<APIGatewayCustomAuthorizerEvent, AuthPolicyV1> {

    private val config = Config().build()

    override fun handleRequest(input: APIGatewayCustomAuthorizerEvent?, context: Context?): AuthPolicyV1 {
        val logger = context?.logger

        val allowPolicy = AuthPolicyV1(
            principalId = "1",
            policyDocument = PolicyDocument(
                version = "2012-10-17",
                statement = listOf(
                    Statement(
                        action = "execute-api:Invoke",
                        effect = "Allow",
                        resource = input?.methodArn!!
                    )
                )
            )
        )

        val denyPolicy = AuthPolicyV1(
            principalId = "0",
            policyDocument = PolicyDocument(
                version = "2012-10-17",
                statement = listOf(
                    Statement(
                        action = "execute-api:Invoke",
                        effect = "Deny",
                        resource = input.methodArn!!
                    )
                )
            )
        )

        val token = input.authorizationToken

        val secret = getValue(config.AUTHENTICATOR_KEY)

        return if (token != secret) {
            logger?.log(denyPolicy.toString())
            denyPolicy
        }else{
            logger?.log(allowPolicy.toString())
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