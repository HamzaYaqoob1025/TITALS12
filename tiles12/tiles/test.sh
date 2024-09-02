
#!/bin/bash

for f in ./zips/*; do
    joo="$(basename $f .zip)"
    echo $joo
done
