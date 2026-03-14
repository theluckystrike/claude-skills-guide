---

layout: default
title: "Claude Code for Image Optimization Workflow Guide"
description: "Learn how to leverage Claude Code to automate and optimize your image processing workflows for faster websites and better user experience."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-image-optimization-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---

{% raw %}

Image optimization is a critical yet often tedious task for web developers. Large images slow down your site, hurt SEO rankings, and frustrate users. This guide shows you how to use Claude Code to automate image optimization workflows, saving time while ensuring consistent quality across your project.

## Why Automate Image Optimization with Claude Code?

Manual image optimization is repetitive and error-prone. You need to resize images for different breakpoints, convert formats for browser compatibility, compress without visible quality loss, and generate responsive images with srcset. Doing this manually for hundreds of images is unsustainable.

Claude Code can automate the entire pipeline. It can process images in bulk, apply consistent optimization settings, generate multiple variants for responsive design, and integrate with your build process. The key is creating a repeatable workflow that handles your specific requirements.

## Setting Up Your Image Optimization Skill

The first step is creating a Claude skill that encapsulates your optimization logic. Create a file called `.claude/image-optimization.md` in your project:

```markdown
# Image Optimization Workflow

This skill automates image processing for web deployment.

## Capabilities
- Bulk process images from source directory
- Generate responsive variants (mobile, tablet, desktop)
- Convert to WebP and AVIF formats
- Apply consistent compression settings
- Generate srcset markup for responsive images

## Usage
Run the optimization pipeline on all images:
/optimize-images --source ./images/raw --output ./public/assets

Optimize a single image:
/optimize-images --single hero-banner.png --output ./public/assets
```

This skill definition tells Claude what operations it can perform and how to invoke them.

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
    console.log(`✓ Processed ${file}`);
  }
}

module.exports = { optimizeImage, batchProcess };
```

This script generates multiple sizes and formats for each input image, creating the foundation for responsive image delivery.

## Generating Responsive Image Markup

Once you have optimized images, you need HTML markup that tells browsers which variants to load. Claude can generate this markup automatically:

```javascript
function generateSrcset(filename, widths = [320, 640, 960, 1280, 1920]) {
  const variants = widths.map(w => {
    const ext = w <= 640 ? 'webp' : 'jpeg';
    return `/assets/${filename}-${w}.${ext} ${w}w`;
  });
  return variants.join(',\n       ');
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
    console.log('✓ Generated image-manifest.json');
  }
  
  console.log('✓ Image optimization complete');
}
```

## Best Practices for Image Optimization

Follow these guidelines for optimal results:

**Choose the right formats.** Use WebP or AVIF for most photographic content—they offer 25-35% better compression than JPEG. Keep PNG for images with transparency or sharp edges like logos and icons.

**Set appropriate quality levels.** Quality 75-85 for JPEG provides good balance. WebP at quality 80 is typically indistinguishable from JPEG at 90. AVIF can use lower quality (60-70) while maintaining visual fidelity.

**Use responsive images wisely.** Generate 4-6 sizes per image. The most important breakpoints are typically 640px (mobile), 1024px (tablet), and 1920px (desktop).

**Implement lazy loading.** Always add `loading="lazy"` to below-the-fold images. Above-the-fold hero images should load eagerly for Core Web Vitals.

**Test your output.** Run Lighthouse audits after optimization to verify you're getting the expected performance improvements.

## Automating on Commit

Add image optimization to your pre-commit workflow to ensure optimized images never accidentally get committed:

```bash
# .git/hooks/pre-commit
npm run optimize-images
git add public/assets/
```

This ensures every commit includes properly optimized images, maintaining consistent performance across your deployment.

## Conclusion

Claude Code makes image optimization repeatable and automated. By creating skills that encapsulate your optimization logic, generating responsive variants in modern formats, and integrating with your build pipeline, you eliminate the manual tedium of image optimization while ensuring every image on your site is optimized for performance.

Start with the basic script above, customize the configuration for your specific needs, and let Claude handle the rest. Your users—and your Lighthouse scores—will thank you.

{% endraw %}
