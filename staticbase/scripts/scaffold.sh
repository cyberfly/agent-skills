#!/bin/bash

# staticbase scaffold script
# Creates a complete static website project with Vite, Tailwind CSS, and Alpine.js

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="${1:-mystaticbase}"
PROJECT_PATH="./$PROJECT_NAME"

echo -e "${BLUE}Creating staticbase project: ${PROJECT_NAME}${NC}"

if [ -d "$PROJECT_PATH" ]; then
  echo -e "${RED}Error: Directory already exists: ${PROJECT_NAME}${NC}"
  exit 1
fi

mkdir -p "$PROJECT_PATH"/{src,public/images,content/blog,templates,lib}

# package.json
cat > "$PROJECT_PATH/package.json" << EOF
{
  "name": "${PROJECT_NAME}",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "alpinejs": "^3.15.3",
    "vite": "^7.3.1"
  },
  "devDependencies": {
    "@tailwindcss/vite": "^4.1.18",
    "@tailwindcss/typography": "^0.5.13",
    "gray-matter": "^4.0.3",
    "marked": "^17.0.1",
    "tailwindcss": "^4.1.18",
    "vite-plugin-virtual-mpa": "^1.12.1"
  }
}
EOF

# .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
node_modules/
dist/
.DS_Store
.env
.env.local
*.log
EOF

# vite.config.js
cat > "$PROJECT_PATH/vite.config.js" << EOF
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import { createMpaPlugin } from "vite-plugin-virtual-mpa";
import { resolve } from "path";
import { readFileSync } from "fs";
import { getContentFromDirectory, formatDate } from "./lib/content.js";
import { generateBlogCard } from "./lib/templates.js";

const __dirname = resolve();

const blogDir = resolve(__dirname, "content/blog");
const blogPosts = getContentFromDirectory(blogDir, {
  sortBy: "date",
  order: "desc",
});

const recentBlogPosts = blogPosts.slice(0, 3);

const blogListTemplate = readFileSync(
  resolve(__dirname, "templates/blog-list.html"),
  "utf-8"
);
const blogPostTemplate = readFileSync(
  resolve(__dirname, "templates/blog-post.html"),
  "utf-8"
);

const indexContent = readFileSync(resolve(__dirname, "index.html"), "utf-8");
const aboutContent = readFileSync(resolve(__dirname, "about.html"), "utf-8");
const contactContent = readFileSync(resolve(__dirname, "contact.html"), "utf-8");

function generateBlogListContent() {
  const cardsHtml = blogPosts.map((post) => generateBlogCard(post)).join("\n");
  return blogListTemplate.replace("<%- blogCards %>", cardsHtml);
}

function generateBlogPostContent(post) {
  const { frontmatter, content } = post;
  const dateFormatted = formatDate(frontmatter.date);
  return blogPostTemplate
    .replace(/<%=\s*title\s*%>/g, frontmatter.title)
    .replace(/<%=\s*date\s*%>/g, dateFormatted)
    .replace(/<%-\s*content\s*%>/g, content);
}

function generateHomepageContent() {
  const recentBlogHtml = recentBlogPosts.map((post) => generateBlogCard(post)).join("\n");
  return indexContent.replace("<%- recentBlogPosts %>", recentBlogHtml);
}

