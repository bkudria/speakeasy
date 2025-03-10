# Key Documents and Rules

## Table of Contents
1. [Important Documents](#1-important-documents)
2. [Task Management Rules](#2-task-management-rules)
3. [Task List Format](#3-task-list-format)
4. [File Visibility Guidelines](#4-file-visibility-guidelines)
5. [Specification Updates](#5-specification-updates)
6. [Task Completion Process](#6-task-completion-process)
7. [Discovered Task Management](#7-discovered-task-management)

## 1. Important Documents:
1. docs/instructions/*.md: Instructions for working with this repository.
2. docs/specification.md: Project specification, describing functionality without implementation details.
3. docs/conventions.md: Conventions, configurations, and notable aspects of the project.
4. docs/tasks.md: Task list in a specific markdown format.

## 2. Task Management Rules:
1. Complete only one task or sub-task at a time.
2. Follow the TDD workflow as detailed in [Workflow: TDD Workflow](04_workflow.md#1-tdd-workflow).
3. Do not include implementation details in specification.md.

## 3. Task List Format:
1. Use the following formats for tracking task status:
   - Incomplete: `- [ ] Task description`
   - In-progress: `- [-] Task description`
   - Completed: `- [x] Task description`
   
   Examples:
   ```
   - [ ] Implement ConfidenceCalculator class
   - [-] Add error handling to TranscriptProcessor
   - [x] Create directory structure for project
   ```

2. Indent sub-tasks with two additional spaces.
3. Include point estimates for leaf tasks only, using the Fibonacci scale (1, 2, 3, 5, 8, 13, 21…).
4. Non-leaf tasks should not have explicit point estimates.
5. File listings for tasks:
   - List required files as non-checkbox bullet points directly under the relevant task
   - Format: `  - Files: file1.rb, file2.rb` (use the bullet symbol • and indent with 2 spaces)
   - Place file listings as high in the hierarchy as possible (parent tasks rather than individual leaf tasks)
   - Update file listings during task refinement or when adding new tasks
   
   Example:
   ```
   - [ ] Create ConfidenceCalculator utility
     - Files: lib/csv_generator.rb, lib/low_confidence_detector.rb
     - [ ] Extract calculate_confidence_metrics method (2)
     - [ ] Extract confidence calculation from process_segment (3)
   ```

## 4. File Visibility Guidelines:
1. Always request to see the content of files mentioned in tasks before beginning work.
2. Explain relevance when requesting additional file contents.
3. Never propose changes to files whose content you have not seen.
4. Follow the DRY principle when listing files in tasks.

## 5. Specification Updates:
1. Evaluate the need for specification.md updates for each task changing user-visible functionality.
2. Seek user guidance when unsure about potential updates.
3. Focus on describing what the system does, not how it does it.

## 6. Task Completion Process:
1. Request necessary file contents and explain why.
2. Identify the next uncompleted task or sub-task.
3. Review related tasks and specifications.
4. Analyze requirements and current code.
5. Consider impact and side effects of changes.
6. Determine necessary changes at a tactical level.
7. Scope changes using the provided Fibonacci scale.
8. Break down tasks exceeding 10 points into smaller subtasks.
9. Use standard library tools and language idioms when possible.
10. Ensure changes adhere to all rules, especially regarding tests and specifications.
11. Only mark a task as complete [x] after receiving explicit confirmation that tests have passed
12. Only mark a task as in progress [-] after receiving confirmation that the test fails appropriately

## 7. Discovered Task Management:
1. When discovering new tasks during implementation:
   - Document them immediately in tasks.md to prevent forgetting.
   - Use the standard task format with appropriate status indicators.
   - Include point estimates for leaf tasks following the Fibonacci scale.

2. Placement in hierarchy:
   - Add as sub-tasks to the current task if closely related to current work.
   - Add as sibling tasks if related to the same parent but independent of current work.
   - Create a new section if the task belongs to a different functional area.

3. Prioritization guidelines:
   - Critical path tasks (blocking other work) should be prioritized highest.
   - Bug fixes that impact existing functionality should be prioritized over new features.
   - Tasks with dependencies on the current implementation should be completed before unrelated tasks.
   - Consider point estimates when prioritizing similarly important tasks.

4. Work interruption criteria:
   - Continue with the current task unless the discovered task:
     - Reveals a critical bug in the code being modified
     - Indicates a fundamental flaw in the current approach
     - Is a prerequisite for completing the current task
   - Otherwise, complete the current task before addressing discovered tasks.

5. Documentation of relationships:
   - When a task is discovered during another task, note the relationship:
     - Add a comment in the format: `(Discovered during Task X.Y.Z)`
     - If the discovered task is a blocker, note: `(Blocks Task X.Y.Z)`
     - If the discovered task is blocked by another task, note: `(Blocked by Task X.Y.Z)`

6. Categorization process:
   - Technical debt: Refactoring, optimization, or cleanup tasks
   - Bug fixes: Corrections to existing functionality
   - Feature enhancements: Improvements to existing features
   - New features: Entirely new functionality
   - Documentation: Updates to documentation or comments
