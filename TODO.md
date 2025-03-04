- [ ] Migrate transcript construction to use individual items instead of audio_segments
  - [ ] Update TranscriptParser to provide a clear, structured list of items (tokens) ready for grouping.
  - [ ] Adjust CsvGenerator (and related code in TranscriptProcessor) to iterate over items for row construction, rather than audio_segments.
  - [ ] Ensure speaker_label handling is consistent at the item level, preserving speaker continuity when forming rows.
  - [ ] Add or update specs to confirm the new item-driven approach produces correct transcripts (with speaker labels, punctuation, confidence stats).

- [ ] Write specs for mis-labeled segments and misaligned sentences in the input JSON
  - We will follow TDD to separate detection specs from correction specs, writing failing specs first
  - Generally, these mis-alignments are only one or two words, and corrected rows should reflect complete sentences

  - [ ] Detection specs:
    - [ ] Add specs for detecting incorrectly labeled segments by analyzing sentence boundaries (punctuation data)
      - Misalignment examples:
        - Sore Throat:
          - Misaligned:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better. Thank
              Gloria: you. I appreciate it.
          - Corrected:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
              Gloria: Thank you. I appreciate it.
        - Real Words:
          - Misaligned:
              Bob: It's a good talent to be able to say that. It's not actually
              Gloria: you. I appreciate it.
          - Corrected:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
              Jim: a real word. I learned that
        - Not a misalignment: even if Jim doesn't have a complete sentence, Bob starts a new sentence, indicating that
          Bob interrupted Jim. This transcript is correct:
            Jim: Hey Bob, question. Is it your intention or your recommendation that we fill up all 22 slots next Wednesday? That would be a
            Bob: I mean, I think that is the ideal scenario.

    - [ ] Add specs that test word-level confidence and overlap to verify alignment
    - [ ] Add specs that test pause/silence data to confirm correct segmentation
    - [ ] Add specs for time-based adjacency checks for short offsets from expected boundaries
    - [ ] Add specs for cross-speaker transition checks to verify trailing words belong to the next speaker
    - [ ] Add specs for aggregated confidence trending to detect abrupt confidence drops (indicating misalignment)

  - [ ] Correction specs:
    - [ ] Add specs to show that short misaligned words (1–2 words) are moved to the correct speaker row
    - [ ] If in doubt about which speaker a fragment belongs to, mark the affected row(s) with "review" in the Note

- [ ] Implement a "multiple speakers" note:
  - [ ] If any row's timestamps overlap with other rows bearing different speakers, mark all involved rows with "multiple speakers" in the Note column

- [ ] Add a "review" note for low-confidence segments:
  - [ ] Allow multiple values in the "note" column, separated by commas

- [ ] Provide a manual review step for suspected mis-labeling, occurring after the CSV is fully written.

- [ ]
