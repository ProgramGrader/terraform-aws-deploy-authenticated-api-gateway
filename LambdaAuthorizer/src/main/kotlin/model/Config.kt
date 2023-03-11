package model

import com.google.gson.Gson
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

class Config() {

     var API_ARN : String? = null
     var REGION : String? = null
     var SECRET_KEY: String? = null
     var ACCOUNT_ID: String? = null


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

    fun findConfigPath(): Path? {
        val possiblePaths = listOf(
            Paths.get("src/main/kotlin/application.conf").toAbsolutePath(), // path to the application.conf for testing env
            Paths.get("application.conf").toAbsolutePath(), // path to the application.conf in image the path of this is defined in docker/DockerFile.native
            // add more possible paths here
        )

        return possiblePaths.firstOrNull { Files.isRegularFile(it) }
    }
}