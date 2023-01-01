USERPROFILE

NAME
    
    userprofile - create users from an file and remove unlisted users

SYNOPSIS
    
    userprofile.sh [OPTION]...

DESCRIPTION
    
    Creates Users from a file and allocates the group "lehrer" and "schueler"
    
    Users of the groups "lehrer" or "schueler" that are not listed anymore

    get deleted, already existing users will be ignored. Also not existing

    groups that will be used will be created.

    -a          Execute the script on every given user even the already existing ones

    -i FILE     Change user list lookup file (Default: people.file)

    -o FILE     Change the error output file (Default: errors.txt)

    -l WORD     Change the group name for users of the group "lehrer" (Only appliers to users that will be created)

    -l WORD     Change the group name for users of the group "schueler" (Only appliers to users that will be created)