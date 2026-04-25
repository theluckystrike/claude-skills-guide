---
layout: default
title: "Claude Code Struts to Spring Boot"
description: "A comprehensive guide to migrating legacy Struts applications to Spring Boot using Claude Code skills and automation workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, struts, spring-boot, migration, legacy-modernization]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-struts-to-spring-boot-migration-workflow/
geo_optimized: true
---


Legacy Struts applications served enterprises well for decades, but modern development demands Spring Boot's agility, auto-configuration, and cloud-native capabilities. Migrating from Struts to Spring Boot is complex, requiring careful analysis of Action classes, XML configurations, and JSP views. This guide demonstrates how Claude Code skills transform a tedious manual migration into an automated, reliable workflow.

## Understanding the Migration Challenge

Struts applications typically comprise Action classes extending `ActionSupport`, XML configuration files (`struts.xml`), JSP views, and form beans. Each component requires different transformation strategies:

- Action Classes: Convert to Spring MVC `@Controller` or `@RestController`
- XML Configurations: Replace with Spring annotations and application properties
- Form Beans: Map to Spring `@ModelAttribute` or DTOs
- JSP Views: Modernize with Thymeleaf or keep as JSP with minimal changes

Claude Code excels at analyzing existing codebases, identifying patterns, and generating equivalent Spring Boot implementations. The key lies in using skills that combine code analysis tools with intelligent transformation capabilities.

The typical Struts application carries substantial technical debt. Action classes often accumulate direct database calls, session manipulation, and business logic that was never separated from the web layer. Before writing a single line of migrated code, you need a clear picture of what you are dealing with. Attempting to rewrite without a full inventory leads to missed dependencies, broken functionality, and months of debugging after go-live.

Why Migrate From Struts to Spring Boot?

Organizations resist Struts migrations because existing applications work, the risk is real, and the cost is high. But the technical case for migrating is compelling:

| Concern | Struts 2 | Spring Boot |
|---------|----------|-------------|
| Security patches | Slow, manual CVE tracking | Auto-updates via Spring Security |
| Embedded server | Requires external Tomcat/JEE | Built-in via Tomcat/Jetty/Undertow |
| Configuration | struts.xml + interceptors | Annotation-driven + application.properties |
| Dependency injection | Optional, manual wiring | First-class via Spring IoC |
| Testing | ActionSupport mocking is awkward | MockMvc + @SpringBootTest built in |
| Cloud deployment | WAR-based, inflexible | JAR-based, container-ready |
| Community support | Declining | Active, large ecosystem |

The OGNL expression language vulnerabilities that plagued Struts 2 throughout the 2010s are a persistent reminder that aging frameworks accumulate security surface area faster than teams can patch it. Spring Boot's frequent release cadence and auto-dependency management dramatically reduce that exposure.

## Setting Up Claude Code for Migration

Begin by ensuring Claude Code has the necessary skills set up for comprehensive migration support. Place `code-analysis.md`, `java-expert.md`, and `spring-framework.md` skill files in your `.claude/` directory and invoke them with `/code-analysis`, `/java-expert`, and `/spring-framework`.

These skills provide the foundation for analyzing Java code structures, understanding Spring patterns, and generating migration-aware transformations.

A practical starting prompt sets the project context:

```
/java-expert
I have a Struts 2.5 application at ./src/main/java. It has approximately
40 Action classes, 12 form beans, and 60 JSP views. Help me plan a
phased migration to Spring Boot 3.2 without disrupting the production
deployment cycle.
```

Claude Code responds with a phased plan tailored to your application's size. For a project of this scale, a typical plan covers three phases: inventory and risk assessment, component-by-component conversion with parallel running, and cutover with deprecation of the Struts layer.

## Step 1: Analyzing the Struts Application

The first phase involves inventorying your Struts application structure. Create a migration analysis skill that scans the codebase:

