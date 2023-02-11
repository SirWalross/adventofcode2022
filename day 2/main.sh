count=0
while IFS= read -r line; do
    left=$(($(printf '%d' "'$(echo $line | cut -d " " -f 1)") - 65))
    outcome=$(($(printf '%d' "'$(echo $line | cut -d " " -f 2)") - 89))
    right=$(((left + outcome) % 3))
    difference=$((right - left))
    if [ "$difference" = "1" -o "$difference" = "-2" ]; then
        # you win
        count=$((count + 6))
    elif [ "$difference" = "0" -o "$difference" = "3" ]; then
        # draw
        count=$((count + 3))
    fi
    count=$((count + right + 1 + (right >= 0 ? 0 : (3))))
done < "input"
echo "${count}"