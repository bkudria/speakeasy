# Quick Reference Cheatsheet

## Table of Contents
1. [Key Project Documents](#1-key-project-documents)
2. [Development Commands](#2-development-commands)
3. [Task Management](#3-task-management)
4. [TDD Workflow](#4-tdd-workflow)
5. [Output Formatting](#5-output-formatting)

## 1. Key Project Documents

| Document      | Purpose                 | Location               |
|---------------|-------------------------|------------------------|
| Instructions  | Working with repository | docs/instructions/*.md |
| Specification | Project functionality   | docs/specification.md  |
| Conventions   | Project standards       | docs/conventions.md    |
| Tasks         | Task tracking           | docs/tasks.org         |

## 2. Development Commands

| Command                                         | Purpose                   |
|-------------------------------------------------|---------------------------|
| `bundle exec rspec`                             | Run full test suite       |
| `bundle exec rspec path/to/spec_file.rb`        | Run single test file      |
| `bundle exec rspec path/to/spec_file.rb:LINE`   | Run specific test         |
| `bundle exec standardrb`                        | Run linting               |
| `bin/speakeasy <input_directory>`              | Execute application       |

## 3. Task Management

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
- Tasks must be completed in sequential order - never skip ahead
- Complete all tasks in a section before moving to the next section
  - Sections are defined by top-level headings (single * prefix) in tasks.org
  - All tasks and subtasks in one section must be completed before starting the next
  - This ensures focused development and prevents context switching
- Within a section, follow the hierarchical order of tasks
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

## 4. TDD Workflow

For the complete and canonical TDD workflow reference, see [04_workflow.md](04_workflow.md#1-tdd-workflow).

**Note**: Tests are only required for program functionality in lib/. Refactors, test suite improvements, and other non-core changes don't need strict TDD.

### Quick Reference Steps

1. **Documentation**: Read all files listed in the task's :FILES: property
2. **Identify**: Select the next uncompleted task (`TODO` state) in sequential order
3. **Clarify**: Ask questions to understand task requirements
4. **Mark In-Progress**: Mark task as `DOING` in tasks.org before starting work
5. **Write Test**: Create failing test for the desired behavior
6. **Verify Failure**: Confirm test fails for the expected reason
7. **Implement**: Write minimum code to make test pass
8. **Verify Success**: Confirm tests pass and no regressions
9. **Complete**: Mark task as `DONE` in tasks.org after tests pass
10. **Report**: Tell the user what the next task will be

### Key Reminders

- Always read documentation at the start of each session
- For complete Task Status Management guidelines, see [04_workflow.md#2-task-status-management](04_workflow.md#2-task-status-management)
- Mark tasks as `DOING` as soon as they become the current focus
- Task status must reflect the actual project state at all times
- Verify task status after any interruption or context switch
- Follow all hierarchy status rules for parent tasks and sections

## 5. Output Formatting

### Task Analysis Format
```
<task_analysis>
- Analysis of requirements and rules
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