# Kleomarcus — AI Coding Agent Instructions

## Project Overview

Kleomarcus is the web presence of **Kleomarcus Spor Akademi**, a combat sports and fitness academy based in Çanakkale, Turkey.

The site serves as a public-facing informational platform showcasing the academy's programs (Boks, Kick Boks, Muay Thai, Wushu, MMA, CrossFit, Bodybuilding, Hyrox, Powerlifting, Functional Training), trainer profiles, weekly schedules, photo gallery, membership pricing, and contact information. All user-facing content is in **Turkish**.

---

## Stack & Dependencies

| Layer              | Technology                                                                             |
| ------------------ | -------------------------------------------------------------------------------------- |
| **Runtime**        | Ruby 3.4.4, Rails 8.1.1                                                                |
| **Database**       | SQLite3 (all environments) with Solid adapters (solid_cache, solid_queue, solid_cable) |
| **Asset Pipeline** | Propshaft (no Sprockets)                                                               |
| **CSS**            | Tailwind CSS 4.x + DaisyUI component library                                           |
| **JavaScript**     | importmap-rails (no bundler), Stimulus controllers, Turbo                              |
| **Testing**        | RSpec 8, Factory Bot, Faker, Capybara, Selenium, SimpleCov                             |
| **Deployment**     | Kamal 2 + Docker, Thruster (HTTP compression/caching), Hetzner VPS                     |
| **Code Quality**   | RuboCop (Rails Omakase), Brakeman, bundler-audit, Herb (ERB linter)                    |
| **Fonts**          | Google Fonts — Russo One (display), Ubuntu (sans-serif)                                |

> **Note**: No Redis or PostgreSQL required. All caching, background jobs, and WebSocket connections are handled by SQLite-backed Solid adapters.

---

## Ruby & Rails Coding Standards

### Style Guide

Follow the official Ruby Style Guide and Rails conventions. Enforced by RuboCop (Rails Omakase):

- **2-space indentation** for all Ruby files
- **snake_case** for methods, variables, file names; **CamelCase** for classes/modules; **SCREAMING_SNAKE_CASE** for constants
- **Predicate methods** end with `?`; **bang methods** end with `!`
- **Double quotes** `""` for string literals
- **Modern hash syntax**: `{ key: value }` for symbol keys
- **120-character** line length limit
- **No trailing whitespace**; blank line between method definitions

### Rails Conventions

- **Thin controllers** — extract complex logic to models or service objects (`app/services/`)
- **RESTful routes** — use standard CRUD actions; define custom member/collection routes only when necessary
- **Strong parameters** — required for all mass-assignment operations
- **ActiveRecord queries** — use the query interface; avoid raw SQL unless strictly necessary
- **Validations in models**, not controllers
- **Callbacks** — use sparingly; prefer explicit service objects for multi-step workflows
- **Concerns** — extract shared model/controller behavior when reused across multiple classes
- **Partials** — extract reusable view components; avoid logic in views
- **I18n** — user-facing text is currently hardcoded in Turkish; future work will extract to `config/locales/tr.yml`

### Security

- **CSRF protection** enabled by default — never disable
- **Strong parameters** required for all controller create/update actions
- **Parameterized queries** — never interpolate user input into SQL strings
- **ERB auto-escaping** — use `<%= %>` by default; only use `raw` / `html_safe` when the content is trusted
- **Content Security Policy** defined in `config/initializers/content_security_policy.rb` — restrict `default_src :self`, allow Google Fonts and HTTPS images
- **Secrets** stored in `credentials.yml.enc` — never commit plaintext secrets
- **SSL forced** in production (`config.force_ssl = true`)

---

## Development Workflows

### Local Development

```bash
bin/setup        # First-time setup: bundle install, db:prepare, clear logs/tmp
bin/dev          # Start Rails server (port 3000) + Tailwind CSS watcher via Foreman
rails console    # Interactive console with the full application loaded
```

`bin/dev` reads `Procfile.dev` which runs two processes:

- `web`: `bin/rails server -p 3000`
- `css`: `bin/rails tailwindcss:watch`

### Testing

```bash
bundle exec rspec                           # Run all specs
bundle exec rspec spec/requests/            # Run request specs only
bundle exec rspec spec/system/              # Run system specs only
bundle exec rspec spec/path/to_spec.rb      # Run a single file
bundle exec rspec spec/path/to_spec.rb:42   # Run a specific example by line
bin/ci                                      # Full CI pipeline (see below)
```

