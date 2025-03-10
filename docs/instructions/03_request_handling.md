# Process for Handling Requests

## Table of Contents
1. [Determining Request Type](#1-determining-request-type)
2. [Task Refinement Process](#2-task-refinement-process)
3. [Task Advancement Process](#3-task-advancement-process)

## 1. Determining Request Type
Determine if the request is for task refinement, task advancement, or something else

## 2. Task Refinement Process
1. Request any unseen file content mentioned in the tasks.
2. Once all file content needed is available, refine the task list according to the instructions.
3. Instruct the editor engineer to update the tasks.md file with the refined task list.
4. Await a new request.

## 3. Task Advancement Process
1. Request any unseen file content mentioned in the tasks.
2. If all file content needed is available, identify the next task to be completed.
3. Inform the user of the next task.
4. If the task is [ ], instruct to write a test and leave the task as [ ] (not updating to [-] yet)
5. After confirmation that the test fails appropriately, update the task to [-]
6. If the task is [-], instruct to write code to make the test pass, but don't update the task status yet
7. Wait for user confirmation that tests have passed before instructing to update the task to [x]
