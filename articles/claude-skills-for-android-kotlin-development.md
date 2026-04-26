---
layout: default
title: "Claude Skills For Android Kotlin (2026)"
description: "Use Claude Code skills to accelerate Android development: Jetpack Compose UI, Room databases, Retrofit clients, Espresso testing, and Gradle optimization."
date: 2026-03-20
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, android, kotlin, jetpack-compose, room, retrofit, espresso, gradle]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-skills-for-android-kotlin-development/
geo_optimized: true
---
# Claude Skills for Android and Kotlin Development

Android development involves a lot of boilerplate. Jetpack Compose components, Room DAO interfaces, Retrofit service definitions, Hilt modules, test setup. these are well-structured, predictable patterns that Claude handles well. A few targeted Claude Code skills can eliminate the repetitive scaffolding work and let you focus on product logic.

This guide covers five practical skill areas for Android/Kotlin development, with working examples and guidance on what to include in your skill `.md` files.

## Jetpack Compose UI Generation

Compose's declarative model is a good fit for Claude. The component structure is predictable, the theming system is well-defined, and the patterns for state hoisting are consistent. A `compose` skill can generate complete, functional screen components from a description.

A solid Compose skill prompt includes:

```
When generating Compose UI:
- Use Material3 components (not Material2)
- Follow state hoisting: state lives in the caller, composables receive state and callbacks
- Separate stateful and stateless variants: MyScreenContent() for the stateless composable,
 MyScreen() as the stateful wrapper that provides ViewModel
- Use string resources (stringResource) not hardcoded strings
- Include a @Preview for each composable
- Use Modifier.fillMaxWidth() and proper padding. never hardcode pixel dimensions
```

Example of what a well-formed skill output looks like for a product detail screen:

```kotlin
@Composable
fun ProductDetailContent(
 product: Product,
 onAddToCart: (Product) -> Unit,
 onBackPress: () -> Unit,
 modifier: Modifier = Modifier
) {
 Scaffold(
 topBar = {
 TopAppBar(
 title = { Text(product.name) },
 navigationIcon = {
 IconButton(onClick = onBackPress) {
 Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
 }
 }
 )
 }
 ) { paddingValues ->
 Column(
 modifier = modifier
 .fillMaxSize()
 .padding(paddingValues)
 .padding(horizontal = 16.dp)
 ) {
 AsyncImage(
 model = product.imageUrl,
 contentDescription = product.name,
 modifier = Modifier
 .fillMaxWidth()
 .height(240.dp),
 contentScale = ContentScale.Crop
 )
 Spacer(modifier = Modifier.height(16.dp))
 Text(
 text = product.name,
 style = MaterialTheme.typography.headlineMedium
 )
 Text(
 text = product.description,
 style = MaterialTheme.typography.bodyMedium,
 modifier = Modifier.padding(top = 8.dp)
 )
 Spacer(modifier = Modifier.weight(1f))
 Button(
 onClick = { onAddToCart(product) },
 modifier = Modifier.fillMaxWidth()
 ) {
 Text(stringResource(R.string.add_to_cart))
 }
 }
 }
}

@Preview
@Composable
private fun ProductDetailContentPreview() {
 AppTheme {
 ProductDetailContent(
 product = Product.preview(),
 onAddToCart = {},
 onBackPress = {}
 )
 }
}
```

## Room Database Setup

Room has a specific structure: entities, DAOs, the database class, and type converters. Claude generates all of these correctly when the skill gives it a schema description. The key is telling the skill what to produce and in what order.

Skill instruction pattern for Room:

```
When setting up a Room entity:
1. Create the @Entity data class in data/local/entity/
2. Create the @Dao interface in data/local/dao/
3. Add the entity to the @Database class in data/local/AppDatabase.kt
4. If the field type is not a Room-supported primitive, create a TypeConverter

Use suspend functions for all DAO methods that perform writes.
Use Flow<List<T>> for DAO query methods that should observe changes.
Never use runBlocking in DAO or repository layers.
```

A complete Room DAO for a notes feature:

```kotlin
@Entity(tableName = "notes")
data class NoteEntity(
 @PrimaryKey(autoGenerate = true)
 val id: Long = 0,
 val title: String,
 val body: String,
 val createdAt: Long = System.currentTimeMillis(),
 val updatedAt: Long = System.currentTimeMillis(),
 val isPinned: Boolean = false
)

@Dao
interface NoteDao {
 @Query("SELECT * FROM notes ORDER BY isPinned DESC, updatedAt DESC")
 fun observeAll(): Flow<List<NoteEntity>>

 @Query("SELECT * FROM notes WHERE id = :id")
 suspend fun getById(id: Long): NoteEntity?

 @Insert(onConflict = OnConflictStrategy.REPLACE)
 suspend fun upsert(note: NoteEntity): Long

 @Delete
 suspend fun delete(note: NoteEntity)

 @Query("DELETE FROM notes WHERE id = :id")
 suspend fun deleteById(id: Long)
}
```

The database class update is where most developers make mistakes. Tell the skill to handle it:

```kotlin
@Database(
 entities = [NoteEntity::class],
 version = 2,
 exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
 abstract fun noteDao(): NoteDao

 companion object {
 val MIGRATION_1_2 = object : Migration(1, 2) {
 override fun migrate(database: SupportSQLiteDatabase) {
 database.execSQL(
 "ALTER TABLE notes ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0"
 )
 }
 }
 }
}
```

## Retrofit API Clients

Retrofit service interfaces are highly formulaic. A Claude skill that understands your API conventions can generate a complete service interface, data classes, and a Hilt module in one pass.

Skill instruction pattern:

