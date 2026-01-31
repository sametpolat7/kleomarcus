# Kleomarcus - AI Coding Agent Instructions

## Project Overview

Kleomarcus is a Rails 8.1 web application for Kleomarcus Fight Club built with modern Rails conventions using the Omakase stack: Hotwire (Turbo + Stimulus), Tailwind CSS, and PostgreSQL.

## Stack & Dependencies

- **Ruby 3.4.4** / **Rails 8.1.1**
- **Database**: PostgreSQL with Solid adapters (solid_cache, solid_queue, solid_cable)
- **Frontend**: Tailwind CSS 4.1.16 + DaisyUI component library
- **JavaScript**: importmap-rails (no bundler), Stimulus controllers, Turbo
- **Testing**: RSpec with Factory Bot, Faker, Capybara, SimpleCov, Selenium
- **Deployment**: Kamal with Docker support
- **Code Quality**: RuboCop (Rails Omakase), Brakeman, bundler-audit, Herb (ERB linter)

## Ruby & Rails Coding Standards

### Style Guide Compliance

**ALWAYS** follow the official Ruby Style Guide and Rails conventions:

- **2-space indentation** for Ruby files (enforced by RuboCop)
- **Snake_case** for methods, variables, file names; **CamelCase** for classes/modules
- **SCREAMING_SNAKE_CASE** for constants
- **Predicate methods** end with `?`; **dangerous methods** end with `!`
- **String literals**: Prefer double quotes `""`
- **Hash syntax**: Modern style `{ key: value }` for symbol keys, `{ "key" => value }` for string keys
- **Method chaining**: Align dots on subsequent lines when wrapping
- **Line length**: Aim for 120 characters max (RuboCop default)
- **No trailing whitespace**, consistent blank lines between methods

### Rails Best Practices

- **Controllers**: Keep thin, extract business logic to models/services
- **RESTful routes**: Use standard actions (index, show, new, create, edit, update, destroy) if possible
- **Views**: Use partials for reusable components, avoid logic in views
- **Strong parameters**: Always use for mass assignment protection
- **Callbacks**: Use sparingly, prefer explicit service objects for complex workflows
- **Queries**: Use ActiveRecord query interface, avoid raw SQL unless necessary
- **Validations**: Place in models, not controllers
- **I18n**: Use locale files for all user-facing text (currently using Turkish locale)
- **Concerns**: Extract shared functionality, properly test included modules

### Security Standards

- **CSRF protection**: Enabled by default, never disable
- **Strong parameters**: Required for all controller create/update actions
- **SQL injection**: Use parameterized queries, avoid string interpolation in queries
- **XSS prevention**: Use ERB escaping by default (`<%= %>`), explicitly mark safe HTML with `raw` or `html_safe` only when necessary
- **Mass assignment**: Use strong parameters, never permit all params
- **Authentication**: Use `has_secure_password` or established gems (Devise, Sorcery)
- **Secrets**: Store in `credentials.yml.enc`, never commit sensitive data

## Development Workflows

### Local Development

```bash
bin/dev          # Primary command: runs Rails server + Tailwind CSS watcher
bin/setup        # First-time setup: installs dependencies, creates DB, seeds data
rails console    # Interactive Ruby console with app loaded
```

The `bin/dev` script uses `Procfile.dev` to run multiple processes concurrently.

### Testing

```bash
bundle exec rspec                    # Run all specs
bundle exec rspec spec/models/       # Run specific directory
bundle exec rspec spec/path_spec.rb  # Run single file
bin/ci                               # Run full CI suite (uses config/ci.rb)
```

**Test organization**:

- `spec/requests/` - Controller/integration tests (HTTP requests)
- `spec/system/` - End-to-end browser tests with Capybara
- `spec/models/` - Model unit tests
- `spec/helpers/` - View helper tests
- `spec/factories/` - Factory Bot definitions
- `spec/support/` - RSpec configuration and helpers

### Code Quality

