#!/usr/bin/fish

# pending upgrades
set UPGRADES (/usr/lib/update-notifier/apt-check 2>&1)
set UPGRADES_PENDING (echo $UPGRADES | cut -d ';' -f 1)
set UPGRADES_SECURITY (echo $UPGRADES | cut -d ';' -f 2)
if begin
    [ $UPGRADES_PENDING -gt 0 ]
    or [ $UPGRADES_SECURITY -gt 0 ]
    end
    set_color -ou white 
    echo "Upgrades available"
    set_color normal
    set_color yellow
    echo "$UPGRADES_PENDING packages to be upgraded"
    set_color magenta
    echo "$UPGRADES_SECURITY security packages"
    set_color normal
    echo
end

# raid status, perform only if raid exists
if [ -e /dev/md0 ]

# check raid status
    set_color -ou white
    echo "RAID status"
    set_color normal
    if set RAIDUP (grep -o "\[[U]*\]" /proc/mdstat)
        set_color cyan
        echo $RAIDUP
    else
        set_color -o red
        grep -o "\[[_UF]*[_F][_UF]*\]" /proc/mdstat
    end
    echo
    set_color normal

# raid temps
    if [ -f ~/.scripts/hdtemps ]
        set_color -ou white
        echo "RAID Temperatures"
        set_color normal
        set HDDS (grep -o 'sd[a-z]' /proc/mdstat | sort)
        set COUNT 1
        for i in (~/.scripts/hdtemps)
            echo -en "\033[32m$HDDS[$COUNT]: \033[36m$i°C "
            set COUNT (math $COUNT + 1)
        end
        echo -e "\n"
        set_color normal
    end

# raid space left
    set_color -ou white
    echo "RAID usage"
    set_color normal
    set RAID_AVAIL (df -h /dev/md0 | awk '!/Used/ {print $4}')
    set RAID_USAGE (df -h /dev/md0 | awk '!/Used/ {print $5}')
    echo -e "\033[32mAvailable: \033[36m$RAID_AVAIL \033[32mUsed: \033[36m$RAID_USAGE\n"
    set_color normal
end

# is the internet on fire status reports
set_color -ou white
echo "Is the internet broken?"
set_color normal; set_color blue
host -t txt istheinternetonfire.com | cut -f 2 -d '"' | sed 's/^/ • /' | sed 's/\\\;/\n\n •/' | fmt
echo
set_color normal

set_color green
echo 'Press Enter to continue...'
set_color normal