**Test directory structure**:

| Directory         | Purpose                                        |
| ----------------- | ---------------------------------------------- |
| `spec/requests/`  | HTTP-level controller integration tests        |
| `spec/system/`    | End-to-end browser tests (Capybara + Selenium) |
| `spec/models/`    | Model unit tests                               |
| `spec/helpers/`   | View helper tests                              |
| `spec/factories/` | Factory Bot definitions                        |
| `spec/support/`   | Shared configuration (Capybara, etc.)          |

### CI Pipeline (`bin/ci`)

The CI script runs the following steps sequentially via `ActiveSupport::ContinuousIntegration`:

1. RuboCop (style)
2. Herb (ERB linting)
3. bundler-audit (gem vulnerabilities)
4. importmap audit (JS vulnerabilities)
5. Brakeman (static security analysis)
6. RSpec — all specs excluding system
7. RSpec — system specs only
8. `db:seed:replant` (seed validation)

**Always run `bin/ci` before pushing.**

### Code Quality Commands

```bash
bin/rubocop        # Check style
bin/rubocop -a     # Auto-fix safe violations
bin/brakeman       # Security scan
bin/bundler-audit  # Gem vulnerability audit
herb               # ERB/HTML linting
```

### Database

```bash
rails db:create      # Create databases
rails db:migrate     # Run pending migrations
rails db:seed        # Seed data
rails db:reset       # Drop + create + migrate + seed
rails db:rollback    # Undo last migration
```

The schema is currently empty (version 0) — no application models exist yet. Solid adapter schemas (`solid_cache_entries`, `solid_queue_*`, `solid_cable_messages`) are managed separately.

---

## Architecture & Patterns

### Controller Organization

Controllers are **namespaced by audience**. All current controllers serve public visitors:

```
app/controllers/
├── application_controller.rb      # Base: browser version enforcement, etag
├── concerns/
└── public/
    ├── home_controller.rb         # index (homepage)
    └── clubs_controller.rb        # show, trainers, schedules, gallery
```

**Routing pattern** — `scope module: :public` keeps URLs clean (no `/public/` prefix):

```ruby
root "public/home#index"                # GET /
scope module: :public do
  resource :club, only: [:show] do      # GET /club
    get :trainers                       # GET /club/trainers
    get :schedules                      # GET /club/schedules
    get :gallery                        # GET /club/gallery
  end
end
```

### View Structure

Views mirror the controller namespace hierarchy:

```
app/views/
├── layouts/
│   └── application.html.erb           # Main layout (navbar, main, footer, social)
├── shared/
│   ├── _navbar.html.erb               # Fixed header with logo, nav links, theme toggle
│   ├── _footer.html.erb               # Brand info, quick links, 2 location addresses
│   ├── _floating_social.html.erb      # Fixed bottom-right: Instagram + WhatsApp buttons
│   └── _page_hero.html.erb            # Reusable hero banner (image + title overlay)
├── public/
│   ├── home/
│   │   ├── index.html.erb             # Homepage: SEO meta + renders section partials
│   │   └── sections/
│   │       ├── _hero.html.erb         # Rotating disciplines hero
│   │       ├── _philosophy.html.erb   # "Felsefemiz" section
│   │       ├── _programs.html.erb     # Carousel of 8 program cards
│   │       ├── _testimonials.html.erb # Member testimonials
│   │       ├── _faq.html.erb          # FAQ accordion
│   │       ├── _membership.html.erb   # 3 pricing tiers
│   │       ├── _cta.html.erb          # Contact CTA (phone + WhatsApp)
│   │       ├── _instagram.html.erb    # Instagram embed section
│   │       ├── _gallery_break_one.html.erb
│   │       └── _gallery_break_two.html.erb
│   └── clubs/
│       ├── show.html.erb              # About the club
│       ├── trainers.html.erb          # Trainer grid with modal bios
│       ├── schedules.html.erb         # Weekly schedule table
│       └── gallery.html.erb           # Photo gallery with lightbox
└── pwa/                               # PWA views (routes currently commented out)
```

### Helper Organization

**`ApplicationHelper`** — SEO and structured data helpers:

