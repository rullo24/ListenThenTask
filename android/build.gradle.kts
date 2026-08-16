allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// vosk_flutter's build.gradle predates AGP's namespace requirement and
// doesn't declare one, which fails the build under AGP 8+. Patch it in
// from its own AndroidManifest.xml package attribute.
subprojects {
    if (project.name == "vosk_flutter") {
        afterEvaluate {
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                ?.let { ext ->
                    if (ext.namespace == null) {
                        ext.namespace = "org.vosk.vosk_flutter"
                    }
                }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
