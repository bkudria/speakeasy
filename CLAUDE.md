# Development Information

The development information has been moved to:
- Code style and architecture: [docs/conventions.md](/docs/conventions.md)
- Development commands: [docs/instructions/06_quick_reference.md](/docs/instructions/06_quick_reference.md#development-commands)

# Instructions for Claude

## Initial Documentation Reading

For complete documentation reading requirements, refer to the canonical reference:
[docs/instructions/04_workflow.md#documentation-requirements](/docs/instructions/04_workflow.md#documentation-requirements)

Key points:
- Read all documentation at the start of every session
- Read files listed in the :FILES: property of any task before starting work
- Read instructions files before starting task refinement
- Review documentation before answering project questions

## Role and Responsibilities
- Act as an expert software developer specializing in test-driven development
- Design, plan, and complete development tasks following best practices
- Maintain and update task lists in the project
- Answer questions about project code with deep technical understanding

## Key Commands
- Run all tests: `bundle exec rspec`
- Run single test: `bundle exec rspec path/to/spec_file.rb:LINE`
- Run linting: `bundle exec standardrb`
- Execute app: `bin/speakeasy <input_directory>`

## Ruby Conventions
- Use Standard Ruby for style (bundle exec standardrb)
- Double quotes for strings
- Add frozen_string_literal comment
- Classes in PascalCase, methods in snake_case
- Mark private methods explicitly
- Modular design with single-responsibility classes
- Prefer composition over inheritance

## Task Management

For complete task management guidelines, refer to these canonical references:
- Task format and structure: [docs/instructions/02_documents_and_rules.md#3-task-list-format](/docs/instructions/02_documents_and_rules.md#3-task-list-format)
- Task status management: [docs/instructions/04_workflow.md#2-task-status-management](/docs/instructions/04_workflow.md#2-task-status-management)
- Task order and selection: [docs/instructions/04_workflow.md#task-order-and-selection](/docs/instructions/04_workflow.md#task-order-and-selection)

Key points:
- Tasks follow org-mode format with states: TODO → DOING → DONE
- The next task is always the first incomplete task in sequential order
- Complete one task at a time following TDD workflow
- Process entire sections before moving to the next section

## TDD Workflow
For the complete and canonical TDD workflow, refer to [docs/instructions/04_workflow.md](/docs/instructions/04_workflow.md#1-tdd-workflow).

Key workflow steps:
1. Identify next uncompleted task with TODO state
2. Read all documentation files listed in task's :FILES: property
3. Ask clarifying questions about requirements
4. Mark task as DOING before beginning work
5. Write failing test first
6. Verify test fails appropriately
7. Implement minimum code to make test pass
8. Verify tests pass
9. Mark task as DONE only after tests pass
10. Report the next task to the user

## Project-Specific

For complete project specifications, refer to [docs/specification.md](/docs/specification.md)

Key points:
- Speakeasy processes Amazon Transcribe JSON output
- Extracts speaker audio segments and enables speaker identification
- Generates structured CSV transcripts
- Highlights segments requiring review
- Tests only needed for program functionality in lib/
- Refactors and test improvements don't need strict TDD