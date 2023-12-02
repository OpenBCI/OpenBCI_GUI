package org.gradle

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction
import org.gradle.api.provider.Property
import org.gradle.api.file.RegularFileProperty
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.net.URL
import java.io.FileOutputStream
import java.util.zip.ZipFile

abstract class DownloadExtractTask : DefaultTask() {
    @get:Input
    abstract val downloadURL: Property<String>

    @get:Input
    abstract val fileToExtract: Property<String>

    @get:OutputFile
    abstract val destination: RegularFileProperty

    @TaskAction
    fun downloadAndExtract() {
        val destinationDirectory = destination.get().asFile.parentFile
        if (!destinationDirectory.exists()) {
            destinationDirectory.mkdirs()
        }

        val archive = download(destinationDirectory)
        extract(archive)
        archive.delete()
    }

    fun download(destinationDirectory: File) : File
    {
        val url = URL(downloadURL.get())
        val connection = url.openConnection()
        val inputStream: InputStream = connection.getInputStream()
        val outputFile = File(destinationDirectory, "download.zip")
        val outputStream: OutputStream = outputFile.outputStream()

        inputStream.use { input ->
            outputStream.use { output ->
                input.copyTo(output)
            }
        }

        println ("Downloaded ${downloadURL.get()}")
        return outputFile
    }

    fun extract(archive: File) {
        val zipFile = ZipFile(archive)
        
        val file = zipFile.getEntry(fileToExtract.get())
        if (file != null) {
            zipFile.getInputStream(file).use { input ->
                FileOutputStream(destination.get().asFile).use { output ->
                    input.copyTo(output)
                }
            }
            println ("Extracted ${fileToExtract.get()}")
        } 
        else {
            println("File ${fileToExtract.get()} not found in the archive.")
        }
    }
}