package model

import com.fasterxml.jackson.annotation.JsonProperty

data class AuthPolicyV2(
    @JsonProperty("isAuthorized")
    val isAuthorized : Boolean
)