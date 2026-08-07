#!/usr/bin/env bash

names=(
  "aasimar"
"dragonborn"
"dwarf"
"elf"
"gnome"
"goliath"
"halfling"
"human"
"orc"
"tiefling"
"changeling"
"kalashtar"
"khoravar"
"shifter"
"warforged"
"boggart"
"faerie"
"flamekin"
"lorwyn"
"changeling"
"rimekin"
"dhampir"
"hexblood"
"lupin"
"reborn"
"dhampir"
)

i=1

for name in "${names[@]}"; do
    filename="${name}.json"


    cat > "$filename" <<EOF
{
  "id": "s${i}",
  "catId": "species",
  "name": "${name}",
  "creatureType": "",
  "size": [],
  "speed": ,
  "features": [],
  "subspecies": []
}
EOF

    ((i++))
    echo "- assets/json/species/${name}.json"
done

