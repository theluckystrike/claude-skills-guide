---
title: "Claude Code for Natural/ADABAS Migration (2026)"
permalink: /claude-code-natural-adabas-migration-2026/
description: "Migrate Software AG Natural/ADABAS applications to modern stacks with Claude Code. Convert Natural programs, maps, and ADABAS DDMs."
last_tested: "2026-04-22"
domain: "mainframe modernization"
render_with_liquid: false
---

## Why Claude Code for Natural/ADABAS Migration

Software AG's Natural programming language and ADABAS database power government agencies, insurance companies, and European enterprises. Natural's 4GL syntax with FIND, READ, and HISTOGRAM statements against ADABAS's inverted-list architecture creates an ecosystem that has no modern equivalent. ADABAS files with periodic groups, multiple-value fields, and super/sub/phonetic descriptors represent a data model that does not map cleanly to SQL. The thousands of Natural maps (screen layouts) and Natural Construct-generated programs compound the migration complexity.

Claude Code understands Natural's statement-based syntax, ADABAS data definition modules (DDMs), and the hierarchical record structure unique to ADABAS. It can generate equivalent SQL schemas that preserve the multi-value and periodic group semantics, and convert Natural programs to Java or Python service layers.

## The Workflow

### Step 1: Export and Catalog Natural Objects

```bash
# Export Natural source using SYSOBJH or Natural Engineer
mkdir -p ~/natural-migration/{source,output,ddms,maps}

# Catalog by object type
echo "Programs: $(find ~/natural-migration/source -name '*.NSP' | wc -l)"
echo "Subprograms: $(find ~/natural-migration/source -name '*.NSN' | wc -l)"
echo "Maps: $(find ~/natural-migration/source -name '*.NSM' | wc -l)"
echo "DDMs: $(find ~/natural-migration/ddms -name '*.NSD' | wc -l)"
echo "Local DAs: $(find ~/natural-migration/source -name '*.NSL' | wc -l)"
echo "Global DAs: $(find ~/natural-migration/source -name '*.NSG' | wc -l)"
echo "Copycode: $(find ~/natural-migration/source -name '*.NSC' | wc -l)"
```

### Step 2: Convert ADABAS DDMs to SQL Schemas

ADABAS DDM with periodic groups and MU fields:

```
DB: 055  FILE: 012  - EMPLOYEES                 DDM: EMPLOYEES
TYPE  LEVEL  NAME           FORMAT  SUPPRESSION  DESCRIPTOR
--    --     ----           ------  -----------  ----------
      1      EMPLOYEE-REC
      2      PERSONNEL-ID    A8                   DE,UQ
      2      FIRST-NAME      A20                  DE
      2      LAST-NAME       A30                  DE
      2      DEPARTMENT      A6                   DE
      2      SALARY          P9.2
      2      HIRE-DATE       D
      2      SKILLS          A30/1:10             MU    /* Multiple-value field */
      2      ASSIGNMENTS                          PE    /* Periodic group */
        3    PROJECT-CODE    A10                  DE
        3    START-DATE      D
        3    END-DATE        D
        3    ROLE            A20
        3    HOURS-WORKED    P7.2
```

Claude Code generates normalized PostgreSQL:

```sql
-- Main entity (ADABAS file level 1-2 fields)
CREATE TABLE employees (
    id              SERIAL PRIMARY KEY,
    personnel_id    VARCHAR(8) NOT NULL UNIQUE,
    first_name      VARCHAR(20) NOT NULL,
    last_name       VARCHAR(30) NOT NULL,
    department      VARCHAR(6),
    salary          NUMERIC(9,2),
    hire_date       DATE
);

-- Multiple-value field (MU) -> separate table
-- ADABAS: SKILLS A30/1:10 (up to 10 occurrences)
CREATE TABLE employee_skills (
    id              SERIAL PRIMARY KEY,
    employee_id     INTEGER NOT NULL REFERENCES employees(id),
    occurrence      SMALLINT NOT NULL,  -- preserves MU index (1-10)
    skill           VARCHAR(30) NOT NULL,
    UNIQUE (employee_id, occurrence)
);

-- Periodic group (PE) -> separate table with occurrence tracking
-- ADABAS: ASSIGNMENTS PE (unbounded occurrences)
CREATE TABLE employee_assignments (
    id              SERIAL PRIMARY KEY,
    employee_id     INTEGER NOT NULL REFERENCES employees(id),
    occurrence      SMALLINT NOT NULL,  -- preserves PE ISN sequence
    project_code    VARCHAR(10) NOT NULL,
    start_date      DATE,
    end_date        DATE,
    role            VARCHAR(20),
    hours_worked    NUMERIC(7,2),
    UNIQUE (employee_id, occurrence)
);

CREATE INDEX idx_emp_dept ON employees(department);
CREATE INDEX idx_emp_name ON employees(last_name, first_name);
CREATE INDEX idx_assign_project ON employee_assignments(project_code);
```

### Step 3: Convert Natural Programs to Python

Original Natural program:

