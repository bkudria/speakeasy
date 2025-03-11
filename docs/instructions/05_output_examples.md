# Output Examples

## Table of Contents
1. [Reminders](#1-reminders)
2. [Speakeasy-Specific Output Example](#2-speakeasy-specific-output-example)

## 1. Reminders

### General Guidelines
- Strictly adhere to all rules and guidelines provided.
- Ensure only leaf-node tasks have explicit point estimates.
- Your role is crucial in maintaining the integrity and efficiency of the development process.
- Only propose one step at a time: either writing a test or writing code to make a test pass, never both in the same response.

### Task Status Management
- Maintain consistent task status updates as outlined in the canonical [Task Status Management](04_workflow.md#2-task-status-management) reference:
  - Always update the tasks.org file after each step
  - Explicitly mention when to change status: `TODO` → `DOING` after task selection; `DOING` → `DONE` after test success confirmation
  - Verify task status has been properly updated before proceeding to the next step
  - After any context switch or interruption, reconfirm tasks.org reflects the current project state
- Follow all verification procedures defined in the canonical reference:
  - Checking that implementation steps match their corresponding task status
  - Confirming all discovered tasks have been properly documented
  - Ensuring parent tasks reflect the status of their child tasks
  - Validating file listings are up-to-date
- Remember that keeping task status current is critical for project tracking and coordination

## 2. Speakeasy-Specific Output Example

### Task Analysis
<task_analysis>
I need to implement the `detect_issues` method in the MisalignmentDetector class to identify segments with potential misalignments in the transcript. Looking at the task requirements and existing code:

1. The MisalignmentDetector class exists but the `detect_issues` method only has a TODO stub.
2. According to the specification, transcript misalignments can involve:
   - Sentence boundaries that don't align with speaker changes
   - Words with very low confidence scores
   - Unusual pauses or silences
   - Unexpected transitions between speakers

I should implement this method to check transcript rows for these issues and mark problematic segments for review. I'll need to use the ConfidenceCalculator utility for confidence checks.

First, I need to see the existing MisalignmentDetector class structure, the ConfidenceCalculator implementation, and related tests to understand the expected interface.

After reviewing the files, I'll implement the method in a way that:
- Uses the existing helper methods like check_sentence_boundaries
- Integrates with the ConfidenceCalculator for confidence scoring
- Returns a data structure indicating which segments need review
- Follows the existing error handling patterns

The implementation should focus on the core logic without modifying other parts of the codebase.
</task_analysis>

### Response
<response>
Based on the analysis, I need to implement the `detect_issues` method in the MisalignmentDetector class.

Please edit the file `lib/misalignment_detector.rb` and add the following implementation for the `detect_issues` method:

```ruby
def detect_issues
  issues = []
  
  # Check for various types of misalignments
  sentence_boundary_issues = check_sentence_boundaries
  speaker_label_issues = check_speaker_labels
  confidence_issues = check_word_confidence
  pause_issues = check_pause_silences
  timing_issues = check_time_adjacency
  
  # Combine all detected issues
  issues.concat(sentence_boundary_issues) if sentence_boundary_issues
  issues.concat(speaker_label_issues) if speaker_label_issues
  issues.concat(confidence_issues) if confidence_issues
  issues.concat(pause_issues) if pause_issues
  issues.concat(timing_issues) if timing_issues
  
  # Add aggregate confidence issues as a separate check
  aggregate_issues = check_aggregated_confidence_drops
  issues.concat(aggregate_issues) if aggregate_issues
  
  # Return the combined list of issues
  issues
end
```

This implementation calls all the helper methods and combines their results into a single list of issues that can be processed by the calling code.

Please also update the tasks.org file to mark this task as completed:
- Change the status of "Implement detect_issues method in MisalignmentDetector" from "TODO" to "DONE"
</response>