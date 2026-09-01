import com.android.build.gradle.BaseExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force consistent JVM 17 targets across all modules (including third-party plugins).
// Required because Kotlin 2.2.x changed its default JVM target to 21 while many
// plugins still compile Java/Kotlin at 1.8/11 — any Java-vs-Kotlin target mismatch
// is a hard error in Gradle 8.x. All team machines run JDK 17 per project setup docs.
//
// The Java target for Android modules is controlled by AGP's android.compileOptions,
// which a plugin sets in its own build script body. We must override it AFTER that
// body runs but BEFORE AGP finalizes the DSL. Registering afterEvaluate here, during
// root configuration, schedules our callback ahead of AGP's own finalization so our
// value wins. We skip already-evaluated projects (e.g. :app, forced early by
// evaluationDependsOn(":app") above) — it already declares JVM 17 itself, and calling
// afterEvaluate on an evaluated project throws.
subprojects {
    if (!state.executed) {
        afterEvaluate {
            extensions.findByType(BaseExtension::class.java)?.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions { jvmTarget.set(JvmTarget.JVM_17) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}