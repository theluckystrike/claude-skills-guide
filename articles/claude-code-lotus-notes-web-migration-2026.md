---
title: "Claude Code for Lotus Notes Web Migration (2026)"
permalink: /claude-code-lotus-notes-web-migration-2026/
description: "Migrate Lotus Notes/Domino applications to modern web stacks with Claude Code. Convert NSF databases, LotusScript, and formula language."
last_tested: "2026-04-22"
domain: "legacy modernization"
render_with_liquid: false
---

## Why Claude Code for Lotus Notes Migration

Lotus Notes (now HCL Domino) applications number in the hundreds of thousands across enterprises, with many organizations running 15-20 year old NSF databases containing critical workflow automation. These apps use LotusScript, @Formula language, and Notes-specific concepts like views, forms, and agents that have no direct equivalent in modern web frameworks. The proprietary document-oriented data model, ACL security, and replication architecture make automated migration nearly impossible.

Claude Code can parse LotusScript agents, convert @Formula computed fields to JavaScript expressions, and restructure the document-based data model into proper relational or document database schemas while preserving the workflow logic that business users depend on.

## The Workflow

### Step 1: Export Notes Design Elements

```bash
# Use Domino Designer DXL export or nsftools
# Install nsftools for command-line NSF access
pip install noteslib  # Python bridge to Notes API

# Export DXL (Domino XML Language) from NSF
mkdir -p ~/notes-migration/dxl ~/notes-migration/output

# Using Domino console command
load convert -e ~/notes-migration/source/app.nsf ~/notes-migration/dxl/

# Inventory design elements
grep -c "<form " ~/notes-migration/dxl/*.xml
grep -c "<view " ~/notes-migration/dxl/*.xml
grep -c "<agent " ~/notes-migration/dxl/*.xml
grep -c "<lotusscript>" ~/notes-migration/dxl/*.xml
```

### Step 2: Convert LotusScript Agents to Node.js Services

Original LotusScript agent:

```vb
Sub Initialize
    Dim session As New NotesSession
    Dim db As NotesDatabase
    Dim view As NotesView
    Dim doc As NotesDocument
    Dim maildoc As NotesDocument

    Set db = session.CurrentDatabase
    Set view = db.GetView("PendingApprovals")
    Set doc = view.GetFirstDocument

    While Not (doc Is Nothing)
        If doc.GetItemValue("Status")(0) = "Pending" Then
            If DateDiff("d", doc.GetItemValue("SubmitDate")(0), Now) > 7 Then
                ' Escalate overdue approvals
                Set maildoc = db.CreateDocument
                maildoc.Form = "Memo"
                maildoc.SendTo = doc.GetItemValue("ApproverEmail")
                maildoc.Subject = "OVERDUE: Approval needed for " & _
                    doc.GetItemValue("RequestTitle")(0)
                maildoc.Body = "This request has been pending for over 7 days."
                Call maildoc.Send(False)

                Call doc.ReplaceItemValue("Status", "Escalated")
                Call doc.ReplaceItemValue("EscalatedDate", Now)
                Call doc.Save(True, False)
            End If
        End If
        Set doc = view.GetNextDocument(doc)
    Wend
End Sub
```

Claude Code generates the equivalent Node.js service:

```javascript
// services/approvalEscalation.js
const { addDays, isPast } = require('date-fns');
const { sendEmail } = require('./emailService');
const { ApprovalRequest } = require('../models/ApprovalRequest');

async function escalateOverdueApprovals() {
  const cutoffDate = addDays(new Date(), -7);

  const overdueRequests = await ApprovalRequest.find({
    status: 'Pending',
    submitDate: { $lt: cutoffDate }
  });

  const results = { escalated: 0, errors: [] };

  for (const request of overdueRequests) {
    try {
      await sendEmail({
        to: request.approverEmail,
        subject: `OVERDUE: Approval needed for ${request.requestTitle}`,
        body: 'This request has been pending for over 7 days.'
      });

      request.status = 'Escalated';
      request.escalatedDate = new Date();
      await request.save();
      results.escalated++;
    } catch (err) {
      results.errors.push({ id: request._id, error: err.message });
    }
  }

  return results;
}

// Scheduled job replacing Notes agent trigger
const cron = require('node-cron');
cron.schedule('0 8 * * *', () => {
  escalateOverdueApprovals()
    .then(r => console.log(`Escalated ${r.escalated} approvals`))
    .catch(err => console.error('Escalation failed:', err));
});

module.exports = { escalateOverdueApprovals };
```

