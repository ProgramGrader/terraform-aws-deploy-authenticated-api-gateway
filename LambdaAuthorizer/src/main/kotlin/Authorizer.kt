import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import model.AuthorizerResponse
import model.aws.PolicyDocument
import model.aws.Statement

import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest

import java.util.*
import javax.inject.Named
import kotlin.collections.HashMap
@Named("Authorizer")
class Authorizer:RequestHandler<APIGatewayProxyRequestEvent, AuthorizerResponse> {
    private val config = model.Config.builder().build("../resources/application.conf")


    override fun handleRequest(input: APIGatewayProxyRequestEvent?, context: Context?): AuthorizerResponse {
        val headers = input?.headers
        val token = headers?.get("Authorization")
        val proxyContext = input?.requestContext
        var effect = "Allow"
        val ctx = HashMap<String, String>()
        val secret = getValue("BackendKey")

        if(token == secret){
            ctx["message"]=  "Success"
        }else{
            ctx["message"]= "Failed"
            effect = "Deny"
        }

        val statement: Statement = Statement.builder().resource(config?.API_ARN).effect(effect).build()

        val policyDocument: PolicyDocument = PolicyDocument.builder().statements(Collections.singletonList(statement))
            .build()
        return AuthorizerResponse.builder().principalId(proxyContext!!.accountId).policyDocument(policyDocument)
            .context(ctx).build()

    }


     fun getValue(secretName: String?) : String {

        val valueRequest = GetSecretValueRequest.builder()
            .secretId(secretName)
            .build()

        val secret = SecretsManagerClient.builder()
            .region(Region.of(config?.REGION))
            .build()
            .getSecretValue(valueRequest)

        return secret.secretString()
    }

}

