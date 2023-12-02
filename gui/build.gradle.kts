plugins {
    application
}

repositories {
    mavenCentral()
}

dependencies {
    // testImplementation("org.junit.jupiter:junit-jupiter:5.9.1")
    implementation(project(path = ":processing", configuration = "archives"))
}

application {
    mainClass.set("com.openbci.gui.Application")
}

// tasks.named<Test>("test") {
//     useJUnitPlatform()
// }

tasks.named("compileJava") {
    dependsOn(":processing:build")
}

tasks.register("showFiles") {
    dependsOn(":processing:build")
    doLast {
        configurations["compileClasspath"].forEach { file ->
            println(file)
        }
    }
}