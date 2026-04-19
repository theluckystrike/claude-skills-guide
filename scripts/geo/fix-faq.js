#!/usr/bin/env node
/**
 * Fix FAQ section questions — regenerate with smarter question formatting
 * NASA Power of 10 compliant
 */
'use strict';

const fs = require('fs');
const path = require('path');

const LIMITS = { MAX_FILES: 3000, MAX_FAQ: 5, MAX_SECTIONS: 50 };

function assertDefined(val, name) {
  if (val === null || val === undefined) throw new Error(`${name} is ${val}`);
}

function extractH2s(body) {
  assertDefined(body, 'body');
  const regex = /^## (.+)$/gm;
  const headings = [];
  let m;
  let count = 0;
  while ((m = regex.exec(body)) !== null && count < LIMITS.MAX_SECTIONS) {
    const h = m[1].trim();
    if (h !== 'Frequently Asked Questions' && h !== 'Methodology') {
      headings.push(h);
    }
    count++;
  }
  return headings;
}

function makeQuestion(h) {
  if (h.endsWith('?')) return h;
  const lower = h.toLowerCase();

  if (/^(use |set |add |run |fix |get |check |enable |disable |install |configure |implement |create |build |test |debug |deploy |monitor |avoid |break |specify )/i.test(h)) {
    return `How do you ${lower}?`;
  }
  if (/^(why |how |what |when |where |which )/i.test(lower)) {
    return `${h}?`;
  }
  if (/^(common |key |best |top |important |critical |practical )/i.test(lower)) {
    return `What are the ${lower}?`;
  }
  return `What is ${h.replace(/^(The |A |An )/i, '')}?`;
}

function buildFaqBlock(headings) {
  const skipWords = ['Conclusion', 'Summary', 'Related', 'Getting Started',
    'Prerequisites', 'Introduction', 'Overview', 'Next Steps'];

  const questions = [];
  const limit = Math.min(headings.length, LIMITS.MAX_FAQ);
  for (let i = 0; i < limit; i++) {
    if (skipWords.some(w => headings[i].includes(w))) continue;
    questions.push(makeQuestion(headings[i]));
  }
  if (questions.length < 2) return null;

  let block = '\n\n---\n\n## Frequently Asked Questions\n\n';
  const faqLimit = Math.min(questions.length, LIMITS.MAX_FAQ);
  for (let i = 0; i < faqLimit; i++) {
    block += `### ${questions[i]}\n\n`;
    block += `See the dedicated section above for a detailed explanation `;
    block += `covering practical implementation, best practices, and `;
    block += `specific examples relevant to this topic.\n\n`;
  }
  return block;
}

function processFile(filepath) {
  const content = fs.readFileSync(filepath, 'utf8');

  // Only process files that have existing FAQ sections
  if (!/^## Frequently Asked Questions/m.test(content)) return false;

  // Split at FAQ section
  const faqIdx = content.indexOf('\n## Frequently Asked Questions');
  if (faqIdx === -1) return false;

  // Find methodology section after FAQ
  const afterFaq = content.substring(faqIdx);
  const methIdx = afterFaq.indexOf('\n## Methodology');

  let beforeFaq = content.substring(0, faqIdx);
  let afterMeth = '';

  if (methIdx !== -1) {
    afterMeth = afterFaq.substring(methIdx);
  }

  // Remove trailing --- before FAQ if present
  beforeFaq = beforeFaq.replace(/\n---\s*$/, '');

  // Extract headings from the body before FAQ
  const headings = extractH2s(beforeFaq);
  const newFaq = buildFaqBlock(headings);

  if (!newFaq) return false;

  const result = beforeFaq + newFaq + afterMeth;
  fs.writeFileSync(filepath, result, 'utf8');
  return true;
}

function main() {
  const dir = path.resolve(__dirname, '../../articles');
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
  console.log(`[FAQ-FIX] Processing ${files.length} articles`);

  let fixed = 0;
  let skipped = 0;
  const limit = Math.min(files.length, LIMITS.MAX_FILES);

  for (let i = 0; i < limit; i++) {
    const result = processFile(path.join(dir, files[i]));
    if (result) fixed++;
    else skipped++;
    if ((i + 1) % 500 === 0) console.log(`[FAQ-FIX] Progress: ${i + 1}/${limit}`);
  }

  console.log(`[FAQ-FIX] Fixed: ${fixed}, Skipped: ${skipped}`);
}

main();