const pages = [
  {
    name: "index",
    entry: "/src/main.js",
    data: {
      title: "Home - ${PROJECT_NAME}",
      description: "Welcome to my website",
      activePage: "home",
      content: generateHomepageContent(),
    },
  },
  {
    name: "about",
    entry: "/src/main.js",
    data: {
      title: "About - ${PROJECT_NAME}",
      description: "Learn more about us",
      activePage: "about",
      content: aboutContent,
    },
  },
  {
    name: "contact",
    entry: "/src/main.js",
    data: {
      title: "Contact - ${PROJECT_NAME}",
      description: "Get in touch",
      activePage: "contact",
      content: contactContent,
    },
  },
  {
    name: "blog",
    entry: "/src/main.js",
    data: {
      title: "Blog - ${PROJECT_NAME}",
      description: "Read our latest posts",
      activePage: "blog",
      content: generateBlogListContent(),
    },
  },
  ...blogPosts.map((post) => ({
    name: \`blog-\${post.slug}\`,
    filename: \`blog/\${post.slug}.html\`,
    entry: "/src/main.js",
    data: {
      title: \`\${post.frontmatter.title} - ${PROJECT_NAME}\`,
      description: post.frontmatter.description,
      activePage: "blog",
      content: generateBlogPostContent(post),
    },
  })),
];

const rewrites = [
  ...blogPosts.map((post) => ({
    from: new RegExp(\`^/blog/\${post.slug}(\\.html)?\$\`),
    to: \`/blog/\${post.slug}.html\`,
  })),
];

export default defineConfig({
  plugins: [
    tailwindcss(),
    createMpaPlugin({
      template: "base.html",
      pages,
      rewrites,
    }),
  ],
});
EOF

# base.html
cat > "$PROJECT_PATH/base.html" << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= title %></title>
    <meta name="description" content="<%= description %>" />
    <script type="module" src="/src/main.js"></script>
  </head>
  <body class="min-h-screen bg-gray-50 text-gray-900 antialiased" x-data="{ mobileMenuOpen: false }">
    <nav class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <a href="/" class="text-2xl font-bold text-blue-600 hover:text-blue-700 transition-colors">
            ${PROJECT_NAME}
          </a>
          <ul class="hidden md:flex space-x-8">
            <li><a href="/" class="<%= activePage === 'home' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors">Home</a></li>
            <li><a href="/about.html" class="<%= activePage === 'about' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors">About</a></li>
            <li><a href="/blog.html" class="<%= activePage === 'blog' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors">Blog</a></li>
            <li><a href="/contact.html" class="<%= activePage === 'contact' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors">Contact</a></li>
          </ul>
          <button @click="mobileMenuOpen = !mobileMenuOpen" class="md:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors">
            <svg x-show="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
            <svg x-show="mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div x-show="mobileMenuOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-y-1" x-transition:enter-end="opacity-100 translate-y-0" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 translate-y-0" x-transition:leave-end="opacity-0 -translate-y-1" class="md:hidden pb-4">
          <ul class="space-y-2">
            <li><a href="/" class="block px-4 py-2 rounded-lg <%= activePage === 'home' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">Home</a></li>
            <li><a href="/about.html" class="block px-4 py-2 rounded-lg <%= activePage === 'about' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">About</a></li>
            <li><a href="/blog.html" class="block px-4 py-2 rounded-lg <%= activePage === 'blog' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">Blog</a></li>
            <li><a href="/contact.html" class="block px-4 py-2 rounded-lg <%= activePage === 'contact' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">Contact</a></li>
          </ul>
        </div>
      </div>
    </nav>
    <main class="min-h-[calc(100vh-16rem)]">
      <%- content %>
    </main>
    <footer class="bg-white border-t border-gray-200 mt-16">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <p class="text-center text-gray-600">&copy; $(date +%Y) ${PROJECT_NAME}. All rights reserved.</p>
      </div>
    </footer>
  </body>
</html>
EOF

# index.html
cat > "$PROJECT_PATH/index.html" << EOF
<section class="bg-gradient-to-br from-blue-600 to-blue-800 text-white py-20">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
    <h1 class="text-4xl md:text-6xl font-bold mb-6">Welcome to ${PROJECT_NAME}</h1>
    <p class="text-xl md:text-2xl text-blue-100 mb-8">A simple, clean website built with staticbase</p>
    <a href="/blog.html" class="inline-block bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-colors shadow-lg hover:shadow-xl">Read Our Blog</a>
  </div>
</section>
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-3xl font-bold text-gray-900 mb-8">Recent Blog Posts</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <%- recentBlogPosts %>
    </div>
    <div class="text-center mt-12">
      <a href="/blog.html" class="inline-block bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors">View All Posts</a>
    </div>
  </div>
</section>
EOF

# about.html
cat > "$PROJECT_PATH/about.html" << 'EOF'
<section class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-6">About Us</h1>
    <div class="prose prose-lg max-w-none">
      <p class="text-xl text-gray-600 mb-6">Welcome to our website! We're passionate about creating great content and sharing our knowledge with the world.</p>
      <h2 class="text-2xl font-bold text-gray-900 mt-8 mb-4">Our Mission</h2>
      <p class="text-gray-600 mb-6">Our mission is to provide valuable content and resources to our readers. We believe in simplicity, clarity, and user-friendly design.</p>
      <h2 class="text-2xl font-bold text-gray-900 mt-8 mb-4">What We Do</h2>
      <p class="text-gray-600 mb-6">We write about various topics including technology, design, and development. Our blog features tutorials, insights, and tips to help you grow.</p>
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mt-8">
        <h3 class="text-xl font-semibold text-blue-900 mb-2">Get in Touch</h3>
        <p class="text-blue-700">Interested in working together? <a href="/contact.html" class="underline hover:text-blue-900">Contact us</a> to learn more.</p>
      </div>
    </div>
  </div>
</section>
EOF

# contact.html
cat > "$PROJECT_PATH/contact.html" << 'EOF'
<section class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-6">Contact Us</h1>
    <p class="text-xl text-gray-600 mb-8">We'd love to hear from you! Get in touch using the form below.</p>
    <div id="successMessage" class="hidden bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-lg mb-4">Thank you for your message! We'll get back to you soon.</div>
    <div id="errorMessage" class="hidden bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg mb-4">Something went wrong. Please try again.</div>
    <form id="contactForm" class="space-y-6">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Name</label>
        <input type="text" id="name" name="name" required class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors" />
        <span id="nameError" class="hidden text-sm text-red-600 mt-1">Please enter your name</span>
      </div>
      <div>
        <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email</label>
        <input type="email" id="email" name="email" required class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors" />
        <span id="emailError" class="hidden text-sm text-red-600 mt-1">Please enter a valid email address</span>
      </div>
      <div>
        <label for="message" class="block text-sm font-medium text-gray-700 mb-2">Message</label>
        <textarea id="message" name="message" rows="5" required class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"></textarea>
        <span id="messageError" class="hidden text-sm text-red-600 mt-1">Please enter a message</span>
      </div>
      <button type="submit" id="submitBtn" class="w-full bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
        <span id="submitText">Send Message</span>
      </button>
    </form>
  </div>
</section>
EOF

# templates/blog-list.html
cat > "$PROJECT_PATH/templates/blog-list.html" << 'EOF'
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-4">Blog</h1>
    <p class="text-xl text-gray-600 mb-12">Thoughts, tutorials, and insights</p>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <%- blogCards %>
    </div>
  </div>
</section>
EOF

# templates/blog-post.html
cat > "$PROJECT_PATH/templates/blog-post.html" << 'EOF'
<article class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <header class="mb-8 pb-8 border-b border-gray-200">
      <h1 class="text-4xl font-bold text-gray-900 mb-4"><%= title %></h1>
      <time datetime="<%= date %>" class="text-gray-600"><%= date %></time>
    </header>
    <div class="prose prose-lg max-w-none prose-headings:font-bold prose-a:text-blue-600 prose-a:no-underline hover:prose-a:underline prose-img:rounded-lg prose-pre:bg-gray-900 prose-pre:text-gray-100">
      <%- content %>
    </div>
    <div class="mt-12 pt-8 border-t border-gray-200">
      <a href="/blog.html" class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Back to Blog
      </a>
    </div>
  </div>
</article>
EOF

# lib/content.js
cat > "$PROJECT_PATH/lib/content.js" << 'EOF'
import { readFileSync, readdirSync, existsSync } from "fs";
import { join, basename } from "path";
import matter from "gray-matter";
import { marked } from "marked";

marked.setOptions({ gfm: true, breaks: true });

export function parseMarkdownFile(filePath) {
  const fileContent = readFileSync(filePath, "utf-8");
  const { data: frontmatter, content } = matter(fileContent);
  return {
    frontmatter,
    content: marked(content),
    slug: frontmatter.slug || basename(filePath, ".md"),
  };
}

export function getContentFromDirectory(contentDir, options = {}) {
  const { sortBy = "date", order = "desc", filterDraft = true } = options;
  if (!existsSync(contentDir)) return [];
  const files = readdirSync(contentDir).filter((f) => f.endsWith(".md"));
  const items = files.map((file) => parseMarkdownFile(join(contentDir, file)));
  const filtered = filterDraft ? items.filter((item) => !item.frontmatter.draft) : items;
  return filtered.sort((a, b) => {
    const aVal = a.frontmatter[sortBy];
    const bVal = b.frontmatter[sortBy];
    if (sortBy === "date") {
      return order === "desc" ? new Date(bVal) - new Date(aVal) : new Date(aVal) - new Date(bVal);
    }
    return order === "desc" ? bVal - aVal : aVal - bVal;
  });
}

export function formatDate(date) {
  return new Date(date).toLocaleDateString("en-US", { month: "long", day: "numeric", year: "numeric" });
}
EOF

# lib/templates.js
cat > "$PROJECT_PATH/lib/templates.js" << 'EOF'
export function generateBlogCard(post) {
  const { frontmatter } = post;
  const date = new Date(frontmatter.date).toLocaleDateString("en-US", {
    month: "short", day: "numeric", year: "numeric",
  });
  return `
    <article class="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow">
      <h3 class="text-xl font-bold text-gray-900 mb-2">
        <a href="/blog/${post.slug}.html" class="hover:text-blue-600 transition-colors">${frontmatter.title}</a>
      </h3>
      <time datetime="${frontmatter.date}" class="text-sm text-gray-500 block mb-3">${date}</time>
      <p class="text-gray-600 mb-4">${frontmatter.description || ''}</p>
      <a href="/blog/${post.slug}.html" class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold">
        Read More
        <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </a>
    </article>
  `;
}
EOF

# src/main.js
cat > "$PROJECT_PATH/src/main.js" << 'EOF'
import './style.css';
import Alpine from 'alpinejs';

window.Alpine = Alpine;
Alpine.start();

document.addEventListener('DOMContentLoaded', () => {
  const contactForm = document.getElementById('contactForm');
  if (!contactForm) return;

  const submitBtn = document.getElementById('submitBtn');
  const submitText = document.getElementById('submitText');
  const successMessage = document.getElementById('successMessage');
  const errorMessage = document.getElementById('errorMessage');
  const nameInput = document.getElementById('name');
  const emailInput = document.getElementById('email');
  const messageInput = document.getElementById('message');
  const nameError = document.getElementById('nameError');
  const emailError = document.getElementById('emailError');
  const messageError = document.getElementById('messageError');

  const validateEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

  const showError = (input, errorElement, message) => {
    input.classList.add('border-red-500');
    errorElement.textContent = message;
    errorElement.classList.remove('hidden');
  };

  const hideError = (input, errorElement) => {
    input.classList.remove('border-red-500');
    errorElement.classList.add('hidden');
  };

  nameInput.addEventListener('blur', () => {
    nameInput.value.trim() ? hideError(nameInput, nameError) : showError(nameInput, nameError, 'Please enter your name');
  });
  emailInput.addEventListener('blur', () => {
    validateEmail(emailInput.value) ? hideError(emailInput, emailError) : showError(emailInput, emailError, 'Please enter a valid email address');
  });
  messageInput.addEventListener('blur', () => {
    messageInput.value.trim() ? hideError(messageInput, messageError) : showError(messageInput, messageError, 'Please enter a message');
  });

  contactForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    successMessage.classList.add('hidden');
    errorMessage.classList.add('hidden');

    let isValid = true;
    if (!nameInput.value.trim()) { showError(nameInput, nameError, 'Please enter your name'); isValid = false; } else hideError(nameInput, nameError);
    if (!validateEmail(emailInput.value)) { showError(emailInput, emailError, 'Please enter a valid email address'); isValid = false; } else hideError(emailInput, emailError);
    if (!messageInput.value.trim()) { showError(messageInput, messageError, 'Please enter a message'); isValid = false; } else hideError(messageInput, messageError);
    if (!isValid) return;

    submitBtn.disabled = true;
    submitText.textContent = 'Sending...';

    try {
      // Update this URL with your Firaform form ID
      const response = await fetch('https://a.firaform.com/api/f/xxx', {
        method: 'POST',
        headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: nameInput.value.trim(),
          email: emailInput.value.trim(),
          message: messageInput.value.trim(),
        }),
      });

      if (response.ok) {
        successMessage.classList.remove('hidden');
        contactForm.reset();
        successMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } else {
        errorMessage.classList.remove('hidden');
      }
    } catch {
      errorMessage.classList.remove('hidden');
    } finally {
      submitBtn.disabled = false;
      submitText.textContent = 'Send Message';
    }
  });
});
EOF

# src/style.css
cat > "$PROJECT_PATH/src/style.css" << 'EOF'
@import "tailwindcss";
@plugin "@tailwindcss/typography";
EOF

# Sample blog post 1
cat > "$PROJECT_PATH/content/blog/welcome.md" << 'EOF'
---
title: "Welcome to staticbase"
slug: welcome
date: 2026-01-28
description: "Your first blog post using staticbase with Tailwind CSS and Alpine.js"
---

# Welcome to staticbase!

This is your first blog post. staticbase makes it easy to create a simple, clean website with a blog, powered by modern tools:

- **Tailwind CSS** for beautiful, utility-first styling
- **Alpine.js** for lightweight interactivity
- **Vite** for lightning-fast builds
- **Markdown** for easy content writing

## Getting Started

Edit this file or create new markdown files in the `content/blog` directory to add more posts.

Each post needs frontmatter with:
- **title**: The post title
- **slug**: URL-friendly identifier
- **date**: Publication date (YYYY-MM-DD)
- **description**: Short description for SEO

## Writing Content

You can use all standard Markdown features:

- Bulleted lists
- **Bold** and *italic* text
- [Links](https://example.com)
- Code blocks
- Images

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
}
greet('World');
```

Happy blogging!
EOF

# Sample blog post 2
cat > "$PROJECT_PATH/content/blog/getting-started.md" << 'EOF'
---
title: "Getting Started with Your New Site"
slug: getting-started
date: 2026-01-27
description: "Learn how to customize your new staticbase website with Tailwind CSS and Alpine.js"
---

# Getting Started

Congratulations on setting up your new website! Here's how to customize it and make it your own.

## Project Structure

```
mystaticbase/
├── content/blog/      # Blog posts (markdown)
├── templates/         # Page templates
├── src/               # JS + CSS
├── lib/               # Helper functions
├── public/images/     # Static images
├── index.html         # Homepage content
├── about.html         # About page content
├── contact.html       # Contact page content
├── base.html          # Base template with nav
└── vite.config.js     # Vite config
```

## Adding Blog Posts

Create a new `.md` file in `content/blog/`:

```markdown
---
title: "My Post Title"
slug: my-post-title
date: 2026-01-28
description: "Post description"
---

Your content here...
```

## Deployment

Build your site:

```bash
npm run build
```

Deploy the `dist/` folder to Netlify, Vercel, GitHub Pages, or Cloudflare Pages.
EOF

# README.md
cat > "$PROJECT_PATH/README.md" << EOF
# ${PROJECT_NAME}

A modern static website built with staticbase.

## Commands

\`\`\`bash
npm install      # Install dependencies
npm run dev      # Start dev server (http://localhost:5173)
npm run build    # Build for production (dist/)
npm run preview  # Preview production build
\`\`\`

## Stack

- **Vite** — Build tool
- **Tailwind CSS** — Styling
- **Alpine.js** — Interactivity
- **Marked** — Markdown parser
- **Gray Matter** — Frontmatter

## Adding Blog Posts

Create \`content/blog/<slug>.md\`:

\`\`\`markdown
---
title: "Post Title"
slug: post-slug
date: 2026-01-28
description: "Brief description"
---

Content here...
\`\`\`

## Deployment

Supports Netlify, Vercel, GitHub Pages, Cloudflare Pages.
EOF

echo -e "${GREEN}Project created: ${PROJECT_NAME}${NC}"
echo ""
echo "Next steps:"
echo "  cd ${PROJECT_NAME}"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "Dev server: http://localhost:5173"
