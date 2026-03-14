---

layout: default
title: "Claude Code Emotion CSS-in-JS Guide"
description: "Master Emotion CSS-in-JS styling with Claude Code. Learn practical patterns for component styling, theming, and dynamic styles using @emotion/react and."
date: 2026-03-14
categories: [guides]
tags: [claude-code, emotion, css-in-js, frontend, styling, react, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-emotion-css-in-js-guide/
reviewed: true
score: 7
---


# Claude Code Emotion CSS-in-JS Guide

Emotion has become one of the most popular CSS-in-JS libraries for React applications, offering both performance and developer experience benefits. This guide shows you how to use Claude Code to work with Emotion effectively, from basic component styling to advanced theming patterns.

## Why Use Emotion with React

Emotion provides two primary approaches for styling: the `css` prop with `@emotion/react` and the `styled` API with `@emotion/styled`. Both approaches offer critical advantages over traditional CSS:

- **Scoped styles** that don't leak across components
- **Dynamic theming** based on React context
- **Dead code elimination** through extraction (in production builds)
- **Server-side rendering** support with consistent hydration

Claude Code can help you set up Emotion quickly and generate idiomatic patterns that follow current best practices.

## Setting Up Emotion in Your Project

Before styling, install the required packages:

```bash
npm install @emotion/react @emotion/styled
```

If you're using TypeScript, also install the types:

```bash
npm install -D @types/@emotion/react @types/@emotion/styled
```

When configuring your build system, ensure the Babel or SWC plugin for Emotion is present. For Next.js projects, this typically means adding `@emotion/babel-plugin` to your configuration.

## Basic Component Styling with the css Prop

The simplest approach uses the `css` prop from `@emotion/react`. This works directly on any element:

```jsx
import { css } from '@emotion/react';

function SubmitButton({ disabled }) {
  return (
    <button
      css={css`
        padding: 12px 24px;
        background-color: ${disabled ? '#ccc' : '#0070f3'};
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 16px;
        cursor: ${disabled ? 'not-allowed' : 'pointer'};
        transition: background-color 0.2s ease;

        &:hover {
          background-color: ${disabled ? '#ccc' : '#0051a2'};
        }
      `}
      disabled={disabled}
    >
      Submit
    </button>
  }
}
```

The css prop accepts a template literal that compiles to optimized CSS. Notice how you can use JavaScript expressions inside the template for dynamic values—this is where Emotion shines for conditional styling.

## Using the Styled API

For more complex components, the `styled` API provides a cleaner separation:

```jsx
import styled from '@emotion/styled';

const Card = styled.div`
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 24px;
  max-width: 400px;
`;

const Title = styled.h2`
  font-size: 24px;
  font-weight: 600;
  margin: 0 0 16px 0;
  color: #1a1a1a;
`;

const PrimaryButton = styled.button`
  background-color: #0070f3;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  
  &:hover {
    background-color: #0051a2;
  }
`;
```

The styled API creates reusable components that encapsulate their styling. This makes your components more readable and maintains a clear boundary between structure and presentation.

## Dynamic Props and Variants

One of Emotion's powerful features is passing props to styled components:

```jsx
const StatusBadge = styled.span`
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  
  background-color: ${props => {
    switch (props.status) {
      case 'success': return '#d1fae5';
      case 'error': return '#fee2e2';
      case 'warning': return '#fef3c7';
      default: return '#e5e7eb';
    }
  }};
  
  color: ${props => {
    switch (props.status) {
      case 'success': return '#065f46';
      case 'error': return '#991b1b';
      case 'warning': return '#92400e';
      default: return '#374151';
    }
  }};
`;

// Usage
<StatusBadge status="success">Active</StatusBadge>
<StatusBadge status="error">Failed</StatusBadge>
```

This pattern eliminates the need for utility classes or conditional rendering of different components based on props.

## Theming with Emotion

Emotion integrates smoothly with React's theming. First, wrap your application with the ThemeProvider:

```jsx
import { ThemeProvider } from '@emotion/react';

const theme = {
  colors: {
    primary: '#0070f3',
    secondary: '#7928ca',
    background: '#ffffff',
    text: '#1a1a1a',
    gray: {
      100: '#f3f4f6',
      200: '#e5e7eb',
      300: '#d1d5db',
    }
  },
  spacing: {
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
  },
  borderRadius: {
    sm: '4px',
    md: '8px',
    lg: '12px',
  }
};

function App() {
  return (
    <ThemeProvider theme={theme}>
      <YourApp />
    </ThemeProvider>
  );
}
```

Then access the theme in any styled component:

```jsx
const Container = styled.div`
  padding: ${props => props.theme.spacing.lg};
  background-color: ${props => props.theme.colors.background};
  border-radius: ${props => props.theme.borderRadius.md};
`;

const Heading = styled.h1`
  color: ${props => props.theme.colors.primary};
  font-size: 32px;
`;
```

This approach centralizes design tokens and makes redesigns straightforward—you update the theme object and all components reflect the changes.

## Global Styles

For base styles, reset CSS, or font imports, use global styles:

```jsx
import { Global, css } from '@emotion/react';

function GlobalStyles() {
  return (
    <Global
      styles={css`
        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
        }
        
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          line-height: 1.5;
          -webkit-font-smoothing: antialiased;
        }
        
        a {
          color: #0070f3;
          text-decoration: none;
        }
        
        a:hover {
          text-decoration: underline;
        }
      `}
    />
  );
}
```

Place this component once at the root of your application.

## Combining with Claude Skills

When building Emotion-based components, several Claude skills accelerate your workflow. The **frontend-design** skill helps generate design-system-compliant tokens and patterns. For testing styled components, the **tdd** skill guides you through writing component tests that verify both functionality and visual behavior.

If you need to generate visual assets that complement your Emotion styling, the **canvas-design** skill creates matching graphics and icons. For documentation, the **pdf** skill produces styled PDF exports of your component library.

The **supermemory** skill proves invaluable when maintaining design systems—it remembers previous design decisions and helps maintain consistency across your codebase.

## Performance Considerations

Emotion excels in production because it extracts static styles into a separate CSS file during the build process. However, keep these points in mind:

- Avoid creating styled components inside render loops—define them outside the component
- Use the `css` prop for one-off styles to reduce component count
- Leverage the `shouldForwardProp` option to control which props pass to the DOM element

```jsx
const InteractiveBox = styled.div`
  background: papayawhip;
  padding: 16px;
`;

const CustomComponent = styled(Box, {
  shouldForwardProp: (prop) => prop !== 'isActive'
})`
  border: 2px solid ${props => props.isActive ? 'blue' : 'transparent'};
`;
```

This prevents styled components from receiving internal props they don't need, reducing unnecessary re-renders.

## Conclusion

Emotion provides a flexible, performant approach to styling React applications. Whether you prefer the `css` prop for simplicity or the styled API for component encapsulation, Claude Code helps you implement these patterns effectively. Start with basic styling, progressively adopt theming and global styles, and optimize for production as your application grows.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
