#!/usr/bin/env bash
# 
# This script removes any data in asrOutput.json that is not in the middle
# 15 minutes of the transcript. To run:
#   ./fake_transcript_generator.sh <path_to_asrOutput.json>
#
# NOTE: This script addresses only the first sub-task: removing out-of-range data.

set -e

if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "Usage: $0 path/to/asrOutput.json"
  exit 1
fi

INPUT_JSON="$1"
OUTPUT_JSON="filtered_asrOutput.json"

# 1) Find the largest end_time in audio_segments to determine total duration
TOTAL_DURATION=$(jq '[.results.audio_segments[] | select(.end_time != null) | .end_time | tonumber] | max' "$INPUT_JSON")

# Convert 15 minutes to seconds
MIDDLE_WINDOW=900
HALF_WINDOW=$((MIDDLE_WINDOW / 2))

# 2) Calculate the start and end of the middle 15 minutes
START_TIME=$(awk -v dur="$TOTAL_DURATION" -v hw="$HALF_WINDOW" 'BEGIN { print dur/2 - hw }')
END_TIME=$(awk -v dur="$TOTAL_DURATION" -v hw="$HALF_WINDOW" 'BEGIN { print dur/2 + hw }')

MIN_ID=$(jq --argjson start "$START_TIME" \
            --argjson end "$END_TIME" \
            '[.results.items[] 
               | select(
                   ((.start_time | tonumber) < $end)
                   and 
                   ((.end_time   | tonumber) > $start)
                   and
                   (.start_time != null) 
                   and 
                   (.end_time != null)
                 ) 
               | .id
             ] 
             | min' "$INPUT_JSON")

MAX_ID=$(jq --argjson start "$START_TIME" \
            --argjson end "$END_TIME" \
            '[.results.items[] 
               | select(
                   ((.start_time | tonumber) < $end)
                   and 
                   ((.end_time   | tonumber) > $start)
                   and
                   (.start_time != null) 
                   and 
                   (.end_time != null)
                 ) 
               | .id
             ] 
             | max' "$INPUT_JSON")

echo "Total duration: $TOTAL_DURATION seconds"
echo "Keeping segments in [$START_TIME, $END_TIME]"
echo "Keeping item IDs in [${MIN_ID}, ${MAX_ID}] (for items with no time data)"

# 3) Filter audio_segments to keep only those overlapping with [START_TIME, END_TIME]
#    We also filter items in .results.items similarly, based on their start_time.

jq --argjson start "$START_TIME" \
   --argjson end "$END_TIME" \
   --argjson minid "$MIN_ID" \
   --argjson maxid "$MAX_ID" \
   '
   .results.audio_segments |= map(select(
        ( ( .start_time | tonumber ) < $end )
      and
        ( ( .end_time   | tonumber ) > $start )
   ))
   |
   .results.items |= map(select(
      (
        (.start_time != null and (.start_time | tonumber) < $end)
        and
        (.end_time != null   and (.end_time   | tonumber) > $start)
      )
      or
      (
        (.start_time == null or .end_time == null)
        and
        (.id | tonumber) >= $minid
        and
        (.id | tonumber) <= $maxid
      )
   ))
   ' "$INPUT_JSON" > "$OUTPUT_JSON"

echo "Filtered transcript saved to $OUTPUT_JSON"
echo "Done removing data outside the middle 15 minutes."
