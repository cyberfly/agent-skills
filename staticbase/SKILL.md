---
name: staticbase
description: Scaffold a new static website project using the staticbase stack (Vite 7, Tailwind CSS 4, Alpine.js 3, markdown-powered blog). Use when user wants to create a new static site, website project, scaffold a staticbase project, or mentions the staticbase generator.
---

# staticbase

Scaffold a production-ready static website with multi-page support, responsive navigation, and a markdown blog — no external script needed.

## Quick start

```
/staticbase my-project-name
```

1. Run the scaffold script:
   ```bash
   bash /Users/integrasolid/.claude/skills/staticbase/scripts/scaffold.sh <project-name>
   ```
2. Install dependencies:
   ```bash
   cd <project-name> && npm install
   ```
3. Start dev server:
   ```bash
   npm run dev
   ```

Site runs at **http://localhost:5173**

## Stack

| Tool | Version | Role |
|------|---------|------|
| Vite | 7 | Build tool & dev server |
| Tailwind CSS | 4 | Utility-first styling |
| Alpine.js | 3 | Lightweight interactivity |
| Marked | latest | Markdown → HTML |
| Gray Matter | latest | Frontmatter parsing |
| vite-plugin-virtual-mpa | latest | Multi-page generation |

## What gets scaffolded

```
<project>/
├── content/blog/          # Markdown blog posts
│   ├── welcome.md
│   └── getting-started.md
├── templates/
│   ├── blog-list.html
│   └── blog-post.html
├── lib/
│   ├── content.js         # Markdown parsing utilities
│   └── templates.js       # Blog card HTML generator
├── src/
│   ├── main.js            # Alpine.js + contact form handler
│   └── style.css          # Tailwind CSS imports
├── public/images/
├── base.html              # Layout with responsive nav
├── index.html             # Homepage (hero + recent posts)
├── about.html             # About page
├── contact.html           # Contact form (Firaform)
├── vite.config.js         # MPA config, dynamic blog routing
├── package.json
├── README.md
├── AGENTS.md              # AI agent guidelines
└── .gitignore
```

## Adding pages

1. Create `<page>.html` with content
2. Add nav link in `base.html`
3. Add entry in `vite.config.js` pages array:
   ```js
   {
     name: "services",
     entry: "/src/main.js",
     data: {
       title: "Services - MySite",
       description: "Our services",
       activePage: "services",
       content: readFileSync(resolve(__dirname, "services.html"), "utf-8"),
     },
   }
   ```

## Adding blog posts

Create `content/blog/<slug>.md`:
```markdown
---
title: "Post Title"
slug: post-slug
date: 2026-01-28
description: "Under 160 chars"
---

Content here...
```

Blog pages are auto-generated at `/blog/<slug>.html`.

## Contact form

The contact form submits to Firaform. Update the endpoint in `src/main.js`:
```js
const response = await fetch('https://a.firaform.com/api/f/YOUR_FORM_ID', ...
```

## Deploy

```bash
npm run build   # outputs to dist/
```

Works with Netlify, Vercel, GitHub Pages, Cloudflare Pages.
