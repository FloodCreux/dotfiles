sketchybar -m --set io_speed label=$(iostat | awk 'NR == 3 { printf("%02.02f MB/s", $6) }')
