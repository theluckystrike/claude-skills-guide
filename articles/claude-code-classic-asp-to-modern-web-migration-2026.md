---
title: "Claude Code for Classic ASP to Modern Web Migration (2026)"
permalink: /claude-code-classic-asp-to-modern-web-migration-2026/
description: "Migrate Classic ASP/VBScript applications to modern web frameworks with Claude Code. Convert ADO recordsets, server includes, and inline code."
last_tested: "2026-04-22"
domain: "web migration"
render_with_liquid: false
---

## Why Claude Code for Classic ASP Migration

Classic ASP (Active Server Pages) with VBScript still runs internal portals, HR systems, and reporting dashboards on Windows Server/IIS installations across thousands of organizations. These applications mix VBScript code with HTML, use ADODB recordsets for data access, and rely on server-side includes for code reuse. Microsoft ended mainstream support years ago, and each Windows Server upgrade increases the risk of breaking COM component dependencies.

Claude Code parses the interwoven VBScript/HTML, extracts ADODB connection strings and SQL queries into proper data access layers, and converts the procedural spaghetti into structured MVC or API-based architectures. It understands ASP-specific objects (Request, Response, Server, Session, Application) and maps them to modern equivalents.

## The Workflow

### Step 1: Analyze the Classic ASP Application

```bash
mkdir -p ~/asp-migration/{source,output}

# Inventory ASP files
find /path/to/asp-app -type f \( -name "*.asp" -o -name "*.inc" \) \
  | sort > ~/asp-migration/inventory.txt

# Count key patterns
echo "ADO connections: $(grep -rn 'ADODB.Connection' /path/to/asp-app --include='*.asp' --include='*.inc' | wc -l)"
echo "Recordsets: $(grep -rn 'ADODB.Recordset' /path/to/asp-app --include='*.asp' | wc -l)"
echo "Includes: $(grep -rn '#include' /path/to/asp-app --include='*.asp' | wc -l)"
echo "Session vars: $(grep -rn 'Session(' /path/to/asp-app --include='*.asp' | wc -l)"
echo "Inline SQL: $(grep -rn 'Execute\|CommandText' /path/to/asp-app --include='*.asp' | wc -l)"
```

### Step 2: Convert ASP Pages to Express Routes

Original Classic ASP with inline VBScript:

```asp
<!-- #include file="includes/connection.inc" -->
<!-- #include file="includes/auth_check.inc" -->
<%
Dim rs, sql, searchTerm, pageNum, pageSize

searchTerm = Request.QueryString("q")
pageNum = CInt(Request.QueryString("page"))
If pageNum < 1 Then pageNum = 1
pageSize = 25

' SQL injection vulnerability in original code is common
sql = "SELECT TOP " & pageSize & " emp_id, first_name, last_name, " & _
      "department, hire_date, salary " & _
      "FROM employees " & _
      "WHERE (first_name LIKE '%" & searchTerm & "%' " & _
      "OR last_name LIKE '%" & searchTerm & "%') " & _
      "AND is_active = 1 " & _
      "ORDER BY last_name, first_name"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sql, conn
%>
<html>
<body>
<h1>Employee Search</h1>
<form method="get" action="search.asp">
  <input type="text" name="q" value="<%=Server.HTMLEncode(searchTerm)%>">
  <input type="submit" value="Search">
</form>
<table border="1">
<tr><th>Name</th><th>Department</th><th>Hire Date</th><th>Salary</th></tr>
<% Do While Not rs.EOF %>
<tr>
  <td><%=Server.HTMLEncode(rs("first_name") & " " & rs("last_name"))%></td>
  <td><%=Server.HTMLEncode(rs("department"))%></td>
  <td><%=FormatDateTime(rs("hire_date"), 2)%></td>
  <td><%=FormatCurrency(rs("salary"))%></td>
</tr>
<% rs.MoveNext
Loop
rs.Close
Set rs = Nothing
conn.Close
Set conn = Nothing %>
</table>
</body>
</html>
```

Claude Code generates a secure, separated Express app:

