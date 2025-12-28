# Kleomarcus - AI Coding Agent Instructions

## Project Overview

Kleomarcus is a Rails 8.1 web application for Kleomarcus Fight Club built with modern Rails conventions using the Omakase stack: Hotwire (Turbo + Stimulus), Tailwind CSS, and PostgreSQL.

## Stack & Dependencies

- **Ruby 3.4.4** / **Rails 8.1.1**
- **Database**: PostgreSQL with Solid adapters (solid_cache, solid_queue, solid_cable)
- **Frontend**: Tailwind CSS 4.1.16 + DaisyUI component library
- **JavaScript**: importmap-rails (no bundler), Stimulus controllers, Turbo
- **Testing**: RSpec with Factory Bot, Faker, Capybara (not minitest)
- **Deployment**: Kamal with Docker support
- **Code Quality**: RuboCop (Rails Omakase), Brakeman, bundler-audit, Herb (ERB linter)

## Critical Workflows

## General Coding Rules

When generating, suggesting, or editing code, always follow official **Ruby** and **Ruby on Rails** style guidelines:

- Adhere to Ruby Style Guide and Rails Omakase conventions.
- Follow existing RuboCop (Rails Omakase) rules without introducing violations.
- Maintain consistent formatting, naming, and structure with the existing codebase.
- Be mindful of security vulnerabilities:
  - Follow Rails security best practices (strong parameters, CSRF protection, safe query methods).
  - Avoid introducing XSS, SQL injection, mass-assignment, or unsafe deserialization risks.

### Development Server

```bash
bin/dev  # Runs both Rails server and Tailwind CSS watcher via Procfile.dev
```

This is the primary command for local development - it auto-installs foreman if missing and starts both web and CSS processes.

### Testing

```bash
bundle exec rspec  # Run RSpec test suite
bin/ci             # Run full CI suite (uses config/ci.rb)
```

Uses RSpec exclusively (not Rails default minitest). Test files live in `spec/` directory.

### Code Quality

```bash
bin/rubocop        # Ruby style checks (Omakase style)
bin/brakeman       # Security vulnerability scanning
bin/bundler-audit  # Gem security audit
```

### Database

Standard Rails commands with Solid adapters enabled for caching, background jobs, and WebSockets.

## Architecture & Patterns

### Controller Namespace Convention

Controllers are organized under **namespace directories** to separate public and future admin/api areas:

- Public-facing: `app/controllers/public/` → routes under `namespace :public`
- Example: `Public::HomeController` at `app/controllers/public/home_controller.rb`
- Route: `root "public/home#index"`

**Always use namespaced controllers** - don't create controllers directly in `app/controllers/` except `ApplicationController`.

### Frontend Architecture

- **Tailwind CSS 4.x**: Custom configuration in `app/assets/tailwind/` with DaisyUI component library
- **DaisyUI**: Component classes available (e.g., `btn btn-primary`), imported via `app/assets/tailwind/daisyui.mjs`
- **Stimulus Controllers**: Auto-loaded from `app/javascript/controllers/` via importmap
- **No JavaScript bundler**: Use importmap pins in `config/importmap.rb` for any npm packages

### View Structure

- Namespaced views mirror controller structure: `app/views/public/home/index.html.erb`
- Main layout at `app/views/layouts/application.html.erb` includes Tailwind and Turbo
- PWA support files in `app/views/pwa/` (currently commented out in routes)

### Testing Patterns

- **Request specs**: Test controller actions (e.g., `spec/requests/public/home_spec.rb`)
- **Helper specs**: Minimal, in `spec/helpers/`
- **View specs**: For complex views with Tailwind assertions (`spec/views/public/home/index.html.tailwindcss_spec.rb`)
- Use Factory Bot for test data, Faker for generating fake content

## Key Configuration Files

- `config/routes.rb` - Namespaced route definitions
- `config/importmap.rb` - JavaScript dependencies (no package.json)
- `config/deploy.yml` - Kamal deployment configuration
- `Procfile.dev` - Development process definitions (web + css)
- `app/assets/tailwind/daisyui.mjs` - DaisyUI component library bundle

## Deployment

Uses Kamal for containerized deployment. Local registry at `localhost:5555` (see `config/deploy.yml`). Thruster provides asset acceleration in production.

## Modern Rails Features in Use

- **allow_browser**: Modern browser enforcement in ApplicationController
- **stale_when_importmap_changes**: Automatic ETags for importmap changes
- **Solid adapters**: Database-backed caching, jobs, and cable (no Redis)
- **Propshaft**: Modern asset pipeline (replaces Sprockets)

