- [ ] Migrate transcript construction to use individual items instead of audio_segments
  - [x] Update TranscriptParser to provide a clear, structured list of items (tokens) ready for grouping by speaker
  - [ ] Adjust CsvGenerator (and related code in TranscriptProcessor) to iterate over items for row construction, rather than audio_segments.
  - [ ] Ensure speaker_label handling is consistent at the item level, preserving speaker continuity when forming rows.
  - [ ] Add or update specs to confirm the new item-driven approach produces correct transcripts (with speaker labels, punctuation, confidence stats).

- [ ]
