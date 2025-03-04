
- [ ] Write specs for detecting and correcting minor mis-labelings in the input JSON and aligning them correctly in the CSV
  - Generally, these mis-alignments are only one or two words. Once corrected, the result should generally reflect that
    speakers usually their sentences.
  - Write failing specs only, we will implement this functionality later
  - [ ] Detect incorrectly labeled segments by analyzing sentence boundaries using punctuation data
  - [ ] For short mis-alignments (1–2 words), move them to the correct speaker row
  - [ ] If an ambiguous fragment cannot be determined, duplicate it in both rows with "review" in the Note
  - [ ] Check word-level confidence and overlap to verify alignment
  - [ ] Check pause and silence data to confirm correct segmentation

- [ ] Implement a "multiple speakers" note:
  - [ ] If any row's timestamps overlap with other rows bearing different speakers, mark all involved rows with "multiple speakers" in the Note column

- [ ] Add a "review" note for low-confidence segments:
  - [ ] Allow multiple values in the "note" column, separated by commas

- [ ] Provide a manual review step for suspected mis-labeling, occurring after the CSV is fully written.

- [ ] 
