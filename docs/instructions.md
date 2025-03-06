Please study this information carefully before proceeding with any user requests. These are extremely important instructions. You MUST
follow them, unless the user explicitly tells you otherwise. If you have any doubts or questions, immediately inform the user instead of
proceeding.

# Key Documents:
- docs/instructions.md: this file. Instructions for how to work with this repository.
- docs/specification.md: Contains the project specification. It must be kept up-to-date and describe this project's functionality without
  implementation details.
- docs/conventions.md: any conventions, configurations, idiosyncrasies, or other notable things about this project or repository.
- docs/tasks.md: Contains the task list in a specific markdown format. Tasks must be completed in order, one at a time.

# Important Rules:
1. If you need to ask to add a file to the session, always provide an explanation of your motivation.
2. Do not proceed with any task until explicitly instructed to do so by the user.
3. Complete only one task OR one sub-task at a time.
4. All tasks must begin with a failing test. That is, before making any implementation changes, add or modify a test to reflect the new
   functionality or fix. Confirm the test fails for the correct reason. Then proceed to implement and make the test pass. No changes should
   be made without either a new corresponding test, or an update to an existing test.
   1. Only update tests for program functionality mentioned as a task in the tasks. Documentation or task refinement tasks don't require
      test updates.
5. A task is not complete until it is first demonstrated to fail with a new or modified test, and then that test is made to pass via
   implementation changes. The entire test suite must pass to ensure no regressions.
6. Follow each task in order, ensuring each one starts with a failing test scenario. If re-ordering is needed, consult the user. Each task
   must be verified through TDD before moving on.
7. Do not include implementation details in specification.md.

# Task List Management:
- Tasks are listed with "-" bullets in the tasklist.
  - Use "[ ]" for incomplete tasks, "[-]" for partially completed tasks (failing test written but implementation not complete), and "[x]"
    for completed tasks.
  - Indent sub-tasks with two additional spaces.
- Tasks and sub-tasks must be actionable and verifiable.
- Subtasks or children tasks are tasks that must be completed to help accomplish the parent task.
- Some leaf tasks have a point value listed after the checkbox in parentheses -- they represent relative levels of effort
- Every leaf task needs an explicit point estimate in parentheses after the checkbox, using the Fibonacci scale (1, 2, 3, 5, 8, 13, 21...)
  required to complete the task.
- Tasks with sub-tasks should have no explicit point value - their point value is implied, as the sum of their child tasks' efforts.
- Every leaf task needs an explicit point estimate in parentheses after the checkbox. Non-leaf tasks' estimates are implicitly the sum of
  their children's estimates.
- Some tasks have notes -- bullets without checkboxes. These are important -- pay attention to them.
- Some notes indicate which files should be edited. If the user has not already added those files, stop and ask for them to be added - so
  you have the correct context for any changes. NEVER propose changes to files whose contents you have not seen.
- There is no need for a sub-task to repeat the files already noted in it's parent task.
- Always share with the user any clarifications needed if you have any doubts about a task.

# File Visibility Guidelines:
1. Always proactively ask to see all files noted for a task before beginning work. This includes files mentioned in the task itself, its
   parent task, grandparent task, and so on up the hierarchy.
2. If you need to see additional files not explicitly mentioned in any level of the task hierarchy, explain their relevance to the task
   before requesting
