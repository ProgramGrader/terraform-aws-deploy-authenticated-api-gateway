package model


import org.junit.jupiter.api.Test

class TestConfig {
    @Test
    fun `Config build function Success`()
    {
        val path = "src/main/kotlin/application.conf"
        val config = Config.builder().build(path)
        val actualAPIARN= "arn:aws:apigateway:us-east-2::/restapis/jd5qg22ial" //replace with actual api arn
        val actualRegion = "us-east-2"
        val actualSecretKey = "AuthenticatorGateway"
        assert(config?.API_ARN == actualAPIARN  && config.REGION == actualRegion && config.SECRET_KEY == actualSecretKey)
    }
}