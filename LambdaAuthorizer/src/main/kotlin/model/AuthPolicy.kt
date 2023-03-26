package model
import com.fasterxml.jackson.annotation.JsonProperty

data class AuthPolicy(
    @JsonProperty("principalId")
    val principalId: String,
    @JsonProperty("policyDocument")
    val policyDocument: PolicyDocument,
//    @JsonProperty("context")
//    val context: Map<String, Any>,
//    @JsonProperty("usageIdentifierKey")
//    val usageIdentifierKey: String
)

data class PolicyDocument(
    @JsonProperty("Version")
    val version: String,
    @JsonProperty("Statement")
    val statement: List<Statement>
)

data class Statement(
    @JsonProperty("Action")
    val action: String,
    @JsonProperty("Effect")
    val effect: String,
    @JsonProperty("Resource")
    val resource: String
)