3. Never propose changes to files whose contents you have not seen.
4. When listing files in tasks, follow the DRY principle (Don't Repeat Yourself):
   - If ALL subtasks of a task need to access the SAME files, list those files ONLY in the parent task.
   - NEVER list the same files in both a parent task and its subtasks.
   - ONLY list files in a subtask if that subtask needs files DIFFERENT from or ADDITIONAL to those listed in its parent.
   - Example:
     ```
     - [ ] Parent task
       - Files: file1.rb, file2.rb  # All subtasks need these files
       - [ ] Subtask A  # Uses only the files listed in parent
       - [ ] Subtask B  # Uses only the files listed in parent
       - [ ] Subtask C  # Needs an additional file
         - Files: file3.rb  # Only list the additional file here
     ```

# Specification Updates:
1. For every task that changes user-visible functionality, evaluate whether specification.md needs to be updated.
2. If unsure about a potential specification update, instead of making changes directly, inform the user what you considered adding or
   changing and seek guidance.
3. Remember that specification.md should describe what the system does, not how it does it.

# Completing a task
When instructed to "go" or complete the next task, work through the following steps carefully, thinking thoroughly about each one:

 0. Ask to see any files needed, and explain why
 1. Identify the next uncompleted task or sub-task in the task list.
 2. Review any relevant previous tasks or specifications related to the current task.
 3. Analyze the task requirements and current code.
 4. Consider the impact on existing code and potential side effects of the proposed changes.
 5. Determine what changes will be needed, at a tactical level -- which components, methods, function etc will need to be adapted. Be
    fine-grained.
 6. Scope the necessary changes if needed:
    1. Estimate the size -- the level of effort  -- of each change, according to this Fibonacci scale:
       - 1 point: A straight-forward edit of 1 or 2 lines adjacent lines
       - 2 points: A bigger change, requiring some nuance, decision-making, or judgment calls
       - 3 points: An even larger change, requiring 1-point edits to more than one component (method, class, or file)
       - 5 points: A change requiring 2-point edits to one or more components, or edits to more than two components
       - 8 points: A change requiring edits to 3 or more components, or multiple 3-point edits
       - 13 points: A change requiring edits to 4 or more components, or multiple edits summing to 5 points or more
       - 21 points: A change requiring edits to 5 or more components, or multiple edits summing to 8 points or more
       - … and so on
    2. If a task seems to fall between two Fibonacci numbers, always round up to the next number.
 7. If the sum of points for necessary changes exceeds 10, instead of making the changes, add tasks and subtasks to the tasklist. 
    1. Make sure to include point estimates as a single number in parentheses after the checkbox and a space.
    2. Make sure to add a note indicating which files need to be added to the session in order the make the change.
    3. NEVER make changes whose sum point total exceeds 10 points.
 8. Point Limit: Actively monitor the total point value of changes. If the sum exceeds 10 points, do not implement the changes directly.
    Instead, break down the task into smaller subtasks in the tasklist with appropriate point estimates.
 9. Make sure to use standard library tools and language idioms and best practices:
    1. First, consider if standard library methods or idioms can solve the problem elegantly.
    2. Prefer built-in language features and standard library methods over custom implementations.
    3. Only create custom implementations when standard solutions are insufficient.
    4. When implementing, follow the principle of "Don't Reinvent the Wheel"
10. Ensure the planned changes adhere to all rules, especially regarding the task list, tests, and specification updates.
11. If a step is not relevant to the current task, note this but still consider whether it might apply in a non-obvious way.
12. Prepare detailed, clear, and unambiguous instructions for the editor engineer.

[Provide detailed instructions for code changes here]

[If necessary, provide updates for specification.md here]

[Provide updates for the task list, marking the completed task or sub-task, unless you are writing tests intended to fail.]

# Refinement
If asked to "refine" the task list:
0. Ask to see any files needed, and explain why
1. Read all tasks to understand the plan.
2. Re-order tasks if necessary for efficiency.
3. Review each task:
   1. Ensure clear and unambiguous descriptions.
   2. Split into multiple tasks if needed. Tasks of 8 or more points need to be broken down into smaller sub-tasks.
   3. Break down non-trivial tasks into well-specified sub-tasks. Make sure to estimate point values according to the scale above
   4. Identify and note which specific files need to be edited to accomplish the task, unless they are already noted by an ancestor. Never
      add notes that are not specific files.
   5. If all subtasks of a task need to see a file, note it in the parent, not in the subtasks. Do this recursively
   6. Ensure the task complies with all other rules specified
4. Remove fully completed top-level tasks if there are 10 or more completed tasks or sub-tasks in the entire the tasklist
5. Never add new tasks that weren't in the original list, or aren't needed for the parent task. The refinement process is strictly about
   reorganizing, clarifying, and breaking down existing tasks while maintaining the same overall structure.
6. When in doubt, preserve the original intent. If something seems missing, note it separately as a question rather than making assumptions
   and adding tasks.


