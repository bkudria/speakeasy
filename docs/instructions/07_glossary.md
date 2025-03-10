# Glossary of Terms

## Table of Contents
1. [Project-Specific Terms](#project-specific-terms)
2. [Task Management Terms](#task-management-terms)
3. [Development Process Terms](#development-process-terms)

## Project-Specific Terms

| Term                    | Definition                                                                                                      |
|-------------------------|-----------------------------------------------------------------------------------------------------------------|
| Amazon Transcribe JSON  | JSON format output from Amazon Transcribe service containing timestamped transcription data with speaker labels |
| Speaker Audio Segments  | Individual audio clips extracted from the original recording, separated by speaker                              |
| Speaker Identification  | Process where users rename audio files to identify who is speaking in each segment                              |
| CSV Transcript          | Structured output file containing speaker information, dialogue text, confidence metrics, and review notes      |
| Confidence Score        | Metric (0.0-1.0) provided by Amazon Transcribe indicating reliability of transcription for each word            |
| Confidence Metrics      | Statistical measures (min, max, mean, median) calculated for confidence scores across transcript segments       |
| Misalignment            | Issue where text boundaries don't match natural speech patterns or speaker changes                              |
| Misalignment Detection  | Process of identifying potential transcript errors through various detection methods                            |
| Misalignment Correction | Process of fixing identified transcript issues either automatically or through user review                      |
| Review Suggestion       | Note added to transcript segments with low confidence or detected issues                                        |

## Task Management Terms

| Term           | Definition                                                                       |
|----------------|----------------------------------------------------------------------------------|
| Task           | A unit of work to be completed, represented as a line item in the task list      |
| Sub-task       | A smaller component of a larger task, indented underneath its parent task        |
| Leaf Task      | A task with no sub-tasks, requiring a point estimate                             |
| Point Estimate | Fibonacci number (1,2,3,5,8,13,21) indicating relative effort for a leaf task    |
| Task Status    | Current state of a task: incomplete `[ ]`, in-progress `[-]`, or completed `[x]` |

## Development Process Terms

| Term               | Definition                                                                                       |
|--------------------|--------------------------------------------------------------------------------------------------|
| TDD                | Test-Driven Development - Writing tests before implementation code                               |
| Red-Green-Refactor | TDD cycle: write failing test (red), write code to make it pass (green), improve code (refactor) |
| Task Refinement    | Process of clarifying, organizing, or breaking down tasks into manageable pieces                 |
| Task Advancement   | Process of completing tasks according to TDD principles                                          |
| DRY                | "Don't Repeat Yourself" - A principle of software development to reduce repetition               |

---

For more information about Speakeasy's functionality, refer to [Project Specification](../specification.md).
