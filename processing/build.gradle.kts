plugins {
    base
}

import org.gradle.DownloadExtractTask

val downloadProcessingCoreLibrary by tasks.registering(DownloadExtractTask::class) {
    downloadURL.set("https://github.com/benfry/processing4/releases/download/processing-1293-4.3/processing-4.3-windows-x64.zip")
    fileToExtract.set("processing-4.3/core/library/core.jar")
    destination.set(File("${buildDir}/libs/processing-core.jar"))
}

artifacts {
    add("archives", downloadProcessingCoreLibrary.get().destination)
}