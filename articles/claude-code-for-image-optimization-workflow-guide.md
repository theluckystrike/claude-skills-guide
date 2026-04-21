---

layout: default
title: "Claude Code Image Optimization Workflow (2026)"
description: "Automate image optimization with Claude Code to batch-compress, resize, and convert to WebP format. Cuts total page weight by 60% in minutes."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
last_tested: "2026-04-21"
permalink: /claude-code-for-image-optimization-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---



Image optimization is a critical yet often tedious task for web developers. Large images slow down your site, hurt SEO rankings, and frustrate users. This guide shows you how to use Claude Code to automate image optimization workflows, saving time while ensuring consistent quality across your project.

Why Automate Image Optimization with Claude Code?

Manual image optimization is repetitive and error-prone. You need to resize images for different breakpoints, convert formats for browser compatibility, compress without visible quality loss, and generate responsive images with srcset. Doing this manually for hundreds of images is unsustainable.

Claude Code can automate the entire pipeline. It can process images in bulk, apply consistent optimization settings, generate multiple variants for responsive design, and integrate with your build process. The key is creating a repeatable workflow that handles your specific requirements.

Beyond pure convenience, the business case for automated image optimization is compelling. Images typically account for 50–70% of a web page's total byte weight. Google's Core Web Vitals metrics. particularly Largest Contentful Paint (LCP) and Cumulative Layout Shift (CLS). are directly impacted by how efficiently images load. Sites that serve unoptimized images routinely score 30–40 points lower on Lighthouse performance audits compared to those with a proper pipeline in place.

The problem is that most teams lack consistent standards. One developer compresses at quality 75, another at 95, a third forgets to add WebP variants altogether. Claude Code enforces your standards programmatically, every single time, without relying on anyone remembering to run a tool.

## Understanding Modern Image Formats

Before building your pipeline, you need to understand the format landscape. Choosing the wrong format is the single biggest optimization mistake teams make.

| Format | Best Use Case | Avg. Size vs JPEG | Browser Support |
|--------|--------------|------------------|-----------------|
| JPEG | Photographs, gradients | baseline | Universal |
| PNG | Logos, screenshots, transparency | larger | Universal |
| WebP | Most web images | -25 to -35% | 97%+ |
| AVIF | High-quality photos, illustrations | -40 to -50% | 90%+ |
| GIF | Simple animations | larger | Universal |
| WebM | Video-like animations | much smaller | 95%+ |

For a modern project built in 2025 or 2026, your defaults should be:

- Serve AVIF as first choice with a WebP fallback and JPEG/PNG as universal fallback
- Use PNG only when you actually need alpha transparency or lossless fidelity
- Replace animated GIFs with WebP animations or short video clips
- Reserve SVG for icons, logos, and anything that needs to scale without pixelation

Claude Code can help you audit an existing project to identify format mismatches. Ask it to scan your assets directory and report any PNG files above 200 KB (probable JPEG candidates), any GIF files (probable video candidates), and any JPEG files missing WebP counterparts.

## Setting Up Your Image Optimization Skill

The first step is creating a Claude skill that encapsulates your optimization logic. Create a file called `.claude/image-optimization.md` in your project:

```markdown
Image Optimization Workflow

This skill automates image processing for web deployment.

Capabilities
- Bulk process images from source directory
- Generate responsive variants (mobile, tablet, desktop)
- Convert to WebP and AVIF formats
- Apply consistent compression settings
- Generate srcset markup for responsive images

Usage
Run the optimization pipeline on all images:
/optimize-images --source ./images/raw --output ./public/assets

Optimize a single image:
/optimize-images --single hero-banner.png --output ./public/assets
```

This skill definition tells Claude what operations it can perform and how to invoke them. It acts as the contract between you and the automation. any developer on the team can read it to understand what the pipeline does and how to trigger it.

You can extend this skill definition with project-specific rules. For example, you might add:

```markdown
Project Rules
- Hero images must have a 1920px max width variant
- All product images require a 400x400 square crop
- Blog thumbnails: 800x450px, 16:9 ratio enforced
- Never enlarge images beyond original dimensions
```