```java
// Analyze Struts Action classes for migration planning
public class StrutsActionAnalyzer {
 public List<ActionMapping> analyzeActions(String basePath) {
 List<ActionMapping> mappings = new ArrayList<>();

 // Scan for Action class files
 FileScanner scanner = new FileScanner();
 List<File> actionFiles = scanner.findFiles(basePath,
 "/*Action.java");

 for (File actionFile : actionFiles) {
 ActionMapping mapping = parseActionClass(actionFile);
 mappings.add(mapping);

 // Identify key migration metrics
 System.out.println("Action: " + mapping.getName());
 System.out.println(" Methods: " + mapping.getMethods());
 System.out.println(" Form Bean: " + mapping.getFormBean());
 }

 return mappings;
 }

 private ActionMapping parseActionClass(File file) {
 // Extract action name, method, result type
 // Analyze dependencies and business logic complexity
 }
}
```

Claude Code can execute this analysis across your entire codebase, generating a comprehensive report mapping each Struts component to its Spring Boot equivalent.

Beyond counting classes, Claude Code identifies the riskiest migration candidates. Actions that manipulate `ActionContext` directly, call `ServletActionContext.getRequest()`, or depend on Struts interceptor chain behavior require more careful handling than simple CRUD actions. Flag these early.

Ask Claude Code to generate a complexity heat map:

```
Analyze each Action class and rate its migration complexity as LOW,
MEDIUM, or HIGH. LOW = simple CRUD with form bean. MEDIUM =
interceptor dependencies or session manipulation. HIGH = direct
OGNL usage, custom interceptor stacks, or dynamic method invocation.
Output as a CSV for project planning.
```

This single analysis step can save weeks of scheduling surprises during the actual migration.

## Step 2: Converting Action Classes

The core transformation converts Struts Action classes to Spring MVC controllers. Claude Code applies pattern recognition to map:

| Struts Component | Spring Boot Equivalent |
|-----------------|------------------------|
| `ActionSupport` | `@Controller` |
| `execute()` method | `@RequestMapping` methods |
| `ActionForward` | View name or `@ResponseBody` |
| `ActionForm` | `@ModelAttribute` DTOs |
| `validate()` method | `@Valid` + `BindingResult` |
| `addActionError()` | `BindingResult.rejectValue()` |
| `getText("key")` | `MessageSource.getMessage()` |
| Interceptors | `HandlerInterceptor` or Spring AOP |

Practical conversion example:

```java
// Struts Original
public class UserAction extends ActionSupport {
 private UserForm userForm;

 public ActionForward execute(ActionMapping mapping,
 ActionForm form,
 HttpServletRequest request,
 HttpServletResponse response) {
 UserService service = new UserService();
 List<User> users = service.findAll();
 request.setAttribute("users", users);
 return mapping.findForward("success");
 }
}

// Spring Boot Converted
@Controller
@RequestMapping("/user")
public class UserController {

 @Autowired
 private UserService userService;

 @GetMapping("/list")
 public String listUsers(Model model) {
 List<User> users = userService.findAll();
 model.addAttribute("users", users);
 return "user/list";
 }
}
```

Claude Code's transformation skills preserve business logic while updating the presentation layer. The skill identifies dependencies requiring injection and rewires the component accordingly.

When the original Action instantiates services with `new UserService()`, Claude Code recognizes this as a candidate for constructor injection and refactors accordingly. This is one of the highest-value transformations because it simultaneously modernizes the code and makes the resulting controller unit-testable without a running application context.

## Handling Validation Migration

Struts validation through XML files (`UserAction-validation.xml`) or `validate()` method overrides translates cleanly to Spring's `@Valid` annotation combined with Bean Validation constraints:

```java
// Struts form bean with manual validation
public class UserForm extends ActionForm {
 private String email;

 @Override
 public ActionErrors validate(ActionMapping mapping,
 HttpServletRequest request) {
 ActionErrors errors = new ActionErrors();
 if (email == null || !email.contains("@")) {
 errors.add("email", new ActionMessage("error.invalid.email"));
 }
 return errors;
 }
}

// Spring Boot DTO with declarative validation
public class UserDto {
 @NotBlank(message = "Email is required")
 @Email(message = "Invalid email format")
 private String email;

 // getters and setters
}

// Controller using @Valid
@PostMapping("/create")
public String createUser(@Valid @ModelAttribute UserDto userDto,
 BindingResult result,
 Model model) {
 if (result.hasErrors()) {
 return "user/form";
 }
 userService.create(userDto);
 return "redirect:/user/list";
}
```

