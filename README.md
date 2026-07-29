# Kleomarcus

Web presence for **Kleomarcus Spor Akademi** — a combat sports and fitness academy in Çanakkale, Turkey. Built with Ruby on Rails 8.1.

## Tech Stack

| Layer      | Technology                                          |
| ---------- | --------------------------------------------------- |
| Backend    | Ruby 3.4.4, Rails 8.1.3                             |
| Frontend   | Tailwind CSS 4, DaisyUI, Hotwire (Turbo + Stimulus) |
| Database   | PostgreSQL 16, Solid Cache / Queue / Cable          |
| Assets     | Propshaft, importmap-rails                          |
| Storage    | Active Storage, libvips                             |
| Deployment | Kamal 2, Docker, Thruster                           |
| Testing    | RSpec, Factory Bot, Capybara, Selenium              |
| Quality    | RuboCop, Brakeman, bundler-audit, Herb              |

## Getting Started

Requires Ruby 3.4.4, Rails 8.1.3 and a running PostgreSQL server.

```bash
git clone https://github.com/sametpolat7/kleomarcus.git
cd kleomarcus
bin/setup   # Install deps, prepare DB, seed data
bin/dev     # Start Rails server + Tailwind watcher → http://localhost:3000
```

Development and test connect to `localhost` as your OS user with no password. Set `DATABASE_HOST`, `DATABASE_USERNAME` or `DATABASE_PASSWORD` if your installation differs.

## Testing & CI

```bash
bundle exec rspec   # Run all specs
bin/ci              # Full pipeline: lint → audit → security → assets → specs → seeds
```

## Code Quality

```bash
bin/rubocop                       # Style check (auto-fix with -a)
bin/brakeman                      # Security scan
bin/bundler-audit                 # Dependency audit
bin/importmap audit               # JavaScript dependency audit
bundle exec herb analyze app/views  # ERB lint
```

## Deployment

The app runs on a single Linux VPS as a Docker container, deployed with [Kamal](https://kamal-deploy.org). PostgreSQL runs beside it as a Kamal accessory, bound to loopback and reachable only over the private Docker network. Database files and Active Storage uploads live in named Docker volumes, so they outlive every container.

```bash
bin/kamal deploy               # Build, push, health check, then switch traffic over
bin/kamal rollback <version>   # Return to a previously deployed image
bin/kamal console              # Remote Rails console
bin/kamal logs                 # Tail production logs
bin/kamal dbc                  # Remote database console
```

Migrations need no separate step: the container entrypoint runs `db:prepare` before Puma starts, and traffic moves to the new container only once `/up` responds. A failed build, migration or health check therefore leaves the running version serving.

The database accessory is provisioned once rather than per deploy:

```bash
bin/kamal accessory boot postgres
```

## License

All rights reserved. See [LICENSE](LICENSE) for details.
