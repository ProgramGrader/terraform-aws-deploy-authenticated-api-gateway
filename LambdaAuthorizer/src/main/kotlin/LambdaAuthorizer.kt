import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import model.AuthPolicy
import model.Config
import model.PolicyDocument
import model.Statement
import java.util.*
import javax.inject.Named

@Named("LambdaAuthorizer")
class LambdaAuthorizer:RequestHandler<APIGatewayCustomAuthorizerEvent, AuthPolicy> {

   private val configPath = Config().findConfigPath()

    private val config = configPath?.let {
        model.Config.builder().build(it.toString())
    } ?: throw IllegalStateException("Could not find configuration file.")
    override fun handleRequest(input: APIGatewayCustomAuthorizerEvent?, context: Context?): AuthPolicy {
        val logger = context?.logger

        logger?.log("INFO: REGION: ${config.REGION} ")
        logger?.log("INFO: API_ARN: ${config.API_ARN} ")
        logger?.log("INFO: SECRET_TOKEN: ${config.SECRET_KEY} ")
        logger?.log("INFO: ACCOUNT_ID: ${config.ACCOUNT_ID} ")
        logger?.log("INFO: method_arn: ${input?.methodArn} ")
        logger?.log("INFO: RESOURCE_PATH: ${input?.resource} ")
        logger?.log("INFO: method: ${input?.httpMethod} ")

        val allowPolicy = AuthPolicy(
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

        val denyPolicy = AuthPolicy(
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

        val secret = getValue(config.SECRET_KEY)

        return if (token != secret) {
            denyPolicy
        }else
            allowPolicy
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