## Step 3: Configuration Migration

Struts XML configurations become Spring Boot's annotation-driven approach. Claude Code parses `struts.xml` and generates equivalent Spring configurations:

```java
// Configuration migration pattern
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

 @Override
 public void addViewControllers(ViewControllerRegistry registry) {
 // Map Struts action forwards to view names
 registry.addViewController("/user/list")
 .setViewName("user/list");
 }

 @Bean
 public InternalResourceViewResolver viewResolver() {
 InternalResourceViewResolver resolver =
 new InternalResourceViewResolver();
 resolver.setPrefix("/WEB-INF/views/");
 resolver.setSuffix(".jsp");
 return resolver;
 }
}
```

For properties previously in `struts.xml`, migrate to `application.properties`:

```properties
Migration of Struts constants
struts.ui.theme=xhtml
struts.convention.result.path=/WEB-INF/views

Spring Boot equivalents
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp
```

## Interceptor Stack Migration

Struts interceptor stacks are one of the trickier migration targets. Common patterns translate as follows:

| Struts Interceptor | Spring Equivalent |
|--------------------|-------------------|
| `TokenInterceptor` (CSRF) | Spring Security CSRF filter |
| `ExecuteAndWaitInterceptor` | `@Async` + `DeferredResult` |
| `FileUploadInterceptor` | `MultipartResolver` bean |
| Custom logging interceptor | `HandlerInterceptorAdapter` |
| Authentication interceptor | Spring Security filter chain |

For custom interceptors containing business logic, Claude Code extracts that logic into `@Aspect` components using Spring AOP, preserving cross-cutting behavior without coupling it to the web layer.

## Step 4: Dependency and Build Migration

Update your build configuration from Struts to Spring Boot dependencies:

```xml
<!-- pom.xml Struts dependencies (remove these) -->
<dependency>
 <groupId>org.apache.struts</groupId>
 <artifactId>struts2-core</artifactId>
 <version>2.5.30</version>
</dependency>

<!-- Spring Boot equivalents (add these) -->
<dependency>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
<dependency>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

Add the Spring Boot parent POM to centralize dependency version management:

```xml
<parent>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-parent</artifactId>
 <version>3.2.4</version>
 <relativePath/>
</parent>
```

Claude Code's build analysis skill identifies all transitive dependencies requiring updates, preventing runtime conflicts that often plague manual migrations. It specifically checks for libraries that Struts brought in transitively. like older Commons libraries. that may conflict with Spring Boot's managed versions.

Ask Claude Code to audit dependency conflicts before you attempt a build:

```
Review the pom.xml and identify any dependencies that may conflict
with spring-boot-starter-parent 3.2.4. Flag commons-fileupload,
freemarker, and OGNL versions specifically.
```

## Step 5: Validation and Testing

The migration workflow concludes with comprehensive validation. Generate test cases that verify functional equivalence:

```java
@SpringBootTest
@AutoConfigureMockMvc
public class UserControllerMigrationTest {

 @Autowired
 private MockMvc mockMvc;

 @Test
 public void testUserListEndpoint() throws Exception {
 mockMvc.perform(get("/user/list"))
 .andExpect(status().isOk())
 .andExpect(view().name("user/list"))
 .andExpect(model().attributeExists("users"));
 }

 @Test
 public void testUserCreateValidationFailure() throws Exception {
 mockMvc.perform(post("/user/create")
 .param("email", "not-an-email"))
 .andExpect(status().isOk())
 .andExpect(model().hasErrors())
 .andExpect(model().attributeHasFieldErrors("userDto", "email"));
 }

