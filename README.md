# Kleomarcus

Web presence for **Kleomarcus Spor Akademi** — a combat sports and fitness academy in Çanakkale, Turkey. Built with Ruby on Rails 8.1.

## Tech Stack

| Layer      | Technology                                          |
| ---------- | --------------------------------------------------- |
| Backend    | Ruby 3.4.4, Rails 8.1.3                             |
| Frontend   | Tailwind CSS 4, DaisyUI, Hotwire (Turbo + Stimulus) |
| Database   | SQLite3, Solid Cache / Queue / Cable                |
| Assets     | Propshaft, importmap-rails                          |
| Deployment | Kamal 2, Docker, Thruster                           |
| Testing    | RSpec, Factory Bot, Capybara, Selenium              |
| Quality    | RuboCop, Brakeman, bundler-audit, Herb              |

## Getting Started

```bash
git clone https://github.com/sametpolat7/kleomarcus.git
cd kleomarcus
bin/setup   # Install deps, prepare DB, seed data
bin/dev     # Start Rails server + Tailwind watcher → http://localhost:3000
```

## Testing & CI

```bash
bundle exec rspec   # Run all specs
bin/ci              # Full pipeline: lint → audit → security → specs → seed check
```

## Code Quality

```bash
bin/rubocop         # Style check (auto-fix with -a)
bin/brakeman        # Security scan
bin/bundler-audit   # Dependency audit
herb                # ERB lint
```

## Deployment

The app deploys as a Docker container via [Kamal](https://kamal-deploy.org) to a Linux VPS.

```bash
kamal setup    # First deploy: provision, push, start
kamal deploy   # Build, push, rolling restart
kamal console  # Remote Rails console
kamal app logs # Tail production logs
```

## License

All rights reserved. See [LICENSE](LICENSE) for details.
