I'd like to write a ruby script that processes a transcript output by Amazon Transcribe. 

The script will take two arguments - the path to the json transcript, and the path to the audio file. The script will
then do several things:

1. extract speaker audio
2. look for identified speaker audio files
3. produce a csv of the transcript
4. print segments to review

The transcript JSON structure looks like this:

```
.accountId: str
.jobName: str
.results.audio_segments[].end_time: str
.results.audio_segments[].id: int
.results.audio_segments[].items[]: int
.results.audio_segments[].speaker_label: str
.results.audio_segments[].start_time: str
.results.audio_segments[].transcript: str
.results.items[].alternatives[].confidence: str
.results.items[].alternatives[].content: str
.results.items[].end_time: str
.results.items[].id: int
.results.items[].speaker_label: str
.results.items[].start_time: str
.results.items[].type: str
.results.speaker_labels.channel_label: str
.results.speaker_labels.segments[].end_time: str
.results.speaker_labels.segments[].items[].end_time: str
.results.speaker_labels.segments[].items[].speaker_label: str
.results.speaker_labels.segments[].items[].start_time: str
.results.speaker_labels.segments[].speaker_label: str
.results.speaker_labels.segments[].start_time: str
.results.speaker_labels.speakers: int
.results.transcripts[].transcript: str
.status: str
```

That is:
 - the the transcript is a JSON object with top-level keys accountId (a string), jobName (a string), results (an
   object), and status (a string).
 - results is an object with keys audio_segments (an array), items (an array), speaker_labels (an object), and
   transcripts (an array)
 
 etc.
 
 `items` is the smallest unit. it describes a short section of audio, assigning it an ID and identifying it's start and
 end times. It also includes a speaker label (e.g. spk_0, spk_1, etc), the type of content, and the content itself, with
 a confidence value, a float from 0 to 1.0, stored as a string.
 
 `audio_segments` aggregates consecutive items by a single speaker into larger segments.
 
 `speaker_labels` is the same aggregation, but reduces items to their speaker label and time bounds, rather than
 referencing item IDs
 
= 
 Step 1:
 
The script produces N audio files in the current directory, where N is the number of speakers, the int
`.results.speaker_labels.speakers`. The audio format should be whatever is reasonable, given the input format.

Each audio file is the concatenation of that speaker's audio segments, i.e. the audio between the start_time and
end_time of the segments in audio_segments for that speaker.

The script should use ffmpeg to efficiently extract a speaker's audio, producing a smaller shorter file. It should print
it's progress for each speaker, and for the step overall. The files should be named by their speaker label, e.g.
`spk_0.m4a`, etc.

Once complete, the script should pause, and instruct the user to identify the speakers by appending the speaker's name
to the filename. E.g. if spk_0 is Ben, the user would rename the file to spk_0_Ben.m4a. The script will inform the user
to hit the enter key once they're done.

Step 2: once the user renames the files and hits enter, the script should produce a CSV file in the current directory
with the following columns:

ID: an auto-incrementing integer, starting at 1. Each row increments the ID
Speaker: The speaker's name, e.g. "Ben"
Transcript: What the speaker said for that row
Confidence Min: the minimum confidence of items for this row
Confidence Max: the maximum confidence of items for this row
Confident Mean: the mean confidence of items for this row
Confidence Median: the median confidence for items for this row
Note: one of "multiple speakers", "unknown", or "error"

A new row should be started when:
1. A new speaker speaks
2. There is more than 1 second of silence

If several speakers speakers overlap, or there is no transcript, or there is some unexpected condition with that segment
or row, use the Note field.

If there is more than 3 error rows in a row, the script should print a detailed description of each error, and then exit

The script should display a detailed progress bar to inform the user of its progress.

Finally, after writing out the CSV file, the script should output the IDs of rows with especially low confidence for the
user to review and possibly correct. If there are several consecutive row IDs, they should be grouped into Handle.

The script should handle other errors in a reasonable fashion.


