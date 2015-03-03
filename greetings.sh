#!/bin/bash

# colour escape codes
STYLE_NORMAL='\033[0m'
STYLE_TITLE='\033[1;4;37m'
STYLE_INFO='\033[32m'
STYLE_DATA='\033[36m'
STYLE_HIGHLIGHT='\033[33m'
STYLE_WARN='\033[35m'
STYLE_ALERT='\033[31m'

# last logins
echo -e "${STYLE_TITLE}Last logins${STYLE_NORMAL}"
echo -e "${STYLE_INFO}User\tAddress\t\tLogged in\tLogged out${STYLE_DATA}"
last -n 3 | awk '!/wtmp/ {$2=""; print $0}'
echo -en "${STYLE_NORMAL}"

# pending upgrades
if [ -f /usr/lib/update-notifier/apt-check ]; then
    UPGRADES=`/usr/lib/update-notifier/apt-check 2>&1`
    UPGRADES_PENDING=`echo $UPGRADES | cut -d ';' -f 1`
    UPGRADES_SECURITY=`echo $UPGRADES | cut -d ';' -f 2`

    if [ $UPGRADES_PENDING -gt 0 ] ||
        [ $UPGRADES_SECURITY -gt 0 ]; then
        echo -e "${STYLE_TITLE}Upgrades available${STYLE_NORMAL}"
        echo -e "${STYLE_HIGHLIGHT}${UPGRADES_PENDING} packages to be upgraded"
        echo -e "${STYLE_WARN}${UPGRADES_SECURITY} security packages"
        echo -e "${STYLE_NORMAL}"
    fi
fi

# raid status
if [ -e /dev/md0 ]; then

    # check raid status
    echo -e "${STYLE_TITLE}RAID status${STYLE_NORMAL}"
    if RAIDUP=`grep -o "\[[U]*\]" /proc/mdstat`; then
        echo -e "${STYLE_DATA}${RAIDUP}"
    else
        echo -e "${STYLE_ALERT}${RAIDUP}"
    fi
    echo -e "${STYLE_NORMAL}"

    #raid temps
    if HDDTEMPS=`nc localhost 7634` && [ ! -z "$HDDTEMPS" ]; then
        HDDS=`grep -o 'sd[a-z]' /proc/mdstat | sort`
        HDDSARR=($HDDS)
        HDDPATHS=`echo $HDDS | sed 's|sd|/dev/sd|g'`

        TEMPLIST=`echo $HDDTEMPS | awk -F '|' -v DEVS="$HDDPATHS" '
        NR==1 { NDEV = split(DEVS,DEV," ") ; if (NDEV < 1) exit(1) }
        {
            OUTSTRING = "";
            for (i = 1; i <= NF; i++)
            {
                for (d = 1; d <= NDEV; d++)
                {
                    if ($i == DEV[d])
                    {
                        OUTSTRING = OUTSTRING $(i+2) "\n"
                    }
                }
            }
            print OUTSTRING
        }
        ' -`

        echo -e "${STYLE_TITLE}RAID temperatures${STYLE_NORMAL}"

        COUNT=0
        for HD in $TEMPLIST; do
            echo -en "$STYLE_INFO${HDDSARR[COUNT]}: $STYLE_DATA$HD°C "
            COUNT=$((COUNT+1))
        done
        echo -e "${STYLE_NORMAL}\n"
    fi

    # raid space left
    echo -e "${STYLE_TITLE}RAID usage${STYLE_NORMAL}"
    RAID_AVAIL=`df -h /dev/md0 | awk '!/Used/ {print $4}'`
    RAID_USAGE=`df -h /dev/md0 | awk '!/Used/ {print $5}'`
    echo -e "${STYLE_INFO}Available: ${STYLE_DATA}${RAID_AVAIL} ${STYLE_INFO}Used: ${STYLE_DATA}${RAID_USAGE}"
    echo -e "${STYLE_NORMAL}"
fi

# Is the internet on fire status reports
echo -e "${STYLE_TITLE}Is the internet on fire?${STYLE_NORMAL}${STYLE_HIGHLIGHT}"
host -t txt istheinternetonfire.com | cut -f 2 -d '"' | sed 's/^/ • /' | sed 's/\\\;/\n\n •/' | fmt
echo -e "${STYLE_NORMAL}"

echo -e "${STYLE_INFO}Press Enter to continue...${STYLE_NORMAL}"

