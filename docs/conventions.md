# Speakeasy Development Conventions

## Test Framework
- Test Framework: RSpec
- Run full test suite: `bundle exec rspec`
- Run single test file: `bundle exec rspec path/to/spec_file.rb`
- Run specific test: `bundle exec rspec path/to/spec_file.rb:LINE_NUMBER`

## Code Style
- Uses Standard Ruby gem for style enforcement (`bundle exec standardrb`)
- Use double quotes for strings
- Add `# frozen_string_literal: true` at the top of files
- Classes use PascalCase, methods use snake_case
- Mark private methods explicitly with `private` keyword
- Method names should be descriptive and indicate purpose

## Architecture
- Modular design with single-responsibility classes
- Use composition over inheritance
- Dependency injection pattern (pass dependencies to constructor)
- Centralized error handling with `handle_error` helper

## Execution
- Execute application: `bin/speakeasy <input_directory>`
