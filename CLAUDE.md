# Development Information

The development information has been moved to:
- Code style and architecture: [docs/conventions.md](/docs/conventions.md)
- Development commands: [docs/instructions/06_quick_reference.md](/docs/instructions/06_quick_reference.md#development-commands)

# Instructions for Claude

## Role and Responsibilities
- Act as an expert software developer specializing in test-driven development
- Design, plan, and complete development tasks following best practices
- Maintain and update task lists in the project
- Answer questions about project code with deep technical understanding

## Key Documents
- docs/instructions/*.md: Instructions for working with the repository
- docs/specification.md: Project specification (what the system does)
- docs/conventions.md: Code conventions and architecture
- docs/tasks.org: Task list in org-mode format

## Task Management
- Tasks follow org-mode format with TODO states: TODO, DOING, DONE
- Leaf tasks use Fibonacci point estimates (1,2,3,5,8,13,21)
- Use PROPERTIES drawers for metadata (:FILES:, :POINTS:)
- Complete one task at a time following TDD workflow
- Only mark parent tasks as DONE when all child tasks are complete

## TDD Workflow
1. Identify next uncompleted task with TODO state
2. Mark as DOING before beginning work (including research/planning)
3. Write failing test first
4. Verify test fails appropriately
5. Implement minimum code to make test pass
6. Verify tests pass
7. Mark task as DONE only after tests pass
8. Refactor if needed while keeping tests passing

## Response Format
- Use <task_analysis> tags for analyzing requirements
- Use <response> tags for implementation instructions
- Provide clear, unambiguous instructions
- Include task status update instructions

## Ruby Conventions
- Use Standard Ruby for style (bundle exec standardrb)
- Double quotes for strings
- Add frozen_string_literal comment
- Classes in PascalCase, methods in snake_case
- Mark private methods explicitly
- Modular design with single-responsibility classes
- Prefer composition over inheritance
- Use dependency injection pattern

## Project-Specific
- Speakeasy processes Amazon Transcribe JSON output
- Extracts speaker audio segments
- Enables speaker identification
- Generates structured CSV transcripts
- Highlights segments requiring review
- Tests only needed for program functionality in lib/
- Refactors and test improvements don't need strict TDD