This gives Claude Code enough context to make sensible decisions when processing new image types it hasn't seen before.

## Creating the Optimization Script

Now create the actual processing script that Claude will use. A Node.js script using the `sharp` library provides excellent performance and flexibility:

```javascript
// scripts/optimize-images.js
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const CONFIG = {
 sizes: [320, 640, 960, 1280, 1920],
 formats: ['webp', 'avif', 'jpeg'],
 quality: { webp: 80, avif: 65, jpeg: 85 },
 outputDir: './public/assets'
};

async function optimizeImage(inputPath, outputDir) {
 const filename = path.basename(inputPath, path.extname(inputPath));
 const metadata = await sharp(inputPath).metadata();

 const results = [];

 for (const format of CONFIG.formats) {
 for (const width of CONFIG.sizes) {
 // Skip sizes larger than original to avoid upscaling
 if (width > metadata.width) continue;

 const outputPath = path.join(
 outputDir,
 `${filename}-${width}.${format}`
 );

 let pipeline = sharp(inputPath)
 .resize(width, null, { withoutEnlargement: true })
 .toFormat(format, { quality: CONFIG.quality[format] });

 await pipeline.toFile(outputPath);
 results.push(outputPath);
 }
 }

 // Generate original for compatibility
 await sharp(inputPath)
 .jpeg({ quality: CONFIG.quality.jpeg })
 .toFile(path.join(outputDir, `${filename}-original.jpg`));

 return results;
}

async function batchProcess(inputDir, outputDir) {
 const files = fs.readdirSync(inputDir)
 .filter(f => /\.(jpg|png|gif|webp)$/i.test(f));

 console.log(`Processing ${files.length} images...`);

 for (const file of files) {
 const inputPath = path.join(inputDir, file);
 await optimizeImage(inputPath, outputDir);
 console.log(`Processed ${file}`);
 }
}

module.exports = { optimizeImage, batchProcess };
```

This script generates multiple sizes and formats for each input image, creating the foundation for responsive image delivery.

The `withoutEnlargement: true` flag is important. it prevents sharp from upscaling a 400px image to 1920px, which would create a larger, blurry file. Always respect source dimensions.

## Adding an Audit Mode

Before running full optimization, it helps to run in audit-only mode to understand what will change. Add this function to your script:

```javascript
async function auditImages(inputDir) {
 const files = fs.readdirSync(inputDir)
 .filter(f => /\.(jpg|png|gif|webp|avif)$/i.test(f));

 const report = [];

 for (const file of files) {
 const inputPath = path.join(inputDir, file);
 const stats = fs.statSync(inputPath);
 const metadata = await sharp(inputPath).metadata();

 const issues = [];
 if (stats.size > 500 * 1024) issues.push('oversized (>500KB)');
 if (metadata.width > 2500) issues.push('very wide (>2500px)');
 if (path.extname(file).toLowerCase() === '.gif') issues.push('should convert to WebP animation');

 report.push({
 file,
 sizeKB: Math.round(stats.size / 1024),
 width: metadata.width,
 height: metadata.height,
 format: metadata.format,
 issues
 });
 }

 // Sort by size descending so biggest problems appear first
 report.sort((a, b) => b.sizeKB - a.sizeKB);

 console.table(report);
 return report;
}
```

Running `node scripts/optimize-images.js --audit ./images/raw` before optimization gives you a clear picture of which files will benefit most. This is especially useful when onboarding a legacy codebase with years of accumulated unoptimized assets.

## Generating Responsive Image Markup

Once you have optimized images, you need HTML markup that tells browsers which variants to load. Claude can generate this markup automatically:

```javascript
function generateSrcset(filename, widths = [320, 640, 960, 1280, 1920]) {
 const variants = widths.map(w => {
 const ext = w <= 640 ? 'webp' : 'jpeg';
 return `/assets/${filename}-${w}.${ext} ${w}w`;
 });
 return variants.join(',\n ');
}

function generatePictureElement(imageName, alt, widths = [320, 640, 960, 1280, 1920]) {
 return `<picture>
 <source
 type="image/avif"
 srcset="${generateSrcset(imageName, widths).replace(/\.jpeg/g, '.avif')}">
 <source
 type="image/webp"
 srcset="${generateSrcset(imageName, widths)}">
 <img
 src="/assets/${imageName}-original.jpg"
 alt="${alt}"
 width="${widths[widths.length-1]}"
 height="auto"
 loading="lazy"
 decoding="async">
</picture>`;
}
```

This generates proper `<picture>` elements with multiple sources, letting browsers choose the best format and size for each user.

## Understanding the sizes Attribute

One common mistake is omitting the `sizes` attribute. Without it, the browser defaults to assuming the image fills 100% of the viewport width, and it may download a larger variant than necessary. Add `sizes` to your generated markup:

```javascript
function generatePictureWithSizes(imageName, alt, sizesHint = '(max-width: 768px) 100vw, 50vw') {
 return `<picture>
 <source
 type="image/avif"
 sizes="${sizesHint}"
 srcset="/assets/${imageName}-320.avif 320w,
 /assets/${imageName}-640.avif 640w,
 /assets/${imageName}-960.avif 960w,
 /assets/${imageName}-1280.avif 1280w,
 /assets/${imageName}-1920.avif 1920w">
 <source
 type="image/webp"
 sizes="${sizesHint}"
 srcset="/assets/${imageName}-320.webp 320w,
 /assets/${imageName}-640.webp 640w,
 /assets/${imageName}-960.webp 960w,
 /assets/${imageName}-1280.webp 1280w,
 /assets/${imageName}-1920.webp 1920w">
 <img
 src="/assets/${imageName}-original.jpg"
 alt="${alt}"
 loading="lazy"
 decoding="async">
</picture>`;
}
```

Claude Code can help you determine the right `sizes` value for each image based on its context in the layout. Describe the CSS grid or flex structure the image sits within, and Claude will calculate the appropriate descriptor.

## Integrating with Your Development Workflow

The real power comes from integrating these tools into your daily workflow. Create a Claude command that orchestrates the entire pipeline:

```
/optimize-images --source ./images/raw --output ./public/assets --generate-markup
```

This single command should:
1. Process all images in the source directory
2. Generate responsive variants in multiple formats
3. Create a JSON manifest mapping original names to generated files
4. Output ready-to-use HTML markup for each image

Here's how to implement the command handler:

```javascript
async function handleOptimizeImages(args) {
 const sourceDir = args.source || './images/raw';
 const outputDir = args.output || './public/assets';

 // Ensure output directory exists
 if (!fs.existsSync(outputDir)) {
 fs.mkdirSync(outputDir, { recursive: true });
 }

 // Process all images
 await batchProcess(sourceDir, outputDir);

 // Generate markup if requested
 if (args['generate-markup']) {
 const manifest = generateMarkupManifest(outputDir);
 fs.writeFileSync(
 path.join(outputDir, 'image-manifest.json'),
 JSON.stringify(manifest, null, 2)
 );
 console.log('Generated image-manifest.json');
 }

 console.log('Image optimization complete');
}
```

## Using the Manifest in Templates

The JSON manifest enables template-driven image insertion. A typical manifest entry looks like:

```json
{
 "hero-banner": {
 "original": "/assets/hero-banner-original.jpg",
 "avif": {
 "320": "/assets/hero-banner-320.avif",
 "640": "/assets/hero-banner-640.avif",
 "960": "/assets/hero-banner-960.avif",
 "1280": "/assets/hero-banner-1280.avif",
 "1920": "/assets/hero-banner-1920.avif"
 },
 "webp": {
 "320": "/assets/hero-banner-320.webp",
 "640": "/assets/hero-banner-640.webp"
 },
 "width": 1920,
 "height": 1080,
 "aspectRatio": "16:9"
 }
}
```

Templates in your SSG or CMS can read this manifest to generate correct markup without hard-coding paths. Claude Code can write template helpers for Next.js, Astro, Hugo, Jekyll, or whatever framework you use.