## Responsive Design (Mobile-First Approach)

This project follows a **mobile-first** responsive design strategy using Tailwind CSS breakpoints.

### Breakpoint System

Always define base styles for mobile, then progressively enhance for larger screens:

```
Base (mobile)  →  sm: 640px  →  md: 768px  →  lg: 1024px  →  xl: 1280px
```

### Mobile-First Class Patterns

```erb
<!-- Typography: Start small, scale up -->
<h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl xl:text-6xl">

<!-- Spacing: Compact on mobile, generous on desktop -->
<section class="py-12 sm:py-16 md:py-20 lg:py-24">
<div class="px-4 sm:px-6 lg:px-8">
<div class="mb-6 sm:mb-8 lg:mb-12">

<!-- Grid: Stack on mobile, columns on larger screens -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6 lg:gap-8">

<!-- Buttons: Appropriate touch targets -->
<button class="btn btn-sm sm:btn-md lg:btn-lg">

<!-- Visibility: Show/hide based on screen -->
<nav class="hidden lg:flex">        <!-- Desktop only -->
<button class="lg:hidden">          <!-- Mobile only -->
```

### Section Structure Convention

Each page section should follow this pattern:

```erb
<section id="section-name" class="py-12 sm:py-16 md:py-20 lg:py-24 bg-base-100" aria-labelledby="section-title">
  <div class="container mx-auto px-4 sm:px-6 lg:px-8">
    <header class="text-center mb-8 sm:mb-12 lg:mb-16">
      <h2 id="section-title" class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
```

### Key Responsive Guidelines

1. **Touch Targets**: Minimum 44x44px on mobile (use `btn-sm` minimum)
2. **Font Sizes**: Base at 16px minimum for readability
3. **Spacing**: Use `py-12` or `py-16` minimum for mobile sections
4. **Images**: Always include `loading="lazy"` and appropriate `alt` text
5. **Navigation**: Fixed header with hamburger menu on mobile, horizontal nav on desktop
6. **Hero Sections**: Use `min-h-[100svh]` for full viewport height (handles mobile browser chrome)

## SEO Guidelines

### Meta Tag Structure

The `application.html.erb` layout includes comprehensive SEO support via `content_for` blocks:

```erb
<%# In page views (e.g., index.html.erb) %>
<% content_for :title, "Sayfa Başlığı | Kleomarcus" %>
<% content_for :description, "Sayfa açıklaması - 150-160 karakter arası." %>
<% content_for :keywords, "anahtar, kelimeler, virgülle, ayrılmış" %>
<% content_for :canonical_url, request.original_url %>

<%# Open Graph %>
<% content_for :og_title, "Sosyal medya başlığı" %>
<% content_for :og_description, "Sosyal medya açıklaması" %>
<% content_for :og_image, image_url("og-image.jpg") %>
<% content_for :og_type, "website" %>

<%# Twitter Card %>
<% content_for :twitter_card, "summary_large_image" %>
```

### Structured Data (JSON-LD)

Include schema.org markup for rich search results:

```erb
<% content_for :structured_data do %>
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "SportsClub",
      "name": "Kleomarcus Dövüş Kulübü",
      "description": "...",
      "address": { "@type": "PostalAddress", ... },
      "telephone": "+90...",
      "url": "<%= request.base_url %>"
    }
  </script>
<% end %>
```

### Semantic HTML Requirements

1. **One `<h1>` per page**: Main page title only
2. **Heading Hierarchy**: h1 → h2 → h3 (no skipping levels)
3. **Section IDs**: Every major section needs an `id` for navigation (e.g., `id="about"`, `id="programs"`)
4. **ARIA Labels**: Use `aria-labelledby` to connect sections with their headings
5. **Landmark Roles**: Use semantic elements (`<header>`, `<main>`, `<footer>`, `<nav>`, `<section>`)
6. **Skip Link**: Include skip-to-content link for keyboard users (in layout)

### Image SEO

```erb
<img
  src="..."
  alt="Açıklayıcı alternatif metin"    <%# Descriptive for meaningful images %>
  alt=""                                 <%# Empty for decorative images %>
  aria-hidden="true"                     <%# Add for decorative images %>
  loading="lazy"                         <%# Lazy load below-fold images %>
  width="800" height="600"               <%# Explicit dimensions prevent CLS %>
>
```

### Internal Linking

- Use anchor links for same-page navigation: `href="#programs"`
- All navigation links should be accessible and keyboard-navigable
- Footer should contain sitemap-style links to all major sections
