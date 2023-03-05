import model.Config
import org.junit.jupiter.api.Test

class TestConfig {
    @Test
    fun `Config build function Success`()
    {
        val path = "src/main/resources/config.json"
        val config = Config.builder().build(path)
        val actualAPIARN= "arn:aws:sns:us-east-2:048962136615:status" //replace with actual api arn
        assert(config?.API_ARN == actualAPIARN )
    }
}