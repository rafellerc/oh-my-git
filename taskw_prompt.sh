# I Decided to make this prompt dependent on oh-my-git, to make things easier.
: ${taskw_taskw_symbol:=''} #       
: ${taskw_total_tasks_symbol:=''}   #       
: ${taskw_urgent_symbol:=''}   #  
: ${taskw_tomorrow_symbol:=''}
: ${taskw_today_symbol:=''}    #      
: ${taskw_project_symbol:=''}  #  
: ${taskw_overdue_symbol:=''}   # 
: ${taskw_non_scheduled_symbol:=''}    #   
: ${taskw_routines_symbol:=''}
# contexts   
# Done today   
# Geometric   


TASKW_URGENT_FILTER="+READY urgency.over:8 pro.not:routines"
TASKW_LAST_DATE=$(tail -1 ~/.oh-my-git/date_keeper.txt)
TASKW_DATE_GOAL=7
TASK='task'
alias taskl='task list'

source ~/.oh-my-git/routines.sh

function taskw_enrich_append {
        local flag=$1
        local symbol=$2
        local num=''
        local color=${3:-$omg_default_color_on}
        local number_color=${4:-$white_on_cyan}
        if [[ $flag == false ]] || [[ $flag == 0 ]]; then symbol=' '; fi
        if [[ $flag != true ]] && [[ $flag != false ]] && [[ $flag != 0 ]]; then num=${flag}; fi

        echo -n "${color}${symbol} ${number_color}${num} "
    }


function taskw_build_prompt {
    if [[ $TASKW_PROMPT_ACTIVE == true ]];
    then
        echo $(taskw_custom_build_prompt)
    fi
    }


function date_reset {
    TASKW_LAST_DATE=$(task calc now)
    echo $TASKW_LAST_DATE >> ~/.oh-my-git/date_keeper.txt
    }

function taskw_get_number_of_days {
    local duration=$(task calc now - $TASKW_LAST_DATE | grep -oP ".*(?=T)")
    local retvar=""
    # if [[ $duration == *'Y'* ]];
    # then
    #     retvar+="$(echo $duration | grep -oP "(\d{1,3})(?=(Y))")y"
    # fi
    # if [[ $duration == *'M'* ]];
    # then
    #     retvar+="$(echo $duration | grep -oP "(\d{1,3})(?=(M))")m"
    # fi
    if [[ $duration == *'D'* ]];
    then
        retvar+="$(echo $duration | grep -oP "(\d{1,3})(?=(D))")"
    else
        retvar+="0"
    fi
    echo $retvar
    }

function taskw_get_date_prompt {
        local date=$(taskw_get_number_of_days)
        local retvar""
        if [[ $date < $TASKW_DATE_GOAL ]];then
            retvar=" ${date}d"
        else
            retvar=" ${date}d"
        fi
        if [[ $date == 0 ]];then
            retvar=" ${date}d"
        fi
        echo $retvar
    }


function get_random_urgent_task {
    # The grep here assumes that the task "description" always follows immediately
    # after the "id" field
    local n_urgent_tasks=$($TASK $TASKW_URGENT_FILTER count)
    task $TASKW_URGENT_FILTER export | grep -oP "(?<=\"id\":)(\d{1,4},\"description\":\".*?)(?=(\",))" | grep -oP "(?<=\":\")(.*)" | sed -n $(shuf -i 1-${n_urgent_tasks} -n 1)p
    }

function taskw_custom_build_prompt {
    # Get TaskW info
    local total_ready_tasks=$($TASK +READY pro.not:routines count)
    # NOTE for some reason urgency.over:10 (or above) gives off everything over ~3
    local urgent_tasks=$($TASK ${TASKW_URGENT_FILTER} count)
    local due_tomorrow_tasks=$($TASK +READY +TOMORROW pro.not:routines count)
    local due_today_tasks=$($TASK +READY +TODAY pro.not:routines count)
    local overdue_tasks=$($TASK +READY +OVERDUE pro.not:routines count)
    local non_scheduled_tasks=$($TASK +READY due.none: pro.not:routines count)
    local routines=$($TASK +READY pro:routines count)

    local taskw_prompt=""
    # taskw_prompt+="${black_on_cyan}▓▒░"
    taskw_prompt+="${black_on_cyan} "
    taskw_prompt+=$(taskw_enrich_append true $taskw_taskw_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append true " " "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $total_ready_tasks $taskw_total_tasks_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $due_tomorrow_tasks $taskw_tomorrow_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $due_today_tasks $taskw_today_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $overdue_tasks $taskw_overdue_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $non_scheduled_tasks $taskw_non_scheduled_symbol "${black_on_cyan}")
    # taskw_prompt+=$(taskw_enrich_append $due_today_tasks $taskw_today_symbol "${red_on_white}")

    # Separate
    if [[ $urgent_tasks != 0 ]]; then
        taskw_prompt="${taskw_prompt} ${cyan_on_black}"
        taskw_prompt="${taskw_prompt} ${whites_on_black} "
        taskw_prompt+=$(taskw_enrich_append $urgent_tasks $taskw_urgent_symbol "${white_on_black}" "${white_on_black}")
        taskw_prompt="${taskw_prompt} ${black_on_cyan}"
        taskw_prompt+="${white_on_cyan} "
        taskw_prompt+=$(taskw_enrich_append true "$(get_random_urgent_task)" "${black_on_cyan}" "${black_on_cyan}")
        taskw_prompt="${taskw_prompt} ${cyan_on_black}"
    else
        taskw_prompt="${taskw_prompt} ${cyan_on_black}"
        # taskw_prompt="${taskw_prompt} ${cyan_on_black}▓▒░"
        # taskw_prompt="${taskw_prompt} ${cyan_on_black}█▇▆▅▄▃▂▁${reset}\n"
    fi
    if [[ $routines != 0 ]]; then
        # taskw_prompt="${taskw_prompt} ${cyan_on_black}"
        taskw_prompt="${taskw_prompt} ${whites_on_black} "
        taskw_prompt+=$(taskw_enrich_append $routines $taskw_routines_symbol "${white_on_black}" "${white_on_black}")
        taskw_prompt="${taskw_prompt} ${black_on_cyan}"
        taskw_prompt+="${white_on_cyan} "
        taskw_prompt+=$(taskw_enrich_append true "$(get_random_routine)" "${black_on_cyan}" "${black_on_cyan}")
        taskw_prompt="${taskw_prompt} ${cyan_on_black}"
    fi
    taskw_prompt="${taskw_prompt} ${black_on_cyan}"
    taskw_prompt="${taskw_prompt} ${black_on_cyan} "
    taskw_prompt+=$(taskw_enrich_append true "$(taskw_get_date_prompt)" "${black_on_cyan}")
    taskw_prompt="${taskw_prompt} ${cyan_on_black}"


    taskw_prompt="${taskw_prompt} ${reset}\n"

    echo "${taskw_prompt}"
}
