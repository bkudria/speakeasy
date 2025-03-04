# Speakeasy

## Overview

Speakeasy is a Ruby program that processes Amazon Transcribe JSON output alongside the original audio file to:

1. Extract individual speaker audio segments
2. Allow for speaker identification
3. Generate a structured CSV transcript
4. Highlight segments requiring review

## Input

The script accepts one command-line argument - a directory containing:

1. the JSON transcript file
2. the original audio file

## JSON Structure

The Amazon Transcribe JSON follows this structure:

```json
{
  "accountId": "string",
  "jobName": "string",
  "results": {
    "audio_segments": [
      {
        "end_time": "string",
        "id": "integer",
        "items": ["integer"],
        "speaker_label": "string",
        "start_time": "string",
        "transcript": "string"
      }
    ],
    "items": [
      {
        "alternatives": [
          {
            "confidence": "string",
            "content": "string"
          }
        ],
        "end_time": "string",
        "id": "integer",
        "speaker_label": "string",
        "start_time": "string",
        "type": "string"
      }
    ],
    "speaker_labels": {
      "channel_label": "string",
      "segments": [
        {
          "end_time": "string",
          "items": [
            {
              "end_time": "string",
              "speaker_label": "string",
              "start_time": "string"
            }
          ],
          "speaker_label": "string",
          "start_time": "string"
        }
      ],
      "speakers": "integer"
    },
    "transcripts": [
      {
        "transcript": "string"
      }
    ]
  },
  "status": "string"
}
```

## Processing Steps

### Step 1: Speaker Audio Extraction

1. The script extracts N audio files, where N equals the number of speakers (`.results.speaker_labels.speakers`).
2. Each audio file contains the concatenated segments for a single speaker, using the `start_time` and `end_time` from `audio_segments`.
3. The script uses `ffmpeg` to extract the audio segments efficiently.
4. Output files are named according to speaker labels (e.g., `spk_0.m4a`).
5. The script displays progress for each speaker extraction and the overall step.
6. Upon completion, the script prints a summary showing:
  - Total number of speakers detected
  - Number of segments per speaker
  - Total duration of audio per speaker

#### Error Handling

If the input audio format is incompatible with ffmpeg, the script will display an error message and exit.

#### User Interaction

1. After extraction, the script pauses and instructs the user to identify speakers by renaming files:
  - Original: spk\_0.m4a
  - Renamed: spk\_0\_Ben.m4a (if speaker is identified as "Ben")

2. The script instructs the user to type `go` and press Enter when done renaming.
3. If a user doesn't rename a particular speaker file, the script will treat that speaker as unidentified in the CSV
   output (blank Speaker column).
4. If the script detects any files matching the pattern `spk_*_*.m4a`, it treats those speakers as already identified,
   so speaker audio extraction is skipped. Otherwise, if it detects only files named like `spk_#.m4a`, the user is
   prompted to rename them to indicate the correct speaker name. If no named files are found after this prompt, the
   script exits with an error.

#### Additional Platform Handling

- To assist with speaker renaming, the script detects the user's operating system after audio file generation.
- It determines which command to use for opening the output directory, and then executes that command to open the directory automatically.

### Step 2: CSV Generation

1. The script generates a `transcript.csv`
2. The CSV contains these columns:
  - ID: Auto-incrementing integer starting at 1
  - Speaker: The identified speaker's name (blank if unidentified)
  - Transcript: The spoken content
  - Confidence Min: Minimum confidence value among items in this segment
  - Confidence Max: Maximum confidence value among items in this segment
  - Confidence Mean: Average confidence value among items in this segment
  - Confidence Median: Median confidence value among items in this segment
  - Note: One of "multiple speakers", "unknown", "error", or "review"
  - The script detects and corrects misaligned sentences or mis-labeled speaker segments.
3. The script displays a detailed progress bar during CSV generation.

#### Error Handling

- If the script encounters unexpected conditions while processing a segment, it marks the row with "error" in the Note field.
- If three consecutive error rows occur, the script prints detailed descriptions of each error and exits.

### Step 3: Review Suggestions

After CSV generation, the script identifies segments with low confidence scores for user review:

- Low confidence threshold: segments with mean confidence below 0.75 by default,
  but this threshold can be changed when initializing the detector or via CLI flags.

## General Error Handling

- The script validates input files exist before processing
- It checks for proper JSON formatting in the transcript file
- It verifies the audio file can be processed by ffmpeg
- All errors are reported with clear, actionable messages
