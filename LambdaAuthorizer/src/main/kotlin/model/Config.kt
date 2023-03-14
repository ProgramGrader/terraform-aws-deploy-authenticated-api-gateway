package model

import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.ssm.SsmClient
import software.amazon.awssdk.services.ssm.model.GetParameterRequest

class Config() {
    var REGION : String? = null
    var AUTHENTICATOR_KEY: String? = null


    fun build(): Config{
        val config = Config()
        config.AUTHENTICATOR_KEY= getParameter("csgrader-AUTHENTICATION_KEY")
        config.REGION = getParameter("csgrader-REGION")
        return config
    }

    private fun getParameter(parameterName: String): String? {
        val ssmClient = SsmClient.builder()
            .httpClient(software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient.builder().build())
            .region(Region.US_EAST_2)
            .build()
        val request = GetParameterRequest.builder().name(parameterName).build()
        val response = ssmClient.getParameter(request)
        return response.parameter().value()
    }
}
