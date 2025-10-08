#!/bin/bash
# Custom temperature and monitoring functions for oh-my-bash powerline-multiline
# Save this file as ~/.oh-my-bash/custom/functions/temperature.bash

# Function to get CPU temperature
function __powerline_temperature_prompt {
  local temp_file="/sys/class/thermal/thermal_zone0/temp"
  if [[ -r "$temp_file" ]]; then
    local temp_millic=$(< "$temp_file")
    local temp_c=$((temp_millic / 1000))
    local color=""
    local symbol=""
    
    # Color coding and symbols based on temperature
    if ((temp_c <= 40)); then
      color="70"      # Green - cool
      symbol="❄️"
    elif ((temp_c <= 60)); then  
      color="208"     # Yellow - warm  
      symbol="🌡️"
    elif ((temp_c <= 80)); then
      color="202"     # Orange - hot
      symbol="🔥"
    else
      color="196"     # Red - critical
      symbol="🚨"
    fi
    
    # Use printf for proper powerline format (no newline)
    printf "%s %s°C|%s" "$symbol" "$temp_c" "$color"
  fi
}

# Function to get system load
function __powerline_load_prompt {
  local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
  local load_percent=$(printf "%.0f" "$(echo "$load * 100 / $(nproc)" | bc -l)")
  local color=""
  
  if ((load_percent <= 30)); then
    color="70"      # Green - low load
  elif ((load_percent <= 70)); then
    color="208"     # Yellow - moderate load
  else  
    color="196"     # Red - high load
  fi
  
  # Use printf for proper powerline format (no newline)
  printf "⚡ %s%%|%s" "$load_percent" "$color"
}

# Function to get memory usage
function __powerline_memory_prompt {
  local mem_info=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
  local color=""
  
  if ((mem_info <= 60)); then
    color="70"      # Green - low usage
  elif ((mem_info <= 85)); then
    color="208"     # Yellow - moderate usage  
  else
    color="196"     # Red - high usage
  fi
  
  # Use printf for proper powerline format (no newline)
  printf "🧠 %s%%|%s" "$mem_info" "$color"
}

# Function to get disk usage for root partition
function __powerline_disk_prompt {
  local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  local color=""
  
  if ((disk_usage <= 70)); then
    color="70"      # Green - plenty of space
  elif ((disk_usage <= 90)); then
    color="208"     # Yellow - getting full
  else
    color="196"     # Red - nearly full
  fi
  
  # Use printf for proper powerline format (no newline)
  printf "💾 %s%%|%s" "$disk_usage" "$color"
}

# Function to get disk usage for root partition
function __powerline_disk_prompt {
  local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  local color=""
  
  if ((disk_usage <= 70)); then
    color="70"      # Green - plenty of space
  elif ((disk_usage <= 90)); then
    color="208"     # Yellow - getting full
  else
    color="196"     # Red - nearly full
  fi
  
  # Use printf for proper powerline format (no newline)
  printf "💾 %s%%|%s" "$disk_usage" "$color"
}

# Function to check if system needs updates
function __powerline_updates_prompt {
  local updates_available=""
  if command -v apt >/dev/null 2>&1; then
    # Count available updates (this might be slow, so cache it)
    local update_cache="/tmp/update_count_cache"
    local cache_max_age=3600  # 1 hour
    
    if [[ ! -f "$update_cache" ]] || [[ $(($(date +%s) - $(stat -c %Y "$update_cache" 2>/dev/null || echo 0))) -gt $cache_max_age ]]; then
      apt list --upgradable 2>/dev/null | wc -l > "$update_cache" 2>/dev/null || echo "0" > "$update_cache"
    fi
    
    local updates=$(< "$update_cache")
    if ((updates > 1)); then  # subtract 1 for header line
      local actual_updates=$((updates - 1))
      local color="208"  # Yellow for available updates
      # Use printf for proper powerline format (no newline)
      printf "📦 %s|%s" "$actual_updates" "$color"
    fi
  fi
}

# High-level monitoring function combining multiple metrics
function __powerline_sysmon_prompt {
  local temp_c=0
  local temp_file="/sys/class/thermal/thermal_zone0/temp"
  if [[ -r "$temp_file" ]]; then
    temp_c=$(( $(< "$temp_file") / 1000 ))
  fi
  
  local load_percent=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//' | awk '{printf "%.0f", $1 * 100 / '$(nproc)'}')
  local mem_percent=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
  
  local color="70"    # Default green
  local symbol="✅"   # All good
  
  # Determine overall system health
  if ((temp_c > 80)) || ((load_percent > 90)) || ((mem_percent > 90)); then
    color="196"       # Red - system stress
    symbol="🚨"
  elif ((temp_c > 60)) || ((load_percent > 70)) || ((mem_percent > 80)); then
    color="208"       # Yellow - moderate load
    symbol="⚠️"
  fi
  
  # Use printf for proper powerline format (no newline)
  printf "%s %s°C|%s%%|%s%%|%s" "$symbol" "$temp_c" "$load_percent" "$mem_percent" "$color"
}