```javascript
// routes/employees.js
const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const { query, validationResult } = require('express-validator');

router.get('/search',
  query('q').optional().isString().trim().escape(),
  query('page').optional().isInt({ min: 1 }).toInt(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const searchTerm = req.query.q || '';
      const page = req.query.page || 1;
      const pageSize = 25;
      const offset = (page - 1) * pageSize;

      // Parameterized query fixes SQL injection from original ASP
      const { rows, rowCount } = await pool.query(`
        SELECT emp_id, first_name, last_name,
               department, hire_date, salary
        FROM employees
        WHERE ($1 = '' OR first_name ILIKE $2 OR last_name ILIKE $2)
          AND is_active = true
        ORDER BY last_name, first_name
        LIMIT $3 OFFSET $4
      `, [searchTerm, `%${searchTerm}%`, pageSize, offset]);

      const countResult = await pool.query(`
        SELECT COUNT(*) as total FROM employees
        WHERE ($1 = '' OR first_name ILIKE $2 OR last_name ILIKE $2)
          AND is_active = true
      `, [searchTerm, `%${searchTerm}%`]);

      res.render('employees/search', {
        employees: rows,
        searchTerm,
        page,
        pageSize,
        totalCount: parseInt(countResult.rows[0].total),
        totalPages: Math.ceil(countResult.rows[0].total / pageSize)
      });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
```

```ejs
<!-- views/employees/search.ejs -->
<h1>Employee Search</h1>
<form method="get" action="/employees/search">
  <input type="text" name="q" value="<%= searchTerm %>">
  <button type="submit">Search</button>
</form>
<table>
  <thead>
    <tr><th>Name</th><th>Department</th><th>Hire Date</th><th>Salary</th></tr>
  </thead>
  <tbody>
    <% employees.forEach(emp => { %>
    <tr>
      <td><%= emp.first_name %> <%= emp.last_name %></td>
      <td><%= emp.department %></td>
      <td><%= new Date(emp.hire_date).toLocaleDateString() %></td>
      <td><%= new Intl.NumberFormat('en-US', {style:'currency', currency:'USD'}).format(emp.salary) %></td>
    </tr>
    <% }) %>
  </tbody>
</table>
```

### Step 3: Convert connection.inc and auth_check.inc

```javascript
// db.js — replaces connection.inc
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000
});
module.exports = { pool };

// middleware/auth.js — replaces auth_check.inc
function requireAuth(req, res, next) {
  if (!req.session?.userId) {
    return res.redirect('/login');
  }
  next();
}
module.exports = { requireAuth };
```

### Step 4: Verify

```bash
cd ~/asp-migration/output
npm install express pg ejs express-session express-validator helmet
npm test

# Compare page output
curl -s "http://old-server/search.asp?q=smith" > /tmp/asp-output.html
curl -s "http://localhost:3000/employees/search?q=smith" > /tmp/node-output.html
diff <(xmllint --html --xpath '//table' /tmp/asp-output.html 2>/dev/null) \
     <(xmllint --html --xpath '//table' /tmp/node-output.html 2>/dev/null)
```

## CLAUDE.md for Classic ASP Migration

```markdown
# Classic ASP to Node.js/Express Migration Standards

## Domain Rules
- Request.QueryString maps to req.query, Request.Form maps to req.body
- Response.Write maps to res.render() with templates
- Server.HTMLEncode maps to EJS auto-escaping (<%= %>)
- Session("key") maps to req.session.key
- Application("key") maps to app.locals.key
- ADODB.Connection maps to pg Pool
- ADODB.Recordset maps to pool.query() results array
- Server.CreateObject maps to require() / npm packages
- All inline SQL must become parameterized queries

## File Patterns
- Source: *.asp, *.inc (server-side includes)
- Target: Express.js + EJS templates + PostgreSQL
- ASP pages: src/routes/ + src/views/
- INC includes: src/middleware/ or src/lib/
- Global.asa: src/app.js (startup/shutdown)

## Common Commands
- npm install express pg ejs express-session helmet
- node --watch src/app.js
- npm test
- npx eslint src/ --fix
```

## Common Pitfalls in Classic ASP Migration

- **SQL injection everywhere:** Classic ASP code routinely concatenates user input into SQL strings. Claude Code replaces every instance with parameterized queries, treating this as the highest-priority fix during migration.

- **COM object dependencies:** ASP apps using Server.CreateObject for Excel, PDF generation, or email (CDO.Message) need npm package replacements. Claude Code maps CDONTS to nodemailer, Excel COM to exceljs, and FileSystemObject to Node.js fs.

- **Session affinity requirements:** Classic ASP sessions are in-process and tied to a single IIS server. Claude Code adds a PostgreSQL or Redis session store to enable horizontal scaling that was impossible with the original architecture.

## Related

- [Claude Code for ColdFusion to Node.js Migration](/claude-code-coldfusion-to-nodejs-migration-2026/)
- [Claude Code for VB6 to .NET Migration](/claude-code-vb6-to-dotnet-migration-2026/)
- [Claude Code for Perl to Python Migration](/claude-code-perl-to-python-migration-2026/)
