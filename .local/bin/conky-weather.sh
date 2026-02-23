#!/bin/bash

# Obtener ubicación por IP
ip_data=$(curl -s --max-time 8 "https://ipwho.is/" 2>/dev/null)
lat=$(echo "$ip_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('latitude',''))" 2>/dev/null)
lon=$(echo "$ip_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('longitude',''))" 2>/dev/null)
city=$(echo "$ip_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('city',''))" 2>/dev/null)

# Fallback a Stockholm
lat=${lat:-59.33}
lon=${lon:-18.07}
city=${city:-Stockholm}

location="${city}"

# Obtener clima
weather=$(curl -s --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weathercode&timezone=auto" 2>/dev/null)
temp=$(echo "$weather" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current']['temperature_2m'])" 2>/dev/null)
code=$(echo "$weather" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current']['weathercode'])" 2>/dev/null)

# Icono según código WMO
case "$code" in
    0)           icon="󰖙" ;;
    1|2)         icon="󰖕" ;;
    3)           icon="󰖔" ;;
    45|48)       icon="󰖑" ;;
    51|53|55)    icon="󰖗" ;;
    61|63|65)    icon="󰖖" ;;
    71|73|75|77) icon="󰖘" ;;
    80|81|82)    icon="󰖖" ;;
    95|96|99)    icon="󰖓" ;;
    *)           icon="󰖐" ;;
esac

echo "${icon} ${location}: ${temp}°C"