# Export functions for use in oh-my-bash themes
export -f __powerline_temperature_prompt
export -f __powerline_load_prompt  
export -f __powerline_memory_prompt
export -f __powerline_disk_prompt
export -f __powerline_updates_prompt
export -f __powerline_sysmon_prompt

# ================================
# TEST FUNCTIONS WITH ACTUAL COLORS
# These functions show colored output when called directly
# ================================

# Test function to show temperature with colors
function show_temperature {
  local temp_file="/sys/class/thermal/thermal_zone0/temp"
  if [[ -r "$temp_file" ]]; then
    local temp_millic=$(< "$temp_file")
    local temp_c=$((temp_millic / 1000))
    local color_code=""
    local symbol=""
    
    # Color coding and symbols based on temperature
    if ((temp_c <= 40)); then
      color_code="\033[32m"  # Green - cool
      symbol="❄️"
    elif ((temp_c <= 60)); then  
      color_code="\033[33m"  # Yellow - warm  
      symbol="🌡️"
    elif ((temp_c <= 80)); then
      color_code="\033[31m"  # Red - hot
      symbol="🔥"
    else
      color_code="\033[91m"  # Bright red - critical
      symbol="🚨"
    fi
    
    printf "${color_code}%s %s°C\033[0m\n" "$symbol" "$temp_c"
  fi
}

# Test function to show system load with colors
function show_load {
  local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
  local load_percent=$(printf "%.0f" "$(echo "$load * 100 / $(nproc)" | bc -l)")
  local color_code=""
  
  if ((load_percent <= 30)); then
    color_code="\033[32m"  # Green - low load
  elif ((load_percent <= 70)); then
    color_code="\033[33m"  # Yellow - moderate load
  else  
    color_code="\033[31m"  # Red - high load
  fi
  
  printf "${color_code}⚡ %s%%\033[0m\n" "$load_percent"
}

# Test function to show memory usage with colors
function show_memory {
  local mem_info=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
  local color_code=""
  
  if ((mem_info <= 60)); then
    color_code="\033[32m"  # Green - low usage
  elif ((mem_info <= 85)); then
    color_code="\033[33m"  # Yellow - moderate usage  
  else
    color_code="\033[31m"  # Red - high usage
  fi
  
  printf "${color_code}🧠 %s%%\033[0m\n" "$mem_info"
}

# Test function to show overall system status with colors
function show_system_status {
  echo "🖥️  System Status:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "Temperature: "; show_temperature
  printf "CPU Load:    "; show_load  
  printf "Memory:      "; show_memory
  printf "Disk (root): "
  
  local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  local color_code=""
  
  if ((disk_usage <= 70)); then
    color_code="\033[32m"  # Green - plenty of space
  elif ((disk_usage <= 90)); then
    color_code="\033[33m"  # Yellow - getting full
  else
    color_code="\033[31m"  # Red - nearly full
  fi
  
  printf "${color_code}💾 %s%%\033[0m\n" "$disk_usage"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Export the test functions
export -f show_temperature
export -f show_load
export -f show_memory
export -f show_system_status

# ================================
# INLINE MONITORING SHORTCUTS
# These functions provide colored one-liner output
# ================================

# Inline temperature display
function temp {
  echo -n $(show_temperature)
}

# Inline load display  
function load {
  echo -n $(show_load)
}

# Inline memory display
function mem {
  echo -n $(show_memory)
}

# Inline disk display
function disk {
  local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  local color_code=""
  
  if ((disk_usage <= 70)); then
    color_code="\033[32m"  # Green - plenty of space
  elif ((disk_usage <= 90)); then
    color_code="\033[33m"  # Yellow - getting full
  else
    color_code="\033[31m"  # Red - nearly full
  fi
  
  echo -n -e "${color_code}💾 ${disk_usage}%\033[0m"
}

# Quick system overview inline
function sys {
  echo -n "$(show_temperature) $(show_load) $(show_memory)"
}

# System stats with separators
function stats {
  echo -n "$(show_temperature) | $(show_load) | $(show_memory) | $(disk)"
}

# Export the inline functions
export -f temp
export -f load  
export -f mem
export -f disk
export -f sys
export -f stats
