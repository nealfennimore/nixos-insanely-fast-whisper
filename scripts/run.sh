#! /usr/bin/env bash

insanely-fast-whisper \
    --file-name "$1" \
    --task transcribe \
    --language english \
    --device-id 0 \
    --hf_token "$(op read -n op://Personal/hugging_face_speaker_diarization/credential)"