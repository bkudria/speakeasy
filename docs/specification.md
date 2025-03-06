# Speakeasy

## Overview
Speakeasy processes Amazon Transcribe JSON output alongside the original audio file to:
1. Extract individual speaker audio segments
2. Enable speaker identification
3. Generate a structured CSV transcript
4. Highlight segments requiring review

## Input
A directory containing:
- JSON transcript file, see lib/transcript_parser.rb for schema
- Original audio file

## Processing Steps

### 1. Speaker Audio Extraction
- Extracts separate audio files for each speaker
- Names files according to speaker labels (e.g., `spk_0.m4a`)
- Displays speaker statistics upon completion

### 2. Speaker Identification
- User renames audio files to identify speakers (e.g., `spk_0_Ben.m4a`)
- Script automatically opens the output directory for convenience
- User types `go` to continue processing

### 3. CSV Generation
- Creates `transcript.csv` with columns:
  - ID, Speaker, Transcript, Confidence metrics, Notes
- Detects misaligned sentences or speaker segments
- Marks problematic segments for review

### 4. Review Suggestions
- Identifies segments with low confidence scores for user review
- Default threshold: 0.75 (configurable)

## Error Handling
- Validates input files and formats
- Provides clear error messages for troubleshooting