```bash
bin/rubocop        # Ruby style checks (Rails Omakase)
bin/rubocop -a     # Auto-fix safe violations
bin/brakeman       # Security vulnerability scan
bin/bundler-audit  # Check gems for known vulnerabilities
herb               # ERB/HTML linting
```

**Run before committing**: `bin/ci` to ensure all checks pass.

### Database

```bash
rails db:create    # Create database
rails db:migrate   # Run pending migrations
rails db:seed      # Load seed data
rails db:reset     # Drop, create, migrate, seed
rails db:rollback  # Undo last migration
```

Solid adapters use database tables for cache, jobs, and WebSocket connections (no Redis needed).

## Architecture & Patterns

### Controller Organization

Controllers are **namespaced** to separate concerns:

- **Public-facing**: `app/controllers/public/` → routes under `scope module: :public`
  - Example: `Public::HomeController` at `app/controllers/public/home_controller.rb`
  - Route: `root "public/home#index"`
  - Pattern: `scope module: :public do ... end` (no URL namespace prefix)

### Frontend Architecture

- **Tailwind CSS 4.x**: Configuration in `app/assets/tailwind/` with DaisyUI
- **DaisyUI**: Component library (e.g., `btn`, `btn-primary`, `card`, `navbar`)
- **Stimulus Controllers**: Auto-loaded from `app/javascript/controllers/` via importmap
  - Naming: `theme_controller.js` → `data-controller="theme"`
  - Actions: `data-action="click->theme#toggle"`
  - Targets: `data-theme-target="button"`
- **No JavaScript bundler**: Use importmap pins in `config/importmap.rb`

### View Structure

- Views mirror controller namespaces: `app/views/public/home/index.html.erb`
- Main layout: `app/views/layouts/application.html.erb`
- Shared partials: `app/views/shared/` for reusable components
- Use `content_for` blocks for page-specific meta tags, scripts, styles

### Service Objects (Future Pattern)

For complex business logic, extract to `app/services/`:

```ruby
# app/services/membership_registration.rb
class MembershipRegistration
  def initialize(user, plan)
    @user = user
    @plan = plan
  end

  def call
    # Multi-step business logic here
  end
end

# Usage in controller
def create
  result = MembershipRegistration.new(current_user, params[:plan]).call
  # ...
end
```

## Testing Strategy

### Test Types & Organization

**Request Specs** (`spec/requests/`):

- Test controller actions, HTTP responses, redirects
- Verify response status, content type, body content
- Check authentication, authorization flows
- Simple, focused assertions

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

**System Specs** (`spec/system/`):

- End-to-end user workflows with real browser
- JavaScript interactions (use `js: true`)
- Form submissions, navigation flows
- Mobile/responsive behavior testing

```ruby
RSpec.describe "Homepage", type: :system do
  it "loads successfully" do
    visit root_path
    expect(page).to have_http_status(:success)
  end

  describe "theme toggle", js: true do
    it "toggles and persists theme" do
      visit root_path
      find('label.swap').click
      expect(page.evaluate_script("localStorage.getItem('theme')")).to be_present
    end
  end
end
```

**Model Specs** (`spec/models/`):

- Validations, associations, scopes
- Instance and class methods
- Business logic in models

```ruby
RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "validates presence of email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end
end
```

**Helper Specs** (`spec/helpers/`):

- Minimal, only for complex helpers
- Most helpers should be simple and self-evident

### Testing Best Practices

1. **Keep tests simple and readable**
   - One assertion per test when possible
   - Clear test names describing behavior
   - Use `let` and `let!` for setup, `before` for actions

2. **Use Factory Bot for test data**

   ```ruby
   # spec/factories/users.rb
   FactoryBot.define do
     factory :user do
       email { Faker::Internet.email }
       password { "password123" }
     end
   end
   ```

3. **Capybara configuration** (`spec/support/capybara.rb`)
   - Default: `:rack_test` (fast, no JS)
   - JS tests: `:selenium_chrome_headless`
   - Max wait time: 3 seconds

