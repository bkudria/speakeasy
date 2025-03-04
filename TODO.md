
- [ ] Write specs for detecting and correcting minor mis-labelings in the input JSON and aligning them correctly in the CSV
  - Generally, these mis-alignments are only one or two words. Once corrected, the result should generally reflect that
    speakers usually their sentences.
  - Write failing specs only, we will implement this functionality later
  - [ ] Add specs for detecting incorrectly labeled segments by analyzing sentence boundaries using punctuation data
  - [ ] Add specs the test that for short mis-alignments (1–2 words), the program moves them to the correct speaker row
  - [ ] Add specs that test that if an ambiguous fragment cannot be determined, the program will duplicate it in both rows with "review" in the Note
  - [ ] Add specs that test that the program shecks word-level confidence and overlap to verify alignment
  - [ ] Add specs that test that the program checks pause and silence data to confirm correct segmentation
  - [ ] Add specs for time-based adjacency checks for short offset from expected boundaries
  - [ ] Add specs for cross-speaker transition checks (without textual cues) to verify trailing words actually belong to the next speaker
  - [ ] Add specs for aggregated confidence trending to detect abrupt confidence drops that might indicate misalignment

- [ ] Implement a "multiple speakers" note:
  - [ ] If any row's timestamps overlap with other rows bearing different speakers, mark all involved rows with "multiple speakers" in the Note column

- [ ] Add a "review" note for low-confidence segments:
  - [ ] Allow multiple values in the "note" column, separated by commas

- [ ] Provide a manual review step for suspected mis-labeling, occurring after the CSV is fully written.

- [ ] 
