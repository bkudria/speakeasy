# Process for Handling Requests

## Table of Contents
1. [Determining Request Type](#1-determining-request-type)
2. [Task Refinement Process](#2-task-refinement-process)
3. [Task Advancement Process](#3-task-advancement-process)
4. [Discovered Task Handling Process](#4-discovered-task-handling-process)

## 1. Determining Request Type
Determine if the request is for task refinement, task advancement, or something else

## 2. Task Refinement Process
1. Request any unseen file content mentioned in the tasks.
2. Once all file content needed is available, refine the task list according to the instructions.
3. Add or update file listings as non-checkbox bullet points under relevant tasks following the format in docs/instructions/02_documents_and_rules.md:
   - Format: `  - Files: file1.rb, file2.rb` (with 2-space indentation)
   - Place file listings as high in the hierarchy as possible
4. Instruct the editor engineer to update the tasks.md file with the refined task list.
5. Await a new request.
6. If new tasks are discovered during this process, follow the [Discovered Task Handling Process](#4-discovered-task-handling-process).

## 3. Task Advancement Process
1. Request any unseen file content mentioned in the tasks.
2. If all file content needed is available, identify the next task to be completed.
3. Inform the user of the next task.
4. Mark the task as in-progress ([-]) as soon as it becomes the current focus:
   - Explicitly instruct the editor engineer to update the task status to [-] in tasks.md
   - Verify the status has been updated correctly before proceeding
   - Note: Tasks being actively researched or planned should be marked as in-progress
   - Note: Tasks being refined or broken down should not be changed to in-progress (unless already marked as such)
5. If the task is already marked as [-] (from research/planning), proceed to the next applicable step.
6. For implementation tasks, instruct to write a test:
   - If the task is already [-], continue writing the test
   - Reference the [Task Status Management](02_documents_and_rules.md#8-task-status-management) guidelines for status tracking importance
7. After confirmation that the test fails appropriately:
   - Verify the task remains marked as [-] in tasks.md
   - Document any partial progress or notes as comments under the task if applicable
8. Instruct to write code to make the test pass, but don't update the task status yet:
   - Confirm the task remains marked as [-] in tasks.md throughout implementation
   - Note any discovered tasks according to the [Discovered Task Management](02_documents_and_rules.md#7-discovered-task-management) process
9. Wait for user confirmation that tests have passed, then:
   - Explicitly instruct the editor engineer to update the task status to [x] in tasks.md
   - Verify the task has been properly marked as completed before considering the task finished
   - If this completes a parent task (i.e., all child tasks are now complete), explicitly instruct the editor engineer to update the parent task status to [x] in tasks.md
   - Verify the parent task has been properly marked as completed before proceeding
10. Update any file listing bullets if implementation adds or changes files related to the task:
    - Ensure consistent status tracking across all related documentation
    - Periodically review tasks.md to verify all statuses accurately reflect the current project state
11. If new tasks are discovered during implementation, follow the [Discovered Task Handling Process](#4-discovered-task-handling-process).

## 4. Discovered Task Handling Process
1. When a new task is discovered during development or testing:
   - Document the task immediately in the task list following the format in the "Discovered Task Management" section in docs/instructions/02_documents_and_rules.md.
   - Include all required information: description, point estimate (if a leaf task), and related files.
   - List required files as non-checkbox bullet points using the format: `  - Files: file1.rb, file2.rb` (with 2-space indentation)

2. Determine appropriate placement in the task hierarchy:
   - If the discovered task is directly related to the current task, add it as a sub-task.
   - If it's related to a different existing task, add it under that task.
   - If it represents a new area of work, create a new top-level section.

3. Prioritize the discovered task:
   - Assess its urgency relative to existing tasks.
   - Consider dependencies between tasks (does anything depend on this task?).
   - Evaluate its complexity and estimated time to complete.

4. Decide whether to interrupt current work:
   - If the discovered task is blocking the current task, interrupt and complete it first.
   - If it's a critical bug or security issue, address it immediately.
   - Otherwise, complete the current task before addressing the discovered task.

5. Document relationships between tasks:
   - Note any dependencies in the task description.
   - If the discovered task is a prerequisite for another task, indicate this in both task descriptions.
   - Update point estimates of affected tasks if the discovered task changes their complexity.

6. Instruct the editor engineer to update the tasks.md file with the new task(s).
7. Return to the original process (refinement or advancement) that was interrupted.