4. **Test coverage**
   - SimpleCov tracks coverage automatically
   - Aim for >80% coverage on critical paths
   - Not every line needs testing, focus on behavior

5. **Avoid testing framework internals**
   - Don't test Rails validations themselves
   - Test your business logic and custom behavior
   - Trust that Rails works correctly

## Mobile-First Responsive Design

This project **strictly follows mobile-first** responsive design strategy using Tailwind CSS breakpoints.

### Breakpoint System

**Always define base styles for mobile first**, then progressively enhance for larger screens:

```
Base (mobile, <640px)  →  sm: (≥640px)  →  md: (≥768px)  →  lg: (≥1024px)  →  xl: (≥1280px)
```

### Mobile-First Class Patterns

**Typography**: Start small, scale up based on content hierarchy and importance (hero headings use largest scale, section headings medium scale, subsection headings smaller scale, body text minimal scaling)

**Spacing**: Compact on mobile, generous on desktop (adjust based on section importance - major sections like hero use generous padding, standard sections use moderate padding, minor sections and cards use minimal padding)

**Grid**: Stack on mobile, columns on larger screens (choose column count based on content type - 2 columns for features/testimonials, 3 columns for services/team members, 4 columns for icons/small cards, asymmetric layouts for sidebar + main content)

**Buttons**: Size based on importance and context (primary CTAs largest with full width on mobile, secondary actions medium/default size, tertiary/icon buttons small)

**Visibility**: Show/hide based on screen size and layout needs (desktop navigation horizontal, mobile navigation hamburger menu, responsive images with different sources for different breakpoints)

### Responsive Design Requirements

1. **Touch Targets**: Minimum 44×44px on mobile (DaisyUI `btn-sm` meets this)
2. **Font Sizes**: Base at 16px minimum (Tailwind `text-base` = 16px)
3. **Spacing**: Always use responsive scales, adjust padding based on section importance and context
4. **Images**: Always include `loading="lazy"` for below-fold images, descriptive `alt` text for meaningful images, empty `alt=""` for decorative images, use `width` and `height` attributes to prevent CLS
5. **Navigation**: Mobile hamburger menu with slide-out or dropdown, desktop horizontal navigation (threshold typically `lg:` breakpoint)
6. **Hero Sections**: Use `min-h-screen` for standard viewports, `min-h-[100svh]` when accounting for mobile browser chrome, adjust height based on content needs
7. **Testing**: Use system specs with `js: true` to verify responsive behaviors and breakpoint transitions

## SEO & Semantic HTML

### Meta Tag Structure

The `application.html.erb` layout includes comprehensive SEO support via `content_for` blocks:

```erb
<%# In page views (e.g., index.html.erb) %>
<% content_for :title, "Sayfa Başlığı | Kleomarcus" %>
<% content_for :description, "Sayfa açıklaması - 150-160 karakter arası." %>
<% content_for :keywords, "anahtar, kelimeler, virgülle, ayrılmış" %>
<% content_for :canonical, request.original_url %>

<%# Open Graph %>
<% content_for :og_title, "Sosyal medya başlığı" %>
<% content_for :og_description, "Sosyal medya açıklaması" %>
<% content_for :og_image, image_url("og-image.jpg") %>
<% content_for :og_type, "website" %>
```

### Structured Data (JSON-LD)

Include schema.org markup for rich search results:

```erb
<% content_for :head do %>
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
6. **Skip Link**: Include skip-to-content link for keyboard users

### Image SEO

```erb
<%# Meaningful images: Descriptive alt text %>
<img
  src="image.jpg"
  alt="Açıklayıcı alternatif metin"
  loading="lazy"
  width="800" height="600"
>

<%# Decorative images: Empty alt and aria-hidden %>
<img
  src="decoration.jpg"
  alt=""
  aria-hidden="true"
  loading="lazy"
  width="800" height="600"
>
```

### Internal Linking

- Use anchor links for same-page navigation: `href="#programs"`
- All navigation links should be accessible and keyboard-navigable
- Footer should contain sitemap-style links to all major sections
