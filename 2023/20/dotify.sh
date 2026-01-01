#!/bin/bash

input=$1

if [ ! -f "$input" ]; then
  echo "Usage: $0 <INPUT.TXT>"
  exit 1
fi

cat <<-END
digraph {
broadcaster [ shape=circle,
  style="filled,bold",
  fillcolor="green",
  penwidth=4,
  fontname="Helvetica-Bold"
]
END
cat <<-END
node [ shape=box,
   style="filled",
   fillcolor="blue",
   fontcolor="white",
   penwidth=4,
   fontname="Helvetica-Bold"
 ]
END
grep -e '^%' $input | sed 's/^%//' | cut -c1-2
cat <<-END
node [ shape=triangle,
  style="filled",
  fillcolor="red",
   fontcolor="white",
   penwidth=4,
   fontname="Helvetica-Bold"
]
END
grep -e '^&' $input | sed 's/^&//' | cut -c1-2
grep -e '^broadcaster' $input | sed 's/-> /-> {/' | sed 's/$/};/'
grep -e '^%' $input | sed 's/^%//' | sed 's/-> /-> {/' | sed 's/$/};/'
grep -e '^&' $input | sed 's/^&//' | sed 's/-> /-> {/' | sed 's/$/};/'
echo "}"
