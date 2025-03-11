# Detailed Workflow

## Table of Contents
1. [TDD Workflow](#1-tdd-workflow)
2. [Task Status Management](#2-task-status-management)
3. [Task Analysis](#3-task-analysis)
4. [Response](#4-response)
5. [Clarification](#5-clarification)

For all requests, follow these steps:

## 1. TDD Workflow
The project follows strict Test-Driven Development (TDD) principles. This is the canonical reference for the TDD workflow across all documentation.

### Documentation Requirements
- At the start of each session, read all documentation files to ensure complete understanding
- Before starting any task, always read all files listed in the task's :FILES: property
- Before performing task refinement, read all docs/instructions/*.md files
- Before answering any questions about the project, scan relevant documentation first

### Scope of TDD Application
- Tests need only be written to test program functionality implemented in lib/
- Refactors, test suite improvements, and other changes unrelated to the core functionality do not need to be implemented in strict accordance with TDD
- However, changes to core application functionality must always follow the TDD workflow described below

### Task Order and Selection
- Tasks must be completed in sequential order - never skip tasks
- Complete all tasks in one section before moving to the next section
  - Sections are defined by top-level headings (single * prefix) in tasks.org
  - Examples of sections include "Process Improvements", "Refactoring", etc.
  - This rule prevents context switching between unrelated areas of the project
- Within a section, follow the hierarchical order of tasks
- Section completion is verified by ensuring all tasks and subtasks are marked as `DONE`
- The next task is always the first incomplete task (TODO state) in the list
- Parent tasks are marked as `DONE` only when all child tasks are complete

### Complete TDD Workflow Steps

1. **Task Identification**: Select the next uncompleted task (marked as `TODO`) from the task list in sequential order. The next task is always the first incomplete task in the list - never skip ahead in the task list.

2. **Documentation Review**: Read all files listed in the task's :FILES: property, and review all other documentation mentioned in the task description.

3. **Clarification**: When a new task becomes active, proactively ask the user any questions to clarify the task requirements or scope.

4. **Task Status Verification**: Confirm the current task status in tasks.org accurately reflects the project state before proceeding.

5. **Mark Task In-Progress**: As soon as the task becomes the current focus, mark it as in-progress (`DOING`) in tasks.org. This status update is mandatory before proceeding with further research or planning.
   - Tasks being actively researched or planned should be marked as `DOING`
   - Tasks being refined or broken down should not be changed to `DOING` (unless already marked as such)

6. **Requirement Analysis**: Fully understand what the task needs to accomplish. Ask the user any questions about the task if there is any ambiguity or if additional information is needed. Ensure all required information is gathered up front before beginning implementation.

7. **Test Creation**: Create a test that verifies the behavior you want to implement. The test should fail initially.

8. **Test Verification**: Run the test to confirm it fails for the expected reason. Verify the task remains marked as in-progress (`DOING`) in tasks.org.

9. **Implementation**: Write the minimum code needed to make the test pass.

10. **Discovered Task Management**: If you identify new tasks during implementation:
   - Follow the complete guidelines in the canonical [Discovered Task Management](02_documents_and_rules.md#6-discovered-task-management) reference
   - Document tasks immediately with all required information
   - Place file listings as high in the hierarchy as possible
   - Use appropriate categorization and relationship documentation
   - Determine whether to continue with the current task or address the discovered task based on the interruption criteria

11. **Implementation Verification**: Run the test to confirm it now passes. Also run the full test suite to ensure no regressions.

12. **Task Completion**: After confirming all tests pass, mark the task as completed (`DONE`) in tasks.org. This status update is mandatory before proceeding to the next task.

13. **Status Verification**: Confirm that tasks.org has been properly updated to reflect the completed task before proceeding. This verification step is critical for maintaining project state accuracy.

14. **Refactoring**: Improve the code without changing functionality, ensuring tests still pass.

15. **Task Transition**: Select the next uncompleted task and repeat the process.

16. **User Notification**: After completing a task, always proactively report the next task to the user, so they are aware of what will be worked on next.

### Interruption Handling

During any interruption, context switch, or work session boundary:
- Always ensure tasks.org accurately reflects the current project state
- Document partial progress as comments under relevant tasks if necessary
- When resuming work, verify task status accuracy before continuing

### Task Status Importance

The task status in tasks.org must reflect the actual state of the project at all times. Consistent and accurate status updates are essential for project visibility and proper workflow progression.

This workflow ensures that all functionality is verified by tests, that implementation satisfies the requirements defined by those tests, and that newly discovered tasks are properly captured and managed throughout the development process.

## 2. Task Status Management

This is the canonical reference for task status management across all documentation.

### Importance of Consistent Status Updates

- Task status in tasks.org must reflect the actual state of the project at all times
- Accurate status tracking is essential for project visibility and coordination
- Consistent status updates prevent miscommunication and ensure proper workflow progression
- Status changes should be made at specific points in the TDD workflow, not arbitrarily
- Regular verification of status accuracy is required throughout the workflow

### Status Transition Guidelines

- **TODO → DOING**: Mark a task as `DOING` as soon as it becomes the current focus:
  - This includes during research or planning stages
  - The status update is mandatory before proceeding with any work
  - Explicitly instruct to update the task status in tasks.org
  - Verify the status has been updated correctly before proceeding

- **DOING → DONE**: Mark a task as `DONE` only after specific conditions are met:
  - For implementation tasks: only after all tests pass
  - Explicitly instruct to update the task status in tasks.org
  - Verify the task has been properly marked as completed before proceeding
  
- **Status during refinement**: Tasks being refined or broken down should not be changed to `DOING` (unless already marked as such)

### Hierarchy Status Rules

- **Parent task completion**: A parent task should be marked as `DONE` if and only if all of its children tasks are complete
  - Never mark a parent task as complete if any of its children are still in progress (`DOING`) or incomplete (`TODO`)
  - When marking the last child task of a parent as complete, always verify and update the parent task's status
  - When all children tasks are complete, the parent task must be updated to reflect this state

- **Section completion**: All tasks in a section must be completed before starting tasks in a new section
  - Sections are denoted by top-level headings in tasks.org (single * prefix)
  - Complete all tasks and subtasks within a section are marked as `DONE` before beginning work on the first task of the next section
  - This rule ensures focused development and prevents context switching between unrelated areas

### Handling Status During Interruptions

- Before switching context, document the current task state in tasks.org with accurate status
- Record any partial progress as comments under the task if necessary
- When resuming work, verify the task status accurately reflects the current state
- If a task is blocked by external factors, add a comment indicating the blocker: `(Blocked by: description)`
- For tasks requiring pause due to discovered blockers, maintain `DOING` status with explanation

### Verification Procedures

- Before starting any task, verify its current status in tasks.org
- After writing a failing test, verify the task has been updated to `DOING`
- After confirming tests pass, verify the task has been updated to `DONE`
- When completing a non-leaf task, verify all child tasks are properly marked as completed
- Periodically review tasks.org to ensure all statuses are accurate, especially after:
  - Test runs or implementation changes
  - Task discoveries or refinements
  - Context switches or work sessions

### Responsibility Assignment

- The AI assistant must explicitly instruct the user to update task status at appropriate times
- The AI assistant must verify status updates have been made before continuing to the next step
- Both parties should confirm status accuracy during context switching or after interruptions

## 3. Task Analysis
Begin your analysis inside <task_analysis> tags. In this section:
1. Quote and analyze relevant parts of the user instructions and task description.
2. List out all rules and guidelines, ensuring each is considered.
3. Identify and list ALL files that might be needed for the task or refinement, explaining the relevance of each.
   - Review any existing file listings in the task's PROPERTIES drawer (formatted as `:FILES: file1.rb, file2.rb`)
   - Consider whether the file listings need updating based on your analysis
4. Break down the task into smaller, numbered steps.
5. Explicitly consider each rule and guideline, noting compliance.
6. Analyze potential impacts on other parts of the project.
7. Identify any necessary updates to specification.md.
8. Plan your approach to the task or refinement.
9. Double-check your compliance with all rules before proceeding.

## 4. Response
After your task analysis, provide your response in <response> tags:

For task completion:
1. Provide detailed, clear, and unambiguous instructions for the editor engineer.
2. Include instructions to update the task list, marking the task as either [-] (if writing a test) or [x] (if making the test pass).
3. Include any necessary updates to specification.md.

For task list refinement:
1. Provide the refined task list with any reorganization, clarification, or breakdown of tasks.
2. Ensure only leaf-node tasks have explicit point estimates.

## 5. Clarification
If you need any clarification or have doubts, express them clearly to the user before proceeding.