## Framework-Specific Integration

## Next.js

Next.js has a built-in `next/image` component that handles much of this automatically, but you may still want to pre-generate optimized variants for external delivery. Ask Claude Code to generate a custom loader:

```javascript
// lib/imageLoader.js
export default function customLoader({ src, width, quality }) {
 const q = quality || 75;
 return `https://cdn.yoursite.com${src}?w=${width}&q=${q}&fmt=avif`;
}
```

Hugo / Jekyll (Static Sites)

For static site generators, Claude Code can generate a shortcode or include that reads from your manifest file and outputs a complete `<picture>` element with correct paths and attributes.

## Plain HTML

When working with plain HTML sites, Claude Code can do a one-time replacement scan. finding all `<img>` tags and converting them to `<picture>` elements with proper srcset, while also generating the optimized variants.

## Best Practices for Image Optimization

Follow these guidelines for optimal results:

Choose the right formats. Use WebP or AVIF for most photographic content. they offer 25-35% better compression than JPEG. Keep PNG for images with transparency or sharp edges like logos and icons.

Set appropriate quality levels. Quality 75-85 for JPEG provides good balance. WebP at quality 80 is typically indistinguishable from JPEG at 90. AVIF can use lower quality (60-70) while maintaining visual fidelity.

Use responsive images wisely. Generate 4-6 sizes per image. The most important breakpoints are typically 640px (mobile), 1024px (tablet), and 1920px (desktop).

Implement lazy loading. Always add `loading="lazy"` to below-the-fold images. Above-the-fold hero images should load eagerly for Core Web Vitals.

Test your output. Run Lighthouse audits after optimization to verify you're getting the expected performance improvements.

Preserve metadata selectively. By default, strip EXIF data for privacy and file size. But for photography sites or portfolios, You should preserve copyright and camera data. Sharp supports this with the `withMetadata()` option.

Avoid double compression. Never run optimization on already-optimized output files. Keep your source originals in a separate, unoptimized directory and treat the output directory as a build artifact.

## Comparing Optimization Approaches

| Approach | Setup Effort | Ongoing Effort | Consistency | Best For |
|----------|-------------|---------------|-------------|----------|
| Manual (Photoshop/Squoosh) | None | High | Low | Small sites, one-off projects |
| CDN auto-optimization | Medium | Low | High | Sites already using a CDN |
| Build-time script | Medium | None | High | Static sites, JAMstack |
| Claude Code pipeline | Low | None | High | Any project, fastest to set up |
| CI/CD integration | High | None | Very high | Teams, large projects |

Claude Code sits in a sweet spot. quick to set up because you describe what you want in plain English, and highly consistent because the same script runs every time. The CI/CD integration is the next step for larger teams.

## Automating on Commit

Add image optimization to your pre-commit workflow to ensure optimized images never accidentally get committed:

```bash
.git/hooks/pre-commit
npm run optimize-images
git add public/assets/
```

For a more solid setup, use a dedicated git hook manager like Husky:

```json
// package.json
{
 "lint-staged": {
 "images/raw//*.{jpg,png,gif}": [
 "node scripts/optimize-images.js --single",
 "git add public/assets/"
 ]
 }
}
```

This configuration runs optimization only on images that are being committed, rather than the entire directory. much faster for large projects.

## CI/CD Pipeline Integration

For teams, a CI/CD step ensures images are always optimized regardless of local developer setup:

```yaml
.github/workflows/build.yml
- name: Optimize images
 run: |
 npm install sharp
 node scripts/optimize-images.js --source ./images/raw --output ./public/assets

- name: Verify optimization
 run: |
 node scripts/optimize-images.js --audit ./public/assets --fail-on-oversized 200
