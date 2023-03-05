package model

import com.google.gson.Gson
import java.io.File
import java.io.IOException

class Config(builder:builder) {
     var API_ARN : String? = null
     var REGION : String? = null

    class builder(){
        private var config: Config? = null
        fun build(configPath: String): Config?{
            val jsonString: String
            try {
                jsonString = File(configPath).readText(Charsets.UTF_8)
            }catch (ioException: IOException){
                ioException.printStackTrace()
                return null
            }
            val gson = Gson()
            config= gson.fromJson(jsonString,Config::class.java)
            return config
        }
    }
}