# Process for Handling Requests

## Table of Contents
1. [Determining Request Type](#1-determining-request-type)
2. [Task Refinement Process](#2-task-refinement-process)
3. [Task Advancement Process](#3-task-advancement-process)
4. [Discovered Task Handling Process](#4-discovered-task-handling-process)

## 1. Determining Request Type
Determine if the request is for task refinement, task advancement, or something else

## 2. Task Refinement Process
1. Before beginning any task refinement, read ALL docs/instructions/*.md files to ensure full understanding of the process and requirements.
2. Analyze the current task list and the user's request to understand what refinement is needed.
3. Identify tasks that need refinement, clarification, breakdown, or reorganization.
4. Add or update file listings in PROPERTIES drawers under relevant tasks following the format in docs/instructions/02_documents_and_rules.md:
   - Format: `:PROPERTIES:\n:FILES: file1.rb, file2.rb\n:END:`
   - Place file listings as high in the hierarchy as possible
5. Update the tasks.org file with the refined task list.
6. Await a new request.
7. If new tasks are discovered during this process, follow the [Discovered Task Handling Process](#4-discovered-task-handling-process).

## 3. Task Advancement Process

Follow the canonical TDD workflow defined in [04_workflow.md](04_workflow.md#1-tdd-workflow) for the complete step-by-step process. This section contains only additional considerations specific to request handling.

### Pre-Task Activities
1. At the start of each session, read all documentation files to ensure complete understanding of the project
2. Identify the next task to be completed using the task selection rules
3. Read all files listed in the task's :FILES: property before starting work
4. Inform the user of the next task

### Information Gathering
- Before starting work on the task, ensure you have all the information needed to complete it properly
- Proactively ask the user any clarifying questions about requirements, scope, or implementation details
- Address any ambiguities in the task description
- Confirm your understanding of the expected outcomes
- Document gathered information as reference for implementation

### Status Management
- For comprehensive status management guidelines, refer to the canonical reference: [04_workflow.md#2-task-status-management](04_workflow.md#2-task-status-management)
- Mark the task as `DOING` as soon as it becomes the current focus
- Explicitly instruct the editor engineer to update the task status in tasks.org
- Verify the status has been updated correctly before proceeding

### Implementation
- Follow the canonical TDD process (test first, implementation, verification)
- Update any file listings in PROPERTIES drawers if implementation adds or changes files

### Post-Task Activities
- For all status management guidelines, refer to the canonical reference: [04_workflow.md#2-task-status-management](04_workflow.md#2-task-status-management)
- When tests have passed, mark the task as `DONE` in tasks.org
- Update parent task status according to the hierarchy status rules
- Report the next task to the user after completing the current one

## 4. Discovered Task Handling Process

For the canonical reference on discovered task management, see [02_documents_and_rules.md#6-discovered-task-management](02_documents_and_rules.md#6-discovered-task-management).

### Process Components
1. **Documentation Requirements**: Immediate task documentation with all necessary information
2. **Hierarchy Placement**: Determining where to add discovered tasks in the task list
3. **Prioritization Guidelines**: Assessing importance relative to existing tasks
4. **Work Interruption Criteria**: Deciding whether to interrupt current work
5. **Relationship Documentation**: Noting dependencies between tasks
6. **Categorization Process**: Classifying tasks by type (technical debt, bug fix, etc.)

### Request Handling Integration
When a discovered task impacts request handling, ensure you appropriately update tasks.org and return to the original process (refinement or advancement) that was interrupted.