```
When generating a Retrofit service:
1. Create a sealed Result<T> wrapper if one doesn't exist in data/remote/
2. Create the response data classes in data/remote/model/ using @SerializedName for all fields
3. Create the service interface in data/remote/api/ using suspend functions
4. Create a Hilt module in di/ that provides the Retrofit instance and the service
5. Wrap all network calls in try/catch and return Result.Error for exceptions
```

A working Retrofit setup with error handling:

```kotlin
// data/remote/model/UserResponse.kt
data class UserResponse(
 @SerializedName("id") val id: String,
 @SerializedName("display_name") val displayName: String,
 @SerializedName("avatar_url") val avatarUrl: String?,
 @SerializedName("created_at") val createdAt: String
)

// data/remote/api/UserService.kt
interface UserService {
 @GET("users/{id}")
 suspend fun getUser(@Path("id") id: String): UserResponse

 @PUT("users/{id}")
 suspend fun updateUser(
 @Path("id") id: String,
 @Body request: UpdateUserRequest
 ): UserResponse

 @DELETE("users/{id}")
 suspend fun deleteUser(@Path("id") id: String): Response<Unit>
}

// Repository layer with error handling
class UserRepository @Inject constructor(
 private val userService: UserService
) {
 suspend fun getUser(id: String): Result<User> = runCatching {
 userService.getUser(id).toDomain()
 }.fold(
 onSuccess = { Result.success(it) },
 onFailure = { Result.failure(it) }
 )
}
```

## Testing with Espresso and Robolectric

UI testing in Android is where developers lose the most time. Claude can generate test scaffolding reliably when you constrain the output format.

For Espresso UI tests:

```kotlin
@RunWith(AndroidJUnit4::class)
@HiltAndroidTest
class ProductDetailScreenTest {

 @get:Rule(order = 0)
 val hiltRule = HiltAndroidRule(this)

 @get:Rule(order = 1)
 val composeRule = createAndroidComposeRule<MainActivity>()

 @Before
 fun setUp() {
 hiltRule.inject()
 }

 @Test
 fun addToCart_buttonIsVisible_whenProductLoaded() {
 composeRule.onNodeWithText("Add to Cart").assertIsDisplayed()
 }

 @Test
 fun backButton_navigatesUp_whenPressed() {
 composeRule.onNodeWithContentDescription("Navigate up").performClick()
 composeRule.onNodeWithText("Products").assertIsDisplayed()
 }
}
```

For Robolectric unit tests of ViewModels:

```kotlin
@RunWith(RobolectricTestRunner::class)
class ProductViewModelTest {

 private val fakeRepository = FakeProductRepository()
 private lateinit var viewModel: ProductViewModel

 @Before
 fun setUp() {
 viewModel = ProductViewModel(fakeRepository)
 }

 @Test
 fun `loading state emitted before products arrive`() = runTest {
 val states = mutableListOf<ProductUiState>()
 val job = launch { viewModel.uiState.toList(states) }

 advanceUntilIdle()
 job.cancel()

 assertThat(states.first()).isEqualTo(ProductUiState.Loading)
 }

 @Test
 fun `products displayed after successful load`() = runTest {
 fakeRepository.setProducts(listOf(Product.fixture()))

 val state = viewModel.uiState.filterIsInstance<ProductUiState.Success>().first()

 assertThat(state.products).hasSize(1)
 }
}
```

The skill instruction for testing should include: "Always use a Fake implementation of repositories rather than Mockito mocks in ViewModel tests. Use runTest and advanceUntilIdle for coroutine testing."

## Gradle Build Optimization

Gradle build times are a recurring problem. Claude can audit your `build.gradle.kts` files and apply specific optimizations. A skill for this is more useful than a general prompt because it can be scoped to your project's setup.

Skill instruction:

```
When optimizing Gradle builds:
1. Check gradle.properties for missing performance flags
2. Verify configuration cache is enabled
3. Check for redundant kapt dependencies that can be replaced with KSP
4. Identify modules that should be converted from api() to implementation() deps
5. Check for duplicate dependency declarations across modules
```

A properly optimized `gradle.properties`:

```properties
Build performance
org.gradle.jvmargs=-Xmx4g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.configuration-cache.problems=warn

Android specific
android.useAndroidX=true
android.enableJetifier=false
android.nonTransitiveRClass=true
android.nonFinalResIds=true

Kotlin
kotlin.incremental=true
kotlin.incremental.useClasspathSnapshot=true
kapt.incremental.apt=true
```

KSP migration from kapt for Room and Hilt cuts incremental build time significantly:

```kotlin
// build.gradle.kts. replace kapt with ksp
plugins {
 id("com.google.devtools.ksp") version "2.0.0-1.0.22"
}

dependencies {
 // Room with KSP
 implementation("androidx.room:room-runtime:2.6.1")
 implementation("androidx.room:room-ktx:2.6.1")
 ksp("androidx.room:room-compiler:2.6.1") // was: kapt(...)

 // Hilt with KSP
 implementation("com.google.dagger:hilt-android:2.51")
 ksp("com.google.dagger:hilt-compiler:2.51") // was: kapt(...)
}
```

## Writing the Skill Files

Each of these areas benefits from a dedicated skill `.md` file. Keep each skill focused: a `compose` skill for UI, a `room` skill for database setup, a `retrofit` skill for API clients. Mixing them into a single "android" skill produces lower-quality output because the instructions compete.

Your skill files should live in `.claude/skills/` and include: the specific file naming conventions for your project, your package structure, which Hilt scopes to use, and your target API level constraints. Claude performs significantly better when it knows `minSdk=26` than when it has to guess.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-for-android-kotlin-development)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Full Stack Web App with Claude Skills Step by Step](/full-stack-web-app-with-claude-skills-step-by-step/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

