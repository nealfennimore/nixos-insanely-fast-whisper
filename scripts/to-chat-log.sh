#! /usr/bin/env bash

jq '.speakers | reduce .[] as $item ([]; 
  if . == [] or last.speaker != $item.speaker then 
    . + [{speaker: $item.speaker, timestamp: $item.timestamp, text: $item.text}] 
  else 
    .[:-1] + [{speaker: last.speaker, timestamp: [last.timestamp[0], $item.timestamp[-1]], text: (last.text + " " + $item.text)}]  
  end
)' output.json