```

The `--fail-on-oversized` flag causes the CI step to fail if any output image exceeds 200 KB. a useful quality gate that prevents regressions.

## Measuring Results

After deploying your optimized images, measure the impact. Useful metrics to track:

- Total page weight before and after (use Chrome DevTools Network tab)
- Lighthouse Performance score. expect 5-15 point improvements for image-heavy pages
- LCP (Largest Contentful Paint). should drop significantly if the LCP element is an image
- Bytes transferred per session. visible in analytics platforms

A typical e-commerce product page might go from 2.4 MB to 800 KB after proper optimization. a 67% reduction that directly translates to faster load times and better conversion rates, particularly on mobile networks.

## Conclusion

Claude Code makes image optimization repeatable and automated. By creating skills that encapsulate your optimization logic, generating responsive variants in modern formats, and integrating with your build pipeline, you eliminate the manual tedium of image optimization while ensuring every image on your site is optimized for performance.

Start with the basic script above, customize the configuration for your specific needs, and let Claude handle the rest. Add the audit mode to understand your current state, build out the responsive markup generator for your specific framework, and integrate with your commit or CI process so optimization becomes invisible infrastructure rather than a task anyone has to remember.

Your users. and your Lighthouse scores. will thank you.



---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-image-optimization-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Imgix Image Optimization Workflow](/claude-code-for-imgix-image-optimization-workflow/)
- [Claude Code Next.js Image Optimization Guide](/claude-code-nextjs-image-optimization-guide/)
- [AI Coding Tools for Performance Optimization: A.](/ai-coding-tools-for-performance-optimization/)
- [How to Use Power BI DAX Optimization with Claude Code (2026)](/claude-code-power-bi-dax-optimization-guide/)
- [How to Use PWA Install Prompt Workflow (2026)](/claude-code-for-pwa-install-prompt-workflow-guide/)
- [Claude Code For Coding Interview — Complete Developer Guide](/claude-code-for-coding-interview-preparation-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Understanding Modern Image Formats?

Modern image formats for web include AVIF (40-50% smaller than JPEG, 90%+ browser support), WebP (25-35% smaller, 97%+ support), JPEG (universal, baseline for photographs), and PNG (universal, required for alpha transparency). For 2026 projects, serve AVIF as first choice with WebP fallback and JPEG/PNG as universal fallback. Replace animated GIFs with WebP animations or short video clips. Use SVG exclusively for icons, logos, and scalable vector graphics.

### What is Setting Up Your Image Optimization Skill?

Create a Claude skill file at `.claude/image-optimization.md` that defines capabilities (bulk processing, responsive variants, WebP/AVIF conversion, consistent compression, srcset markup generation) and usage patterns. Extend it with project-specific rules like hero image max width of 1920px, product image 400x400 square crops, blog thumbnails at 800x450 in 16:9 ratio, and a rule to never enlarge images beyond original dimensions. This skill acts as the contract for your optimization pipeline.

### What is Creating the Optimization Script?

The optimization script is a Node.js file using the sharp library that processes each input image into multiple sizes (320, 640, 960, 1280, 1920px) and formats (WebP at quality 80, AVIF at quality 65, JPEG at quality 85). The `withoutEnlargement: true` flag prevents upscaling smaller images. The script includes both single-image `optimizeImage()` and batch `batchProcess()` functions that filter for jpg/png/gif/webp files and generate all variants in the output directory.

### What is Adding an Audit Mode?

Audit mode scans your images directory before optimization to report file sizes, dimensions, formats, and issues. It flags files over 500KB as oversized, images wider than 2500px as very wide, and GIF files as candidates for WebP animation conversion. Results are sorted by size descending so the biggest problems appear first. Running audit mode on legacy codebases with years of unoptimized assets shows which files benefit most before committing to full optimization.

### What is Generating Responsive Image Markup?

Generating responsive image markup produces HTML `<picture>` elements with multiple `<source>` tags for AVIF and WebP formats, plus an `<img>` fallback for JPEG. Each source includes a srcset attribute listing all width variants (320w through 1920w). Include the `sizes` attribute to prevent browsers from downloading oversized variants -- for example, `(max-width: 768px) 100vw, 50vw`. Add `loading="lazy"` and `decoding="async"` to below-the-fold images for Core Web Vitals performance.
