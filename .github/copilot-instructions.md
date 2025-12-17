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
