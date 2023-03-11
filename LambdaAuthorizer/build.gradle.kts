plugins {
    kotlin("jvm") version "1.7.22"
    kotlin("plugin.allopen") version "1.7.22"
    id("io.quarkus")
    id("org.graalvm.buildtools.native") version "0.9.19"
}

repositories {
    mavenCentral()
    mavenLocal()
}

val quarkusPlatformGroupId: String by project
val quarkusPlatformArtifactId: String by project
val quarkusPlatformVersion: String by project

dependencies {
    implementation(enforcedPlatform("${quarkusPlatformGroupId}:${quarkusPlatformArtifactId}:${quarkusPlatformVersion}"))
    implementation("io.quarkus:quarkus-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    implementation("io.quarkus:quarkus-arc")
    implementation("io.quarkus:quarkus-amazon-lambda")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.9.8")
    implementation("io.jsonwebtoken:jjwt:0.9.1")
    implementation("com.google.code.gson:gson:2.8.9")
    implementation("io.quarkiverse.amazonservices:quarkus-amazon-secretsmanager:1.4.0")
    implementation("software.amazon.awssdk:url-connection-client:2.19.13")
    testImplementation("io.quarkus:quarkus-junit5")
}

group = "authorizer"
version = "1.0.0-SNAPSHOT"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

tasks.withType<Test> {
    systemProperty("java.util.logging.manager", "org.jboss.logmanager.LogManager")
}
allOpen {
    annotation("javax.ws.rs.Path")
    annotation("javax.enterprise.context.ApplicationScoped")
    annotation("io.quarkus.test.junit.QuarkusTest")
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions.jvmTarget = JavaVersion.VERSION_17.toString()
    kotlinOptions.javaParameters = true
}

graalvmNative {
    binaries.all{
        resources.autodetect()
    }
    toolchainDetection.set(false)

}