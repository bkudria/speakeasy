# Key Documents and Rules

## Table of Contents
1. [Important Documents](#1-important-documents)
2. [Task Management Rules](#2-task-management-rules)
3. [Task List Format](#3-task-list-format)
4. [File Visibility Guidelines](#4-file-visibility-guidelines)
5. [Specification Updates](#5-specification-updates)
6. [Task Completion Process](#6-task-completion-process)
7. [Discovered Task Management](#7-discovered-task-management)
8. [Task Status Management](#8-task-status-management)

## 1. Important Documents:
1. docs/instructions/*.md: Instructions for working with this repository.
2. docs/specification.md: Project specification, describing functionality without implementation details.
3. docs/conventions.md: Conventions, configurations, and notable aspects of the project.
4. docs/tasks.org: Task list in org-mode format.

## 2. Task Management Rules:
1. Complete only one task or sub-task at a time.
2. Follow the TDD workflow as detailed in [Workflow: TDD Workflow](04_workflow.md#1-tdd-workflow).
3. Do not include implementation details in specification.md.

## 3. Task List Format:
1. Tasks are tracked in org-mode format with TODO states:
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

2. Use org-mode hierarchy with * for main sections, ** for top-level tasks, *** for subtasks, etc.
3. Include point estimates for leaf tasks only, using the Fibonacci scale (1, 2, 3, 5, 8, 13, 21…) in the PROPERTIES drawer.
4. Non-leaf tasks can have POINTS properties calculated from their children.
5. Use PROPERTIES drawers for all metadata:
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
8. Break down tasks exceeding 5 points into smaller subtasks.
9. After selecting a task and making a plan for it, re-evaluate its point-score effort number. If the re-evaluated score exceeds 5 points, break down the task into smaller subtasks.
10. Use standard library tools and language idioms when possible.
11. Ensure changes adhere to all rules, especially regarding tests and specifications.
12. Only mark a task as complete [x] after receiving explicit confirmation that tests have passed
13. Only mark a task as in progress [-] after receiving confirmation that the test fails appropriately

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

## 8. Task Status Management:
1. Importance of consistent status updates:
   - Accurate status tracking is essential for project visibility and coordination.
   - Task status in tasks.md must reflect the actual state of the project at all times.
   - Consistent status updates prevent miscommunication and ensure proper workflow progression.
   - Status changes should be made at specific points in the TDD workflow, not arbitrarily.
   - Tasks should be marked as in-progress ([-]) as soon as they become the current focus, including during research or planning stages.
   - Tasks being actively researched or planned should be marked as in-progress.
   - Tasks being refined or broken down should not be changed to in-progress (unless already marked as such).
   - Regular verification of status accuracy is required throughout the workflow.

2. Responsibility assignments:
   - The editor engineer is responsible for physically updating the tasks.md file.
   - The AI assistant must explicitly instruct the engineer to update task status at appropriate times.
   - The AI assistant must verify status updates have been made before continuing to the next step.
   - Both parties should confirm status accuracy during context switching or after interruptions.

3. Handling status during interruptions or context switches:
   - Before switching context, document the current task state in tasks.md with accurate status.
   - Record any partial progress as comments under the task if necessary.
   - When resuming work, verify the task status accurately reflects the current state.
   - If a task is blocked by external factors, add a comment indicating the blocker: `(Blocked by: description)`.
   - For tasks requiring pause due to discovered blockers, maintain [-] status with explanation.

4. Verification procedures:
   - Before starting any task, verify its current status in tasks.md.
   - After writing a failing test, verify the task has been updated to [-].
   - After confirming tests pass, verify the task has been updated to [x].
   - Periodically review tasks.md to ensure all statuses are accurate, especially after:
     - Test runs or implementation changes
     - Task discoveries or refinements
     - Context switches or work sessions
   - When completing a non-leaf task, verify all child tasks are properly marked as completed.

5. Parent task completion rule:
   - A parent task should be marked as complete [x] if and only if all of its children tasks are complete.
   - When marking the last child task of a parent as complete, always verify and update the parent task's status.
   - Never mark a parent task as complete if any of its children are still in progress [-] or incomplete [ ].
   - When all children tasks are complete, the parent task must be updated to reflect this state.
