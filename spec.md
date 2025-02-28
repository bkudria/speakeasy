 # Amazon Transcribe Processing Script Specification

 ## Overview
 This Ruby script processes Amazon Transcribe JSON output alongside the original audio file to:
 1. Extract individual speaker audio segments
 2. Allow for speaker identification
 3. Generate a structured CSV transcript
 4. Highlight segments requiring review

 ## Input
 The script accepts one command-line argument:
 1. Path to a directory containing:
    - The JSON transcript file (named "asrOutput.json")
    - The original audio file (largest audio file in the directory)

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


                                                                       Processing Steps

                                                               Step 1: Speaker Audio Extraction

 1 The script extracts N audio files, where N equals the number of speakers (.results.speaker_labels.speakers).
 2 Each audio file contains the concatenated segments for a single speaker, using the start_time and end_time from audio_segments.
 3 The script uses ffmpeg to extract the audio segments efficiently.
 4 Output files are named according to speaker labels (e.g., spk_0.m4a).
 5 The script displays progress for each speaker extraction and the overall step.
 6 Upon completion, the script prints a summary showing:
    • Total number of speakers detected
    • Number of segments per speaker
    • Total duration of audio per speaker

                                                                        Error Handling

 • If the input audio format is incompatible with ffmpeg, the script will display an error message and exit.

                                                                       User Interaction

 1 After extraction, the script pauses and instructs the user to identify speakers by renaming files:
    • Original: spk_0.m4a
    • Renamed: spk_0_Ben.m4a (if speaker is identified as "Ben")
 2 The script informs the user to press Enter when done with renaming.
 3 If a user doesn't rename a particular speaker file, the script will treat that speaker as unidentified in the CSV output (blank Speaker column).

                                                                    Step 2: CSV Generation

 1 The script generates a CSV file with the following naming convention:
    • Base name matches the audio filename with a .csv extension
    • If a file with that name exists, append an incrementing number (e.g., name.1.csv, name.2.csv)
 2 The CSV contains these columns:
    • ID: Auto-incrementing integer starting at 1
    • Speaker: The identified speaker's name (blank if unidentified)
    • Transcript: The spoken content
    • Confidence Min: Minimum confidence value among items in this segment
    • Confidence Max: Maximum confidence value among items in this segment
    • Confidence Mean: Average confidence value among items in this segment
    • Confidence Median: Median confidence value among items in this segment
    • Note: One of "multiple speakers", "unknown", or "error"
 3 Row segmentation rules:
    • Start a new row when a different speaker begins talking
    • Start a new row when there is more than 1 second of silence
 4 The script displays a detailed progress bar during CSV generation.

                                                                        Error Handling

 • If the script encounters unexpected conditions while processing a segment, it marks the row with "error" in the Note field.
 • If three consecutive error rows occur, the script prints detailed descriptions of each error and exits.

                                                                  Step 3: Review Suggestions

After CSV generation, the script identifies segments with low confidence scores for user review:

 • Low confidence threshold: segments with mean confidence below 0.75
 • The script outputs the IDs of these segments
 • Consecutive IDs are grouped for easier reference


                                                                    General Error Handling

 • The script validates input files exist before processing
 • It checks for proper JSON formatting in the transcript file
 • It verifies the audio file can be processed by ffmpeg
 • All errors are reported with clear, actionable messages
