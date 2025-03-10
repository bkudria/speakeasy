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
2. **Understand Requirements**: Fully understand what the task needs to accomplish.
3. **Write Test First**: Create a test that verifies the behavior you want to implement. The test should fail initially.
4. **Execute Test**: Run the test to confirm it fails for the expected reason.
5. **Update Status**: After confirming the test fails appropriately, mark the task as in-progress `[-]`.
6. **Implement Code**: Write the minimum code needed to make the test pass.
7. **Verify Implementation**: Run the test to confirm it now passes. Also run the full test suite to ensure no regressions.
8. **Complete Task**: After confirming all tests pass, mark the task as completed `[x]`.
9. **Refactor if Needed**: Improve the code without changing functionality, ensuring tests still pass.
10. **Move to Next Task**: Select the next uncompleted task and repeat the process.

This workflow ensures that all functionality is verified by tests and that implementation satisfies the requirements defined by those tests.

## 2. Task Analysis
Begin your analysis inside <task_analysis> tags. In this section:
1. Quote and analyze relevant parts of the user instructions and task description.
2. List out all rules and guidelines, ensuring each is considered.
3. Identify and list ALL files that might be needed for the task or refinement, explaining the relevance of each.
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