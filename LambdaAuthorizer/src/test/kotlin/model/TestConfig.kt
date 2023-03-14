package model


import org.junit.jupiter.api.Test

class TestConfig {
    @Test
    fun `Config build function Success`()
    {
        val path = "src/main/kotlin/application.conf"
        val config = Config().build()
        val actualRegion ="us-east-2" //replace with actual api arn
        val actualAuthKey = "AuthenticatorGateway"
        assert(config.REGION == actualAuthKey  && config.AUTHENTICATOR_KEY == actualRegion)
    }
}