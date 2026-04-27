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
    // Fix for "Already Evaluated" by only applying if the project is in the correct state
    if (!project.state.executed) {
        if (project.name != "app") {
            project.evaluationDependsOn(":app")
        }
        
        project.afterEvaluate {
            if (project.hasProperty("android")) {
                val android = project.property("android") as com.android.build.gradle.BaseExtension
                if (android.namespace == null) {
                    android.namespace = "com.cardsnap.${project.name.replace("-", ".")}"
                }
            }
        }
    } else {
        // If already evaluated, attempt to fix namespace immediately
        if (project.hasProperty("android")) {
            val android = project.property("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = "com.cardsnap.${project.name.replace("-", ".")}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
