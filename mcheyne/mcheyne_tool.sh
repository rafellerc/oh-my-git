# TODO implement logic for all 4 columns

MCHEYNE_BOOKMARK="/home/rafael/.oh-my-git/mcheyne/bookmark.txt"
MCHEYNE_CURRENT_LINE=$(tail -1 $MCHEYNE_BOOKMARK)
MCHEYNE_READINGS_FILE="/home/rafael/.oh-my-git/mcheyne/mcheyne.txt"

function mcheyne_get_current_reading {
    # Get nth line; Get the 2nd text between semicolons and remove whitespace
    sed "${MCHEYNE_CURRENT_LINE}q;d" $MCHEYNE_READINGS_FILE | cut -d ';' -f2 | sed 's/ //'
    }

# TODO add line limitation
function mcheyne_update_bookmark {
    expr $MCHEYNE_CURRENT_LINE + 1 >> MCHEYNE_BOOKMARK
    }