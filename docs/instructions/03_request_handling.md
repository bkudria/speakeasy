# Process for Handling Requests

## Table of Contents
1. [Determining Request Type](#1-determining-request-type)
2. [Task Refinement Process](#2-task-refinement-process)
3. [Task Advancement Process](#3-task-advancement-process)
4. [Discovered Task Handling Process](#4-discovered-task-handling-process)

## 1. Determining Request Type
Determine if the request is for task refinement, task advancement, or something else

## 2. Task Refinement Process
1. Analyze the current task list and the user's request to understand what refinement is needed.
2. Identify tasks that need refinement, clarification, breakdown, or reorganization.
3. Add or update file listings in PROPERTIES drawers under relevant tasks following the format in docs/instructions/02_documents_and_rules.md:
   - Format: `:PROPERTIES:\n:FILES: file1.rb, file2.rb\n:END:`
   - Place file listings as high in the hierarchy as possible
4. Update the tasks.org file with the refined task list.
5. Await a new request.
6. If new tasks are discovered during this process, follow the [Discovered Task Handling Process](#4-discovered-task-handling-process).

## 3. Task Advancement Process
1. Identify the next task to be completed.
2. Inform the user of the next task.
3. Mark the task as `DOING` as soon as it becomes the current focus:
   - Explicitly instruct the editor engineer to update the task status to `DOING` in tasks.org
   - Verify the status has been updated correctly before proceeding
   - Note: Tasks being actively researched or planned should be marked as `DOING`
   - Note: Tasks being refined or broken down should not be changed to `DOING` (unless already marked as such)
4. If the task is already marked as `DOING` (from research/planning), proceed to the next applicable step.
5. For implementation tasks, write a test:
   - If the task is already `DOING`, continue writing the test
   - Reference the [Task Status Management](02_documents_and_rules.md#8-task-status-management) guidelines for status tracking importance
6. After confirmation that the test fails appropriately:
   - Verify the task remains marked as `DOING` in tasks.org
   - Document any partial progress or notes as comments under the task if applicable
7. Write code to make the test pass, but don't update the task status yet:
   - Confirm the task remains marked as `DOING` in tasks.org throughout implementation
   - Note any discovered tasks according to the [Discovered Task Management](02_documents_and_rules.md#7-discovered-task-management) process
8. When tests have passed, then:
   - Explicitly instruct the editor engineer to update the task status to `DONE` in tasks.org
   - Verify the task has been properly marked as completed before considering the task finished
   - If this completes a parent task (i.e., all child tasks are now complete), explicitly instruct the editor engineer to update the parent task status to `DONE` in tasks.org
   - Verify the parent task has been properly marked as completed before proceeding
9. Update any file listings in PROPERTIES drawers if implementation adds or changes files related to the task:
   - Ensure consistent status tracking across all related documentation
   - Periodically review tasks.org to verify all statuses accurately reflect the current project state
10. If new tasks are discovered during implementation, follow the [Discovered Task Handling Process](#4-discovered-task-handling-process).

## 4. Discovered Task Handling Process
1. When a new task is discovered during development or testing:
   - Document the task immediately in the task list following the format in the "Discovered Task Management" section in docs/instructions/02_documents_and_rules.md.
   - Include all required information: description, point estimate (if a leaf task), and related files.
   - Add file listings in PROPERTIES drawers using the format: `:PROPERTIES:\n:FILES: file1.rb, file2.rb\n:END:`

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

6. Update the tasks.org file with the new task(s).
7. Return to the original process (refinement or advancement) that was interrupted.
