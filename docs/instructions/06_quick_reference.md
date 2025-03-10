# Quick Reference Cheatsheet

## Table of Contents
1. [Key Project Documents](#key-project-documents)
2. [Task Management](#task-management)
3. [TDD Workflow](#tdd-workflow)
4. [File Handling Guidelines](#file-handling-guidelines)
5. [Output Formatting](#output-formatting)

## Key Project Documents

| Document      | Purpose                 | Location               |
|---------------|-------------------------|------------------------|
| Instructions  | Working with repository | docs/instructions/*.md |
| Specification | Project functionality   | docs/specification.md  |
| Conventions   | Project standards       | docs/conventions.md    |
| Tasks         | Task tracking           | docs/tasks.md          |

## Task Management

### Task Status Notation
```
- [ ] Incomplete task
- [-] In-progress task 
- [x] Completed task
```

### Task Structure
- Hierarchical organization with 2-space indentation for sub-tasks
- Point estimates (Fibonacci: 1,2,3,5,8,13,21) for leaf tasks only
- Include file references at highest applicable level

### Example Task Structure
```
- [ ] Main task
  - [ ] Sub-task with files needed (2)
    - [ ] Leaf task (1)
    - [ ] Another leaf task (1)
  - [ ] Another sub-task (3)
```

## TDD Workflow

1. **Start**: Identify next uncompleted task `[ ]`
2. **Write Test**: Create failing test but don't update task status yet
3. **Verify Failure**: Confirm test fails appropriately, then mark task as in-progress `[-]`
4. **Implement**: Write minimum code to make test pass but don't update task status
5. **Verify Success**: Confirm test passes and all tests still pass
6. **Complete**: Mark task as completed `[x]` only after test passes

## File Handling Guidelines

- Always request file content before proposing changes
- Explain relevance when requesting additional files
- Never propose changes to unseen files
- DRY principle: List files at highest hierarchy level possible

## Output Formatting

### Task Analysis Format
```
<task_analysis>
- Analysis of requirements and rules
- List of needed files with explanations
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