- `set_seo_meta(title:, description:, keywords:, og_title:, og_description:, og_image:, og_type:)` — centralised SEO metadata
- `organization_schema` — JSON-LD SportsClub schema
- `structured_data_tag(schema)` — wraps schema hash in `<script type="application/ld+json">`

**`Public::ClubsHelper`** — static data for club pages:

- `trainers_data` — array of trainer hashes (name, title, image, branches, bio)
- `schedule_data`, `schedule_days`, `schedule_hours` — weekly schedule structure
- `gallery_images` — image paths and metadata for the gallery page

### Stimulus Controllers

```
app/javascript/controllers/
├── application.js          # Stimulus Application initialization
├── index.js                # Auto-loads all *_controller.js files
├── theme_controller.js     # Light/dark theme toggle (localStorage persistence)
├── carousel_controller.js  # Infinite carousel with touch/swipe support
├── gallery_controller.js   # Lightbox gallery with keyboard navigation
└── modal_controller.js     # Dialog modal opener for trainer bios
```

| Controller   | Key Behavior                                                                                                                                   |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **theme**    | Toggles between `pastel` (light) and `dracula` (dark) DaisyUI themes. Reads/writes `localStorage`. Uses `data-theme` attribute on `<html>`.    |
| **carousel** | Infinite slide carousel with `next()`/`prev()`. Touch/swipe gestures. ResizeObserver for responsive gap calculation. Debounce on rapid clicks. |
| **gallery**  | Creates a `<dialog>` lightbox dynamically. Arrow key and Escape keyboard bindings. Circular prev/next navigation. Image counter display.       |
| **modal**    | Opens a `<dialog>` element via `showModal()`. Used on trainer cards to display detailed bios. Single `open()` action with a `dialog` target.   |

### Frontend Architecture

- **Tailwind CSS 4.x** — configured in `app/assets/tailwind/application.css`
  - Custom `--font-sans` (Ubuntu) and `--font-display` (Russo One) via `@theme`
  - DaisyUI loaded as a plugin with two themes: `pastel` (default) and `dracula` (prefers-dark)
  - Source scanning: views, helpers, JavaScript directories
- **DaisyUI** component classes: `btn`, `btn-primary`, `card`, `navbar`, `swap`, `modal`, `collapse`, etc.
- **importmap-rails** — no Webpack/esbuild/Vite; all JS served directly via importmap pins

### Service Objects

For complex multi-step business logic, extract to `app/services/`:

```ruby
class SomeService
  def initialize(params)
    @params = params
  end

  def call
    # Orchestrate multi-step logic here
  end
end
```

---

## Testing Strategy

### Request Specs

Test HTTP-level controller behavior — status codes, content types, response bodies, headers:

```ruby
RSpec.describe Public::HomeController, type: :request do
  describe "GET /" do
    before { get root_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    it "includes expected content" do
      expect(response.body).to include("Kleomarcus")
    end
  end
end
```

### System Specs

End-to-end browser tests for JavaScript interactions and full user workflows:

```ruby
RSpec.describe "Homepage", type: :system do
  it "loads successfully" do
    visit root_path
    expect(page).to have_http_status(:success)
  end

  describe "theme toggle", js: true do
    it "toggles and persists theme" do
      visit root_path
      find("label.swap").click
      expect(page.evaluate_script("localStorage.getItem('theme')")).to be_present
    end
  end
end
```

### Helper Specs

Test complex helper logic (SEO helpers, data helpers):

```ruby
RSpec.describe ApplicationHelper, type: :helper do
  describe "#set_seo_meta" do
    it "sets page title with site name suffix" do
      helper.set_seo_meta(title: "Antrenörler")
      expect(helper.content_for(:title)).to include("Antrenörler")
    end
  end
end
```

### Best Practices

1. **One assertion per test** when practical; clear `it` descriptions
2. **`let` / `let!`** for setup, **`before`** for actions
3. **Factory Bot + Faker** for test data generation
4. **Capybara**: default driver `:rack_test` (fast, no JS); JS tests use `:selenium_chrome_headless`; max wait 3 seconds
5. **SimpleCov** tracks coverage automatically — aim for >80% on critical paths
6. **Test behavior, not framework internals** — trust that Rails validations work; test your custom logic

---

## Mobile-First Responsive Design

All styling follows a **strict mobile-first** approach with Tailwind CSS breakpoints:

