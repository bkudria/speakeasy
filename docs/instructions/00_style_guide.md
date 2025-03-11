# Instruction Document Style Guide

## Table of Contents
1. [Introduction](#1-introduction)
2. [Document Structure](#2-document-structure)
3. [Formatting Conventions](#3-formatting-conventions)
4. [Lists and Tables](#4-lists-and-tables)
5. [Code References](#5-code-references)
6. [Cross-References](#6-cross-references)

## 1. Introduction

This style guide establishes formatting standards for all instruction documents to ensure consistency and readability. Following these guidelines will make documentation easier to maintain and use.

## 2. Document Structure

### Heading Hierarchy
- **H1 (#)**: Document title only
- **H2 (##)**: Major sections (numbered like "1. Section Name")
- **H3 (###)**: Subsections (using descriptive titles)
- **H4 (####)**: Minor points or examples

### Table of Contents
Each document should include a Table of Contents with links to all H2 sections.
```markdown
## Table of Contents
1. [First Section](#1-first-section)
2. [Second Section](#2-second-section)
```

### Section Order
Maintain consistent section ordering across documents:
1. Introduction/Purpose
2. Key concepts or prerequisites
3. Main content sections
4. Examples (if applicable)
5. References to other documents (if applicable)

## 3. Formatting Conventions

### Emphasis
- Use **bold** for key terms and action items
- Use *italics* for emphasis or definitions
- Use `code formatting` for commands, file paths, or properties

### Paragraph Structure
- Keep paragraphs concise (3-5 lines)
- Use line breaks between paragraphs
- Break complex concepts into multiple paragraphs
- Introduce sections with a brief overview before listing details

### Visual Separation
- Use horizontal rules (---) to separate major content blocks
- Use blank lines to separate related concepts
- Use indentation consistently for nested content (especially in lists)

## 4. Lists and Tables

### Bullet Points
- Use bullet points (-) for related but unordered items
- Keep bullet points parallel in structure
- Begin each point with a capital letter and end without punctuation unless it's a complete sentence
- Use sub-bullets indented with 2 spaces when needed

### Numbered Lists
- Use numbered lists (1. 2. 3.) only for sequential steps/workflows
- Use consistent capitalization and punctuation
- Ensure numbers accurately reflect the sequence

### Tables
- Use tables for structured comparisons or data
- Include a header row
- Align columns appropriately
- Keep table content concise

## 5. Code References

### Code Blocks
Use triple backticks with language specification for code blocks:
```markdown
```ruby
def example_method
  puts "Hello World"
end
```
```

### Inline Code
Format inline code references, commands, and file names with backticks:
- Use command `bundle exec rspec` to run tests
- Edit the `lib/example.rb` file
- Set the `:FILES:` property

### Example Formatting
When showing example input/output, use clear labels and consistent formatting:
```
Input:
example command

Output:
example result
```

## 6. Cross-References

### Document Links
Link to other documents using relative paths:
```markdown
See [Document Name](path/to/document.md) for more information.
```

### Section Links
Link to specific sections using anchors:
```markdown
Refer to the [Task Status Management](04_workflow.md#2-task-status-management) section.
```

### Canonical References
When referring to information that exists in multiple places:
- Identify one location as the canonical source
- Link to that source from other documents
- Include a brief summary followed by the canonical reference link