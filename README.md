# Kleomarcus

A Rails 8.1 web application for Kleomarcus Fight Club — a martial arts and combat sports academy based in Çanakkale, Turkey.

## Requirements

- Ruby 3.4.4
- Rails 8.1.1

## Technology Stack

- **Backend**: Ruby on Rails 8.1.1
- **Frontend**: Tailwind CSS 4, DaisyUI, Hotwire (Turbo, Stimulus)
- **Database**: SQLite3 with Solid adapters (cache, queue, cable)
- **Asset Pipeline**: Propshaft
- **JavaScript**: importmap-rails
- **Testing**: RSpec, Factory Bot, Capybara, Selenium
- **Deployment**: Kamal with Docker (Thruster)
- **Code Quality**: RuboCop (Rails Omakase), Brakeman, Bundler Audit, Herb

## Installation

Clone the repository:

```bash
git clone https://github.com/sametpolat7/kleomarcus.git
cd kleomarcus
```

Run the setup script:

```bash
bin/setup
```

This will install dependencies, create the database, run migrations, and seed initial data.

## Development

Start the development server:

```bash
bin/dev
```

This runs both the Rails server and Tailwind CSS watcher. The application will be available at `http://localhost:3000`.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

Run the full CI suite (tests, linters, security checks):

```bash
bin/ci
```

Run specific test types:

```bash
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
bundle exec rspec spec/system/
```

## Code Quality

Run RuboCop for style checks:

```bash
bin/rubocop
bin/rubocop -a  # Auto-fix violations
```

Run security checks:

```bash
bin/brakeman
bin/bundler-audit
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
