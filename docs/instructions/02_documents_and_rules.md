# Key Documents and Rules

## Table of Contents
1. [Important Documents](#1-important-documents)
2. [Task Management Rules](#2-task-management-rules)
3. [Task List Format](#3-task-list-format)
4. [Specification Updates](#4-specification-updates)
5. [Task Completion Process](#5-task-completion-process)
6. [Discovered Task Management](#6-discovered-task-management)
7. [Task Status Management](#7-task-status-management)

## 1. Important Documents
- docs/instructions/*.md: Instructions for working with this repository.
- docs/specification.md: Project specification, describing functionality without implementation details.
- docs/conventions.md: Conventions, configurations, and notable aspects of the project.
- docs/tasks.org: Task list in org-mode format.

## 2. Task Management Rules
1. Complete only one task or sub-task at a time.
2. The next task is always the first incomplete task (TODO state) in the list.
3. Tasks must be completed in sequential order - never skip ahead.
4. Complete all tasks in a section before moving to the next section.
5. Within a section, follow the hierarchical order of tasks.
6. Follow the TDD workflow as detailed in [Workflow: TDD Workflow](04_workflow.md#1-tdd-workflow).
7. Do not include implementation details in specification.md.

## 3. Task List Format

### Task Status Notation
Tasks are tracked in org-mode format with TODO states:
- Incomplete: `TODO Task description`
- In-progress: `DOING Task description`
- Completed: `DONE Task description`

Examples:
```org
* Development
** TODO Implement ConfidenceCalculator class
** DOING Add error handling to TranscriptProcessor
** DONE Create directory structure for project
```

### Hierarchy Structure
- Use org-mode hierarchy with * for main sections, ** for top-level tasks, *** for subtasks, etc.
- Include point estimates for leaf tasks only, using the Fibonacci scale (1, 2, 3, 5, 8, 13, 21…) in the PROPERTIES drawer.
- Non-leaf tasks can have POINTS properties calculated from their children.

### Metadata Management
Use PROPERTIES drawers for all metadata:
- Use `:FILES:` to list files relevant to a task
- Use `:POINTS:` to store complexity/effort estimates
- Place property drawers as high in the hierarchy as possible
- Update properties during task refinement or when adding new tasks

Example:
```org
** TODO Create ConfidenceCalculator utility
:PROPERTIES:
:FILES: lib/csv_generator.rb, lib/low_confidence_detector.rb
:END:
*** TODO Extract calculate_confidence_metrics method
:PROPERTIES:
:POINTS: 2
:END:
*** TODO Extract confidence calculation from process_segment
:PROPERTIES:
:POINTS: 3
:END:
```

## 4. Specification Updates
1. Evaluate the need for specification.md updates for each task changing user-visible functionality.
2. Seek user guidance when unsure about potential updates.
3. Focus on describing what the system does, not how it does it.

## 5. Task Completion Process
1. Identify the next uncompleted task or sub-task. The next task is always the first incomplete task (TODO state) in the list - never skip ahead.
2. Review related tasks and specifications.
3. Gather complete information about the task:
   - Ask clarifying questions before beginning the task
   - Address any ambiguities in the task description
   - Ensure you understand the requirements fully 
   - Document gathered information for reference during implementation
4. Analyze requirements and current code.
5. Consider impact and side effects of changes.
6. Determine necessary changes at a tactical level.
7. Scope changes using the provided Fibonacci scale.
8. Break down tasks exceeding 5 points into smaller subtasks.
9. After selecting a task and making a plan for it, re-evaluate its point-score effort number. If the re-evaluated score exceeds 5 points, break down the task into smaller subtasks.
10. Use standard library tools and language idioms when possible.
11. Ensure changes adhere to all rules, especially regarding tests and specifications.
12. Only mark a task as DONE after receiving explicit confirmation that tests have passed
13. Only mark a task as DOING after receiving confirmation that the test fails appropriately

## 6. Discovered Task Management

### Documentation Requirements
When discovering new tasks during implementation:
- Document them immediately in tasks.md to prevent forgetting
- Use the standard task format with appropriate status indicators
- Include point estimates for leaf tasks following the Fibonacci scale

### Hierarchy Placement
- Add as sub-tasks to the current task if closely related to current work
- Add as sibling tasks if related to the same parent but independent of current work
- Create a new section if the task belongs to a different functional area

### Prioritization Guidelines
- Critical path tasks (blocking other work) should be prioritized highest
- Bug fixes that impact existing functionality should be prioritized over new features
- Tasks with dependencies on the current implementation should be completed before unrelated tasks
- Consider point estimates when prioritizing similarly important tasks

### Work Interruption Criteria
Continue with the current task unless the discovered task:
- Reveals a critical bug in the code being modified
- Indicates a fundamental flaw in the current approach
- Is a prerequisite for completing the current task
- Otherwise, complete the current task before addressing discovered tasks

### Relationship Documentation
When a task is discovered during another task, note the relationship:
- Add a comment in the format: `(Discovered during Task X.Y.Z)`
- If the discovered task is a blocker, note: `(Blocks Task X.Y.Z)`
- If the discovered task is blocked by another task, note: `(Blocked by Task X.Y.Z)`

### Categorization Process
- Technical debt: Refactoring, optimization, or cleanup tasks
- Bug fixes: Corrections to existing functionality
- Feature enhancements: Improvements to existing features
- New features: Entirely new functionality
- Documentation: Updates to documentation or comments

## 7. Task Status Management

For the complete and canonical Task Status Management reference, see [04_workflow.md#2-task-status-management](04_workflow.md#2-task-status-management).

This section covers:
- Importance of consistent status updates
- Status transition guidelines (TODO → DOING → DONE)
- Hierarchy status rules (parent tasks, section completion)
- Handling status during interruptions
- Verification procedures
- Responsibility assignment

Always refer to the canonical reference for the most up-to-date and comprehensive guidance on task status management.