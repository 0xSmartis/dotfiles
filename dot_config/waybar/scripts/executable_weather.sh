#!/usr/bin/env bash

CITY="Graz"
CACHE="/tmp/waybar-weather-graz.txt"
CACHE_MAX_AGE=900

URL="https://wttr.in/${CITY}?format=%C|%t|%f|%h|%w"

if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -lt "$CACHE_MAX_AGE" ]; then
  DATA="$(cat "$CACHE")"
else
  DATA="$(curl -sf --max-time 5 "$URL")"

  if [ -n "$DATA" ]; then
    echo "$DATA" > "$CACHE"
  elif [ -f "$CACHE" ]; then
    DATA="$(cat "$CACHE")"
  else
    jq -cn \
      --arg text "󰖐 --°C" \
      --arg tooltip "Wetterdaten für Graz nicht verfügbar" \
      --arg class "weather-error" \
      '{text: $text, tooltip: $tooltip, class: $class}'
    exit 0
  fi
fi

DESC="$(echo "$DATA" | cut -d'|' -f1)"
TEMP="$(echo "$DATA" | cut -d'|' -f2)"
FEELS="$(echo "$DATA" | cut -d'|' -f3)"
HUMIDITY="$(echo "$DATA" | cut -d'|' -f4)"
WIND="$(echo "$DATA" | cut -d'|' -f5)"

DESC_LOWER="$(echo "$DESC" | tr '[:upper:]' '[:lower:]')"

case "$DESC_LOWER" in
  *sunny*|*clear*)
    ICON="☀️"
    CLASS="weather-clear"
    ;;
  *partly*|*cloudy*)
    ICON="⛅"
    CLASS="weather-cloudy"
    ;;
  *overcast*)
    ICON="☁️"
    CLASS="weather-overcast"
    ;;
  *mist*|*fog*)
    ICON="🌫️"
    CLASS="weather-fog"
    ;;
  *rain*|*drizzle*|*shower*)
    ICON="🌧️"
    CLASS="weather-rain"
    ;;
  *thunder*|*storm*)
    ICON="⛈️"
    CLASS="weather-storm"
    ;;
  *snow*|*sleet*|*blizzard*)
    ICON="❄️"
    CLASS="weather-snow"
    ;;
  *)
    ICON="🌡️"
    CLASS="weather-default"
    ;;
esac

TEXT="${ICON} ${TEMP}"
TOOLTIP="Graz: ${DESC}
Temperatur: ${TEMP}
Gefühlt: ${FEELS}
Luftfeuchtigkeit: ${HUMIDITY}
Wind: ${WIND}"

jq -cn \
  --arg text "$TEXT" \
  --arg tooltip "$TOOLTIP" \
  --arg class "$CLASS" \
  '{text: $text, tooltip: $tooltip, class: $class}'