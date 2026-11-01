# Kleomarcus

Source code for [kleomarcus.com](https://www.kleomarcus.com), the website of Kleomarcus Spor Akademi, a combat sports and fitness academy in Çanakkale, Turkey.

The public site presents the club, its disciplines, trainers, gallery and press coverage, and takes enrollment applications. An admin panel manages that content.

## Stack

| Area        | Tools                                                                    |
| ----------- | ------------------------------------------------------------------------ |
| Framework   | Ruby 3.4, Rails 8.1                                                      |
| Frontend    | Hotwire (Turbo, Stimulus), import maps, Propshaft, Tailwind CSS 4, daisyUI |
| Data        | PostgreSQL 16, Solid Cache, Solid Queue, Solid Cable, Active Storage      |
| Deployment  | Docker, Kamal 2, Thruster, Puma                                          |
| Quality     | RSpec, Factory Bot, Capybara, RuboCop, Herb, Brakeman, bundler-audit     |

## Getting started

Requires Ruby 3.4.4 (see `.ruby-version`), PostgreSQL 16 and libvips.

```bash
git clone https://github.com/sametpolat7/kleomarcus.git
cd kleomarcus
bin/setup
```

`bin/setup` installs gems, creates and seeds the database, then starts the app at http://localhost:3000. Pass `--skip-server` to set up without starting it. On later runs, `bin/dev` starts the Rails server together with the Tailwind watcher.

Development and test connect to PostgreSQL on `localhost` as your OS user with no password. Set `DATABASE_HOST`, `DATABASE_USERNAME` or `DATABASE_PASSWORD` if your installation differs.

The admin panel lives at `/admin`. Seeds do not create a user, so create the first admin once:

```bash
bin/rails runner 'User.create!(username: "admin", email_address: "admin@example.com", password: "change-me", role: :admin)'
```

## Testing and quality

```bash
bin/ci                               # full pipeline: style, security, assets, specs, seeds
bundle exec rspec                    # all specs, including system tests
bin/rubocop                          # Ruby style (add -a to auto-correct)
bundle exec herb analyze app/views   # ERB lint
bin/brakeman                         # static security analysis
bin/bundler-audit                    # gem vulnerability audit
bin/importmap audit                  # JavaScript vulnerability audit
```

GitHub Actions runs the same checks on every pull request and on every push to `main`.

## Deployment

The app runs as a single Docker container on a Linux VPS, deployed with [Kamal](https://kamal-deploy.org). PostgreSQL runs beside it as a Kamal accessory bound to loopback, and both the database files and Active Storage uploads live in named Docker volumes that outlive containers.

```bash
bin/kamal deploy               # build, push, health check, then switch traffic
bin/kamal rollback <version>   # return to a previously deployed image
bin/kamal console              # production Rails console
bin/kamal logs                 # tail production logs
bin/kamal dbc                  # production database console
```

Migrations need no separate step. The container entrypoint runs `db:prepare` before Puma starts, and traffic only moves to the new container once `/up` responds. A failed build, migration or health check leaves the running version in place.

The database accessory is provisioned once, before the first deploy:

```bash
bin/kamal accessory boot postgres
```

Secrets (`RAILS_MASTER_KEY`, `KAMAL_REGISTRY_PASSWORD`, `POSTGRES_PASSWORD`) are resolved through `.kamal/secrets`, which documents where each one comes from.

## License

Copyright © 2025–2026 Samet Polat. All rights reserved. See [LICENSE](LICENSE).