```natural
** EMPSRCH - Employee search by department with skill filter
DEFINE DATA
LOCAL USING EMPLOYEES    /* DDM reference */
LOCAL
  1 #DEPT      (A6)
  1 #SKILL     (A30)
  1 #COUNT     (P5)
  1 #TOTAL-SAL (P11.2)
END-DEFINE

INPUT USING MAP 'SRCHMAP'    /* Screen map input */

RESET #COUNT #TOTAL-SAL

FIND EMPLOYEES WITH DEPARTMENT = #DEPT
                 SORTED BY LAST-NAME
  IF #SKILL NE ' '
    FIND(1) EMPLOYEES WITH PERSONNEL-ID = PERSONNEL-ID
                       AND SKILLS = #SKILL
      IF *NUMBER = 0 ESCAPE TOP
    END-FIND
  END-IF

  ADD 1 TO #COUNT
  ADD SALARY TO #TOTAL-SAL

  DISPLAY PERSONNEL-ID FIRST-NAME LAST-NAME SALARY
END-FIND

IF #COUNT GT 0
  WRITE / 'Total employees:' #COUNT
  WRITE   'Average salary: ' #TOTAL-SAL / #COUNT
ELSE
  WRITE 'No employees found'
END-IF

END
```

Claude Code converts:

```python
# services/employee_search.py
from dataclasses import dataclass
from decimal import Decimal
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession
from models import Employee, EmployeeSkill

@dataclass
class SearchResult:
    employees: list
    count: int
    avg_salary: Decimal | None

async def search_employees(
    session: AsyncSession,
    department: str,
    skill: str | None = None
) -> SearchResult:
    """Employee search by department with optional skill filter.
    Converted from Natural program EMPSRCH."""

    # Base query: FIND EMPLOYEES WITH DEPARTMENT = #DEPT
    query = select(Employee).where(
        Employee.department == department
    ).order_by(Employee.last_name)  # SORTED BY LAST-NAME

    # Skill filter: nested FIND with SKILLS = #SKILL
    if skill and skill.strip():
        skill_subq = (
            select(EmployeeSkill.employee_id)
            .where(EmployeeSkill.skill == skill)
        )
        query = query.where(Employee.id.in_(skill_subq))

    result = await session.execute(query)
    employees = result.scalars().all()

    count = len(employees)
    total_salary = sum(e.salary for e in employees if e.salary)
    avg_salary = (total_salary / count) if count > 0 else None

    return SearchResult(
        employees=[{
            'personnel_id': e.personnel_id,
            'first_name': e.first_name,
            'last_name': e.last_name,
            'salary': e.salary
        } for e in employees],
        count=count,
        avg_salary=avg_salary
    )
```

### Step 4: Verify

```bash
# Run migration parity tests
cd ~/natural-migration/output
python3 -m pytest tests/test_ddm_migration.py -v
python3 -m pytest tests/test_program_parity.py -v

# Verify record counts match
python3 scripts/verify_counts.py --adabas-report counts.txt --pg-db migrated_db

# Check periodic group occurrence preservation
psql -d migrated_db -c "
  SELECT e.personnel_id, COUNT(a.id) as assignment_count
  FROM employees e
  JOIN employee_assignments a ON e.id = a.employee_id
  GROUP BY e.personnel_id
  ORDER BY assignment_count DESC
  LIMIT 10;"
```

## CLAUDE.md for Natural/ADABAS Migration

```markdown
# Natural/ADABAS to Python/PostgreSQL Migration Standards

## Domain Rules
- ADABAS files map to PostgreSQL tables
- Multiple-value fields (MU) map to one-to-many child tables with occurrence column
- Periodic groups (PE) map to one-to-many child tables with occurrence column
- FIND statement maps to SELECT with WHERE
- READ PHYSICAL maps to sequential scan (avoid in production)
- HISTOGRAM maps to SELECT DISTINCT or GROUP BY
- Natural maps (NSM) map to API endpoints or web forms
- Descriptors (DE) map to PostgreSQL indexes
- Super-descriptors map to composite indexes
- Sub-descriptors map to partial indexes or expression indexes

## File Patterns
- Source: *.NSP (programs), *.NSN (subprograms), *.NSM (maps)
- Source: *.NSD (DDMs), *.NSL (local DA), *.NSG (global DA)
- Target: Python (FastAPI + SQLAlchemy + PostgreSQL)
- Natural programs: src/services/
- DDMs: src/models/ (SQLAlchemy models)
- Maps: src/routes/ (API endpoints)

## Common Commands
- python3 -m alembic revision --autogenerate -m "from_ddm"
- python3 -m alembic upgrade head
- python3 -m pytest tests/ -v
- uvicorn main:app --reload
```

## Common Pitfalls in Natural/ADABAS Migration

- **Periodic group ordering:** ADABAS periodic groups maintain insertion order by ISN. Claude Code preserves this with an explicit `occurrence` column and enforces ordering in all queries to match the original ADABAS behavior.

- **ADABAS FIND with COUPLED files:** Natural FIND with coupled files creates implicit joins across ADABAS files. Claude Code translates these into explicit SQL JOINs with proper foreign key relationships.

- **Natural ESCAPE logic:** Natural's ESCAPE TOP, ESCAPE BOTTOM, and ESCAPE ROUTINE have different scope behaviors than break/continue/return. Claude Code maps each escape level to the correct Python control flow construct.

## Related

- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Mainframe REXX Modernization](/claude-code-mainframe-rexx-modernization-2026/)
- [Claude Code for RPG AS/400 Modernization](/claude-code-rpg-as400-modernization-2026/)
