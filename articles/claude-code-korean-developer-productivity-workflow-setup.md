---

layout: default
title: "        "
description: "Claude Code          ."
date: 2026-03-14
last_modified_at: 2026-03-14
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, productivity, workflow, korean-developers, automation, claude-skills]
permalink: /claude-code-korean-developer-productivity-workflow-setup/
reviewed: true
score: 7
---


        

Claude Code           .   Claude Code             .

Claude Code   

Claude Code (Skills)      .           .  ,  ,  ,         .

   YAML     .   , ,    ,     .  Claude        .

```yaml
---
name: code-review
description:     
---
```

            .

     

Claude Code            .      ,       .

       .              .  , , ,        .

      .           . Jest, Mocha, PyTest     ,      .

    API   . RESTful API GraphQL   Swagger/OpenAPI   .         .

practical workflow  

    Claude Code    .       .

1.    

    Claude Code    ,  ,     .    , Claude Code       .         .

```bash
Claude Code    
Invoke skill: /feature-development "   "
```

   Claude Code    ,    ,       .

2.   

         . Claude Code         .    ,  ,      .

   Pull Request       .        ,    Claude Code .

3.  

       . Claude Code          . API ,  diagram, README       .

4.   

  Claude Code       .      ,       .       .

CLAUDE.md    

Claude Code         `CLAUDE.md`.            .        , Claude Code   .

 `CLAUDE.md`  :

```markdown
 
  . Node.js + TypeScript, PostgreSQL, Redis   .

 
- : camelCase, : PascalCase
-  : async/await , Promise  
-  :  AppError   (src/errors/AppError.ts )


-  : Jest,   *.test.ts
-  :   80% 


-        
-  .env.example   
```

   Claude Code         .             .

   PR  

          . Claude Code             .

          .   Conventional Commits    :

```
feat:      
fix:         
refactor:       
```

Pull Request  .    PR   , `git diff`    Claude Code   ,  ,     .  GitHub Actions  PR         .

Git Hooks Claude Code 

pre-commit  Claude Code           .     .

`.git/hooks/pre-commit`    :

```bash
#!/bin/bash
   Claude Code   
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|js|py)$')

if [ -n "$STAGED_FILES" ]; then
  echo "Claude Code    ..."
  #      claude CLI  
  claude -p "   ,  ,    : $STAGED_FILES" --output-format text
fi
```

             .      ,       exit code   .

  

        .             .

 ,  IT-agile       .     ,   ,       .

     Integration . Jira, Confluence, Slack       Claude Code     .

     

Claude Code            .      .

    .        . `CLAUDE.md`       .   " CLAUDE.md       "      .

   . "  ", " "          .          .

    .     .    ,   ,  API       . Claude Code           .

     .   Git  ,    PR      .         .

  

Claude Code            .           .

         .     ,          .



Claude Code         .     ,              .

        .             . Claude Code     .


Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
