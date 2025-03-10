# Detailed Workflow

## Table of Contents
1. [TDD Workflow](#1-tdd-workflow)
2. [Task Analysis](#2-task-analysis)
3. [Response](#3-response)
4. [Clarification](#4-clarification)

For all requests, follow these steps:

## 1. TDD Workflow
The project follows strict Test-Driven Development (TDD) principles:

1. **Identify Task**: Select the next uncompleted task `[ ]` from the task list.
2. **Verify Task Status**: Confirm the current task status in tasks.md accurately reflects the project state before proceeding. See [Task Status Management](02_documents_and_rules.md#8-task-status-management) for verification procedures.
3. **Understand Requirements**: Fully understand what the task needs to accomplish.
4. **Write Test First**: Create a test that verifies the behavior you want to implement. The test should fail initially.
5. **Execute Test**: Run the test to confirm it fails for the expected reason.
6. **Update Status**: After confirming the test fails appropriately, mark the task as in-progress `[-]` in tasks.md. This status update is mandatory before proceeding.
7. **Implement Code**: Write the minimum code needed to make the test pass.
8. **Capture Discovered Tasks**: If you identify new tasks during implementation:
   - Document them immediately following the guidelines in the [Discovered Task Management](02_documents_and_rules.md#7-discovered-task-management) section.
   - Include file listings as non-checkbox bullet points using the format: `  - Files: file1.rb, file2.rb` (with 2-space indentation).
   - Place file listings as high in the hierarchy as possible (at parent task level rather than individual leaf tasks).
   - Determine whether to continue with the current task or address the discovered task based on the interruption criteria.
   - Add the discovered task to tasks.md with appropriate relationship documentation.
   - Update task status according to [Task Status Management](02_documents_and_rules.md#8-task-status-management) guidelines for handling interruptions.
9. **Verify Implementation**: Run the test to confirm it now passes. Also run the full test suite to ensure no regressions.
10. **Complete Task**: After confirming all tests pass, mark the task as completed `[x]` in tasks.md and update any file listings if implementation required changes to different files than initially identified. This status update is mandatory before proceeding to the next task.
11. **Verify Status Update**: Confirm that tasks.md has been properly updated to reflect the completed task before proceeding. This verification step is critical for maintaining project state accuracy.
12. **Refactor if Needed**: Improve the code without changing functionality, ensuring tests still pass.
13. **Move to Next Task**: Select the next uncompleted task and repeat the process.

During any interruption, context switch, or work session boundary:
- Always ensure tasks.md accurately reflects the current project state.
- Document partial progress as comments under relevant tasks if necessary.
- Follow guidelines in [Task Status Management](02_documents_and_rules.md#8-task-status-management) for handling status during interruptions.
- When resuming work, verify task status accuracy before continuing.

The task status in tasks.md must reflect the actual state of the project at all times. Consistent and accurate status updates are essential for project visibility and proper workflow progression.

This workflow ensures that all functionality is verified by tests, that implementation satisfies the requirements defined by those tests, and that newly discovered tasks are properly captured and managed throughout the development process.

## 2. Task Analysis
Begin your analysis inside <task_analysis> tags. In this section:
1. Quote and analyze relevant parts of the user instructions and task description.
2. List out all rules and guidelines, ensuring each is considered.
3. Identify and list ALL files that might be needed for the task or refinement, explaining the relevance of each.
   - Review any existing file listings in the task (formatted as bullet points `- Files: file1.rb, file2.rb`)
   - Consider whether the file listings need updating based on your analysis
4. Request to see the full content of these files before proceeding with any further analysis or action.
5. Once file contents are provided, break down the task into smaller, numbered steps.
6. Explicitly consider each rule and guideline, noting compliance.
7. Analyze potential impacts on other parts of the project.
8. Identify any necessary updates to specification.md.
9. Plan your approach to the task or refinement.
10. Double-check your compliance with all rules before proceeding.

## 3. Response
After your task analysis, provide your response in <response> tags:

For task completion:
1. Provide detailed, clear, and unambiguous instructions for the editor engineer.
2. Include instructions to update the task list, marking the task as either [-] (if writing a test) or [x] (if making the test pass).
3. Include any necessary updates to specification.md.

For task list refinement:
1. Provide the refined task list with any reorganization, clarification, or breakdown of tasks.
2. Ensure only leaf-node tasks have explicit point estimates.

## 4. Clarification
If you need any clarification or have doubts, express them clearly to the user before proceeding.