### Step 3: Convert @Formula Computed Fields

```javascript
// Notes @Formula: @If(Status = "Approved" & Amount > 10000;
//   "CFO Review Required"; Status = "Approved";
//   "Proceed"; "Awaiting Approval")
// Converts to:

function computeDisplayStatus(doc) {
  if (doc.status === 'Approved' && doc.amount > 10000) {
    return 'CFO Review Required';
  }
  if (doc.status === 'Approved') {
    return 'Proceed';
  }
  return 'Awaiting Approval';
}

// Notes @Formula: @Trim(@Implode(FirstName : " " : LastName))
function computeFullName(doc) {
  return [doc.firstName, doc.lastName].filter(Boolean).join(' ').trim();
}
```

### Step 4: Migrate ACL to Role-Based Access

```javascript
// Notes ACL levels map to RBAC roles
const NOTES_ACL_MAP = {
  'Manager':    ['admin', 'editor', 'reader'],
  'Designer':   ['admin', 'editor', 'reader'],
  'Editor':     ['editor', 'reader'],
  'Author':     ['author', 'reader'],  // can only edit own docs
  'Reader':     ['reader'],
  'Depositor':  ['creator'],
  'No Access':  []
};

// Notes Reader/Author fields become row-level security
const rowLevelPolicy = {
  read: (user, doc) =>
    !doc.readers?.length || doc.readers.includes(user.name),
  edit: (user, doc) =>
    !doc.authors?.length || doc.authors.includes(user.name)
};
```

### Step 5: Verify

```bash
# Compare document counts
echo "Notes docs: $(grep -c '<document ' ~/notes-migration/dxl/data.xml)"
echo "Migrated docs: $(node -e "
  const m = require('mongoose');
  m.connect(process.env.MONGO_URI).then(async () => {
    const count = await m.connection.db.collection('approvals').countDocuments();
    console.log(count); process.exit(0);
  });
")"

# Run integration tests
cd ~/notes-migration/output
npm test -- --grep "migration parity"
```

## CLAUDE.md for Lotus Notes Migration

```markdown
# Lotus Notes to Web App Migration Standards

## Domain Rules
- Every Notes Form maps to one Mongoose model + one Express route
- Notes Views map to MongoDB indexes + API list endpoints
- LotusScript agents map to scheduled Node.js jobs (node-cron)
- @Formula computed fields map to Mongoose virtuals or pre-save hooks
- Reader/Author fields map to row-level security middleware
- Rich Text fields require conversion via DXL to HTML

## File Patterns
- Source: *.nsf, *.dxl, *.lss (LotusScript libraries)
- Target: Node.js/Express with MongoDB (closest to document model)
- Forms: src/models/ (Mongoose schemas)
- Views: src/routes/ (Express endpoints with query params)
- Agents: src/jobs/ (scheduled tasks)

## Common Commands
- load convert -e database.nsf output/
- grep -c "<form " export.dxl
- node scripts/migrate-documents.js --source dxl/ --target mongodb
- npm run test:migration-parity
- mongosh --eval "db.stats()"
```

## Common Pitfalls in Lotus Notes Migration

- **Rich Text field complexity:** Notes Rich Text contains embedded objects, doclinks, file attachments, and computed subforms. Claude Code strips these into clean HTML with attachment references rather than attempting pixel-perfect conversion.

- **Response document hierarchies:** Notes parent-response relationships do not map cleanly to foreign keys. Claude Code models these as nested references with a `parentId` field and recursive query helpers.

- **Replication and conflict documents:** Notes replication creates conflict documents that must be resolved during migration. Claude Code generates a conflict resolution script that picks the most recently modified version.

## Related

- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for ColdFusion to Node.js Migration](/claude-code-coldfusion-to-nodejs-migration-2026/)
- [Claude Code for Classic ASP to Modern Web Migration](/claude-code-classic-asp-to-modern-web-migration-2026/)
