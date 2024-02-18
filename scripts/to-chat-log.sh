#! /usr/bin/env bash

UNIQUE_SPEAKERS=$(jq  '.speakers | unique_by(.speaker) | map(.speaker) | reduce .[] as $item ({}; .[$item] = $item) ' output.json)


NUM_UNIQUE_SPEAKERS=$(jq 'keys | length' <<< "$UNIQUE_SPEAKERS")

get_random_item() {
  local ITEMS="$1"
  local LENGTH=$(jq 'length' <<< "$ITEMS")
  local RANDOM_IDX=$((RANDOM % LENGTH))
  jq --argjson idx $RANDOM_IDX '.[$idx]' <<< "$ITEMS"
}

echo "Press 'c' to find another sample for the speaker"

# Replace the speakers with the speaker name
for i in $(seq 0 $((NUM_UNIQUE_SPEAKERS-1))); do
  NUM=$(printf "%02d" $i)

  echo "Who is SPEAKER_$NUM?"

  ITEMS=$(jq \
  --arg speaker "SPEAKER_$NUM" \
  '.speakers | map(select(.speaker == $speaker))' output.json)

  while [[ -z "$NAME" ]]; do
    ITEM=$(get_random_item "$ITEMS")
    echo "Found at: $(jq '.timestamp | [.[] | [ (. / 60 | floor), . % 60] | "\(.[0])m \(.[1])s"]' <<< "$ITEM")"
    echo "Saying: $(jq '.text' <<< "$ITEM")"
    read NAME
    # Check if NAME is "C" or "c" and reset NAME if true to continue the loop
    if [[ "$NAME" =~ ^(C|c)$ ]]; then
        NAME="" # Reset NAME to ensure loop continues
        echo "Finding another sample for SPEAKER_$NUM"
    fi
    echo
  done

  UNIQUE_SPEAKERS=$(jq \
    --arg speaker "SPEAKER_$NUM" \
    --arg name "$NAME" \
    '.  + {$speaker: $name}' <<< "$UNIQUE_SPEAKERS")

  NAME=""
done

WITH_CORRECT_SPEAKERS=$(jq \
  --argjson unique_speakers "$UNIQUE_SPEAKERS" \
  '.speakers |= map(.speaker = $unique_speakers[.speaker])' output.json)

LINEARLY_CONDENSED_BY_SPEAKER=$(jq '.speakers | reduce .[] as $item ([]; 
  if . == [] or last.speaker != $item.speaker then 
    . + [{speaker: $item.speaker, timestamp: $item.timestamp, text: $item.text}] 
  else 
    .[:-1] + [{speaker: last.speaker, timestamp: [last.timestamp[0], $item.timestamp[-1]], text: (last.text + " " + $item.text)}]  
  end
)' <<< "$WITH_CORRECT_SPEAKERS")

jq -r 'map(.speaker + ":" + .text)[]' <<< "$LINEARLY_CONDENSED_BY_SPEAKER" > chat.log


