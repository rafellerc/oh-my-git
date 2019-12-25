# I Decided to make this prompt dependent on oh-my-git, to make things easier.
: ${taskw_taskw_symbol:=''} #       
: ${taskw_total_tasks_symbol:=''}   #       
: ${taskw_urgent_symbol:=''}   #  
: ${taskw_tomorrow_symbol:=''}
: ${taskw_today_symbol:=''}    #      
: ${taskw_project_symbol:=''}  #  
: ${taskw_overdue_symbol:=''}   # 
: ${taskw_non_scheduled_symbol:=''}    #   
# contexts   
# Done today   


function taskw_enrich_append {
        local flag=$1
        local symbol=$2
        local num=''
        local color=${3:-$omg_default_color_on}
        local number_color=${4:-$black_on_cyan}
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

function taskw_custom_build_prompt {
    TASK='task'
    # Get TaskW info
    local total_ready_tasks=$($TASK +READY count)
    # NOTE for some reason urgency.over:10 (or above) gives off everything over ~3
    local urgent_tasks=$($TASK +READY urgency.over:9.9 count)
    local due_tomorrow_tasks=$($TASK +READY +TOMORROW count)
    local due_today_tasks=$($TASK +READY +TODAY count)
    local overdue_tasks=$($TASK +READY +OVERDUE count)
    local non_scheduled_tasks=$($TASK +READY due.none: count)

    local taskw_prompt=""
    # taskw_prompt+="${black_on_cyan}▓▒░"
    taskw_prompt+="${black_on_cyan} "
    taskw_prompt+=$(taskw_enrich_append true $taskw_taskw_symbol "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append true " " "${black_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $total_ready_tasks $taskw_total_tasks_symbol "${white_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $urgent_tasks $taskw_urgent_symbol "${red_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $due_tomorrow_tasks $taskw_tomorrow_symbol "${white_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $due_today_tasks $taskw_today_symbol "${white_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $overdue_tasks $taskw_overdue_symbol "${white_on_cyan}")
    taskw_prompt+=$(taskw_enrich_append $non_scheduled_tasks $taskw_non_scheduled_symbol "${white_on_cyan}")
    # taskw_prompt+=$(taskw_enrich_append $due_today_tasks $taskw_today_symbol "${red_on_white}")

    # Separate
    # taskw_prompt="${taskw_prompt} ${cyan_on_purple}"
    # taskw_prompt+=$(taskw_enrich_append true " -- " "${black_on_purple}" "${black_on_purple}")

    taskw_prompt="${taskw_prompt} ${cyan_on_black}▓▒░${reset}\n"
    # taskw_prompt="${taskw_prompt} ${cyan_on_black}█▇▆▅▄▃▂▁${reset}\n"

    # No arrow
    # taskw_prompt="${taskw_prompt} ${reset}\n"

    echo "${taskw_prompt}"
}