```
Base (mobile, <640px) → sm: (≥640px) → md: (≥768px) → lg: (≥1024px) → xl: (≥1280px)
```

### Responsive Patterns

| Concern        | Mobile (base)               | Desktop (breakpoint)               |
| -------------- | --------------------------- | ---------------------------------- |
| **Typography** | Smaller scale               | Larger scale at `md:` / `lg:`      |
| **Spacing**    | Compact padding             | Generous padding at `md:` / `lg:`  |
| **Layout**     | Single column (stacked)     | Multi-column grid at `md:` / `lg:` |
| **Navigation** | Hamburger dropdown menu     | Horizontal nav bar at `lg:`        |
| **Buttons**    | Full width for primary CTAs | Auto width at `sm:`                |
| **Visibility** | Hide desktop-only elements  | Show with `lg:block` etc.          |

### Requirements

1. **Touch targets**: minimum 44×44px on mobile
2. **Font sizes**: base 16px minimum (`text-base`)
3. **Images**: `loading="lazy"` for below-fold, `width`/`height` attributes to prevent CLS
4. **Hero sections**: `min-h-screen` or `min-h-[100svh]` for mobile browser chrome
5. **Testing**: system specs with `js: true` for responsive behavior verification

---

## SEO & Semantic HTML

### Meta Tag Management

Use `set_seo_meta` from `ApplicationHelper` at the top of each view:

```erb
<%= set_seo_meta(
  title: "Antrenörlerimiz",
  description: "Profesyonel antrenör kadromuz...",
  keywords: "antrenörler, boks eğitmeni",
  og_image: "trainers.jpg"
) %>
```

**Defaults** (when parameters are omitted):

- **Title**: "Kleomarcus Spor Akademi" (no suffix)
- **Description**: "Çanakkale'nin köklü dövüş sporları akademisi..."
- **Keywords**: full Turkish keyword set covering all disciplines
- **OG image**: `public/hero-desktop.jpeg`
- **Canonical URL**: `request.original_url` (automatic)

### Structured Data (JSON-LD)

```erb
<% content_for :structured_data do %>
  <%= structured_data_tag(organization_schema) %>
<% end %>
```

The `organization_schema` helper returns a complete `schema.org/SportsClub` object including:

- Name, URL, phone, email
- Postal address (Merkez, Çanakkale, TR)
- Geo coordinates (40.16089, 26.41582)
- Social profiles (Instagram, Facebook)
- Price range (₺₺)

Pages can extend the base schema with `.merge()` for page-specific data (opening hours, event data, etc.).

### Semantic HTML Requirements

1. **One `<h1>` per page** — main page title only
2. **Heading hierarchy** — h1 → h2 → h3, no skipping levels
3. **Section IDs** — every major section gets an `id` for anchor navigation (e.g., `id="programs"`)
4. **ARIA labels** — `aria-labelledby` to connect sections with headings
5. **Semantic elements** — `<header>`, `<main>`, `<footer>`, `<nav>`, `<section>`
6. **Skip link** — skip-to-content link for keyboard/screen reader users
7. **Image alt text** — descriptive for meaningful images; empty `alt=""` + `aria-hidden="true"` for decorative

---

## Deployment

### Production Infrastructure

- **Host**: Linux-based cloud VPS managed via Kamal
- **Domain**: Production domain with `www` subdomain and SSL termination at the Kamal proxy
- **Container Registry**: Remote container registry used by Kamal for image pushes and deploys
- **Database & Storage**: SQLite3 in production with persistent storage configured at the infrastructure level
- **Background Jobs**: Solid Queue running in-process alongside the Puma application server
- **Builder**: Remote AMD64 build host accessed via SSH to avoid local ARM64 → AMD64 emulation on macOS

### Deploy Commands

```bash
kamal setup          # First deploy: provision server, push image, start containers
kamal deploy         # Subsequent deploys: build, push, rolling restart
kamal console        # Remote Rails console
kamal app logs       # Tail production logs
```

### Docker

The `Dockerfile` uses a multi-stage build:

1. **Build stage**: install gems, precompile assets and bootsnap
2. **Final stage**: minimal runtime image with `libjemalloc2` for memory optimization
3. Runs as non-root `rails` user (UID 1000)
4. Entrypoint: `bin/docker-entrypoint` → `bin/thrust bin/rails server` on port 80
