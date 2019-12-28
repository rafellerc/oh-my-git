source ~/.oh-my-git/mcheyne/mcheyne_tool.sh

# Routine Symbols
: ${taskw_routine_icon_swim:='🏊'}   # 🏊
: ${taskw_routine_icon_read:='📕'}     # 📕
: ${taskw_routine_icon_devotional:='📖'}    # 📖
: ${taskw_routine_icon_bike:='🚴'}    #🚴 
: ${taskw_routine_icon_gym:='🏋'}    # 💪 🏋
: ${taskw_routine_icon_wake_up_early:='🛌'}    # 🛌


# TODO use wait as well to hide items until the due date?
function taskw_routine_add_swim {
    task add $taskw_routine_icon_swim Swim pro:routines.exercise.swim due:$1 until:$1
}
# Add number of minutes to read as argument
function taskw_routine_add_read {
    task add $taskw_routine_icon_read Read $2 pro:routines.reading due:$1 until:$1
}
# Add reading text
function taskw_routine_add_devotional {
    task add $taskw_routine_icon_devotional Devotional - $(mcheyne_get_current_reading) $2 pro:routines.devotional due:$1 until:$1
}
function taskw_routine_add_bike {
    task add $taskw_routine_icon_bike Bike pro:routines.exercise.bike due:$1 until:$1
}
function taskw_routine_add_gym {
    task add $taskw_routine_icon_bike Bike pro:routines.exercise.gym due:$1 until:$1
}
# Add time as argument
function taskw_routine_add_wake {
    task add $taskw_routine_icon_wake_up_early Wake up early $2 pro:routines due:$1 until:$1
}


# Weekday Routines
function taskw_add_monday_routines {
    taskw_routine_add_wake $1 7:00
    taskw_routine_add_devotional $1
    taskw_routine_add_read $1 30min
    taskw_routine_add_gym $1
    }

function taskw_add_tuesday_routines {
    taskw_routine_add_wake $1 7:00
    taskw_routine_add_devotional $1
    taskw_routine_add_read $1 30min
    taskw_routine_add_swim $1
    }

function taskw_add_wednesday_routines {
    taskw_routine_add_wake $1 7:00
    taskw_routine_add_devotional $1
    taskw_routine_add_read $1 30min
    taskw_routine_add_gym $1
    }

function taskw_add_thursday_routines {
    taskw_routine_add_wake $1 7:00
    taskw_routine_add_devotional $1
    taskw_routine_add_read $1 30min
    taskw_routine_add_swim $1
    }

function taskw_add_friday_routines {
    taskw_routine_add_wake $1 7:00
    taskw_routine_add_devotional $1
    taskw_routine_add_read $1 30min
    taskw_routine_add_swim $1
    }

function taskw_add_saturday_routines {
    taskw_routine_add_wake $1 8:00
    taskw_routine_add_read $1 1hour
    }

function taskw_add_sunday_routines {
    echo "No routines planned"
    }


function routines {
    local target_day=$1
    if [[ -z "$target_day" ]];then
        target_day="eod"
    fi

    case $(date -d $(task calc ${target_day}) +%a) in
        "Mon") taskw_add_monday_routines ${target_day};;
        "Tue") taskw_add_tuesday_routines ${target_day};;
        "Wed") taskw_add_wednesday_routines ${target_day};;
        "Thu") taskw_add_thursday_routines ${target_day};;
        "Fri") taskw_add_friday_routines ${target_day};;
        "Sat") taskw_add_saturday_routines ${target_day};;
        "Sun") taskw_add_saturday_routines ${target_day};;
        *) echo "ERROR: '${weekday}'' is not a valid weekday";;
    esac
}

function get_random_routine {
    local routines=$(task +READY pro:routines count)
    task +READY pro:routines export | grep -oP "(?<=\"id\":)(\d{1,4},\"description\":\".*?)(?=(\",))" | grep -oP "(?<=\":\")(.*)" | sed -n $(shuf -i 1-${routines} -n 1)p
    }