 @Test
 public void testUserCreateSuccess() throws Exception {
 mockMvc.perform(post("/user/create")
 .param("email", "user@example.com")
 .param("name", "Test User"))
 .andExpect(status().is3xxRedirection())
 .andExpect(redirectedUrl("/user/list"));
 }
}
```

Run parallel testing comparing Struts and Spring Boot responses to ensure business logic preservation. During the transition period where both stacks run simultaneously, a simple HTTP comparison tool verifies response parity:

```java
// Parallel response validator
public class MigrationValidator {
 private final String strutsBaseUrl;
 private final String springBaseUrl;

 public ValidationResult compare(String path, Map<String, String> params) {
 Response strutsResponse = httpClient.get(strutsBaseUrl + path, params);
 Response springResponse = httpClient.get(springBaseUrl + path, params);

 return ValidationResult.builder()
 .statusMatch(strutsResponse.status() == springResponse.status())
 .bodyMatch(compareResponseBodies(strutsResponse, springResponse))
 .build();
 }
}
```

Claude Code can generate this comparison harness automatically, then run it against a list of all known action URLs extracted from `struts.xml`.

## Handling Edge Cases in Real Applications

Real Struts applications contain patterns that do not map cleanly. Claude Code handles several common edge cases:

Dynamic Method Invocation (DMI): Struts DMI allows URLs like `/user!delete` to call the `delete()` method directly. Spring Boot does not support this pattern. Claude Code converts each DMI endpoint to an explicit `@DeleteMapping` or `@PostMapping` with a separate URL.

Chained Actions: Struts allows one action to forward to another action via the `chain` result type. In Spring Boot, this is replaced with `redirect:` prefixes or service-layer orchestration.

Wildcard Mappings: Struts wildcard action mappings like `<action name="*User" class="UserAction" method="{1}">` require explicit controller method generation. Claude Code identifies each concrete invocation in JSP files and generates the corresponding controller methods.

## Automating the Complete Workflow

Chain these phases into a reproducible Claude Code skill:

```yaml
Migration workflow skill
name: struts-to-spring-boot-migration
description: Automated Struts to Spring Boot migration
```

Execute the complete migration by invoking the skill in a Claude Code session:

```
/struts-to-spring-boot-migration
Source path: ./src/main/java
Target path: ./src/main/java
```

A practical full-session workflow for a medium-sized application looks like this:

1. Run `/code-analysis` to inventory all Action classes and form beans
2. Generate complexity CSV with Claude Code's Java analysis
3. Migrate LOW complexity actions first. validate each in isolation
4. Migrate MEDIUM complexity actions with interceptor mapping
5. Tackle HIGH complexity actions with paired review
6. Run parallel response comparison across all endpoints
7. Switch traffic to Spring Boot, decommission Struts layer

Following this order means you have working Spring Boot controllers handling the majority of traffic before you tackle the complicated cases. Rollback risk decreases with each validated batch.

## Conclusion

Claude Code transforms the daunting Struts to Spring Boot migration from months of manual effort into a structured, automated workflow. By using code analysis, pattern recognition, and intelligent transformation skills, you preserve business logic while modernizing your architecture. The key advantages include consistent code generation, comprehensive dependency management, and built-in validation ensuring functional equivalence.

The most successful migrations treat Claude Code as an experienced pairing partner rather than a code generator. Use it to analyze before transforming, validate after each batch, and generate the tedious boilerplate. test classes, DTO mappings, Spring Security configuration. that slows down manual migrations. Keep your focus on the business logic that only your team fully understands.

Start your migration today by installing the recommended skills and executing the workflow against your legacy Struts applications.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-struts-to-spring-boot-migration-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Spring Boot Microservices Guide](/claude-code-spring-boot-microservices-guide/)
- [Claude Code Backbone.js to Vue Migration Guide](/claude-code-backbone-js-to-vue-migration-guide/)
- [Claude Code for GraphQL to REST Migration Guide](/claude-code-for-graphql-to-rest-migration-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



