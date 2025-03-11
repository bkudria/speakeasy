# Quick Reference Cheatsheet

## Table of Contents
1. [Key Project Documents](#key-project-documents)
2. [Task Management](#task-management)
3. [TDD Workflow](#tdd-workflow)
4. [File Handling Guidelines](#file-handling-guidelines)
5. [Output Formatting](#output-formatting)

## Key Project Documents

| Document      | Purpose                 | Location               |
|---------------|-------------------------|------------------------|
| Instructions  | Working with repository | docs/instructions/*.md |
| Specification | Project functionality   | docs/specification.md  |
| Conventions   | Project standards       | docs/conventions.md    |
| Tasks         | Task tracking           | docs/tasks.org         |

## Development Commands

| Command                                         | Purpose                   |
|-------------------------------------------------|---------------------------|
| `bundle exec rspec`                             | Run full test suite       |
| `bundle exec rspec path/to/spec_file.rb`        | Run single test file      |
| `bundle exec rspec path/to/spec_file.rb:LINE`   | Run specific test         |
| `bundle exec standardrb`                        | Run linting               |
| `bin/speakeasy <input_directory>`              | Execute application       |

## Task Management

### Task Status Notation
```org
* Section
** TODO Incomplete task
** DOING In-progress task 
** DONE Completed task
```

### Task Structure
- Hierarchical organization with org-mode heading levels (* ** *** etc.)
- Point estimates (Fibonacci: 1,2,3,5,8,13,21) stored in PROPERTIES drawers
- Include file references and points in PROPERTIES drawers at appropriate levels
- Parent tasks should be marked DONE if and only if all child tasks are complete
- Re-evaluate point estimates after planning tasks; break down if they exceed 5 points

### Example Task Structure
```org
* Main Section
** TODO Main task
:PROPERTIES:
:FILES: path/to/files
:END:
*** TODO Sub-task with files needed
:PROPERTIES:
:POINTS: 2
:END:
**** TODO Leaf task
:PROPERTIES:
:POINTS: 1
:END:
**** TODO Another leaf task
:PROPERTIES:
:POINTS: 1
:END:
*** TODO Another sub-task
:PROPERTIES:
:POINTS: 3
:END:
```

## TDD Workflow

**Note**: Tests are only required for program functionality in lib/. Refactors, test suite improvements, and other non-core changes don't need strict TDD.

1. **Start**: Identify next uncompleted task with `TODO` state and verify its status in tasks.org reflects the current project state
2. **Mark In-Progress**: As soon as the task becomes the current focus, mark it as `DOING` in tasks.org
3. **Write Test**: Create failing test (the task should already be marked as `DOING`)
4. **Verify Failure**: Confirm test fails appropriately, and verify the task remains marked as `DOING` in tasks.org
5. **Status Verification**: Verify that tasks.org has been updated to show the task as in-progress before proceeding
6. **Implement**: Write minimum code to make test pass but don't update task status
7. **Verify Success**: Confirm test passes and all tests still pass
8. **Complete**: Mark task as `DONE` in tasks.org only after test passes
9. **Status Verification**: Verify that tasks.org has been updated to show the task as completed before moving to the next task

**Important**: 
- Mark tasks as `DOING` as soon as they become the current focus, including during research or planning
- Tasks being actively researched or planned should be marked as `DOING`
- Tasks being refined or broken down should not be changed to `DOING` (unless already marked as such)
- Task status in tasks.org must reflect the actual project state at all times
- After any interruption or context switch, verify task status accuracy before continuing
- For detailed guidelines, refer to [Task Status Management](02_documents_and_rules.md#8-task-status-management)
- The editor engineer must update tasks.org at each status change point, and the AI assistant must verify these updates

## Output Formatting

### Task Analysis Format
```
<task_analysis>
- Analysis of requirements and rules
- List of needed files with explanations
- Step-by-step approach plan
- Consideration of impacts
</task_analysis>
```

### Response Format
```
<response>
- Clear, unambiguous instructions
- Code to add/modify
- Task status update instructions
- Specification updates if needed
</response>
```

---

For detailed information, refer to the specific instruction files:
- [Responsibilities and Introduction](01_responsibilities_and_introduction.md)
- [Key Documents and Rules](02_documents_and_rules.md)
- [Request Handling](03_request_handling.md)
- [Workflow](04_workflow.md)
- [Output Examples](05_output_examples.md)
