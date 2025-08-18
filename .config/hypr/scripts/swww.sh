#!/bin/sh

randomwall() {
  dir="${HOME}/Pictures/Wallpapers/"
  BG="$(find "${dir}" -name "*.jpg" -o -name "*.png" -o -name "*.gif" | shuf -n1)"
  
  swww img --transition-fps 144 --transition-duration 0.5 --transition-type grow --transition-pos 0.5,1 "${BG}"

}

nextwall() {
  dir="${HOME}/Pictures/Wallpapers/"
  current_bg=$(swww query | awk -F'image: ' '{print $2}' | awk '{print $1}')
  
  if [ -z "$current_bg" ]; then
    randomwall
    return
  fi

  all_images=($(find "${dir}" -name "*.jpg" -o -name "*.png" -o -name "*.gif" | sort))
  
  next_index=-1
  for i in "${!all_images[@]}"; do
    if [[ "${all_images[$i]}" == "$current_bg" ]]; then
      next_index=$((i + 1))
      break
    fi
  done

  if [ "$next_index" -ge "${#all_images[@]}" ] || [ "$next_index" -eq -1 ]; then
    BG="${all_images[0]}"
  else
    BG="${all_images[$next_index]}"
  fi

  swww img --transition-fps 144 --transition-duration 0.5 --transition-type grow --transition-pos 0.5,1 "${BG}"
  
}

case "$1" in
  --next)
    nextwall
    ;;
  --random)
    randomwall
    ;;
  *)
    randomwall
    ;;
esac
