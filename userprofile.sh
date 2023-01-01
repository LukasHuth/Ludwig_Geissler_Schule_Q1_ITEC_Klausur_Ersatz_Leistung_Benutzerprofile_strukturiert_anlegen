#!/bin/bash
filename="people.file"
password="password"
errorfile="errors.txt"
rm $errorfile
errors=0
#read lines

foundUsers=()
foundUsersIndex=0

users=$(cut -d: -f1 /etc/passwd)
IFS=' ' read -ra userarr <<< $users
schuelerGroup="schueler"
lehrerGroup="lehrer"
# TODO: set to true if option -a is provided

everythingEvenIfUserExist=false
{
    while getopts s:l:i:o:a flag
    do
        case "${flag}" in
            s) schuelerGroup=${OPTARG};;
            l) lehrerGroup=${OPTARG};;
            i) filename="${OPTARG}";;
            o) errorfile=${OPTARG};;
            a) everythingEvenIfUserExist=true
        esac
    done
} &> /dev/null

echo $schuelerGroup

touch $errorfile
while read line
do
    {
        IFS='|' read -ra ARR <<< "$line"
        accname="${ARR[0]}"
        name="${ARR[1]}"
        group="${ARR[2]}"
        if [ $group = "schueler" ]; then
            group="$schuelerGroup"
        elif [ $group = "lehrer" ]; then
            group="$lehrerGroup"
        else
            echo "Error: group '$group' for user '$name' is neither 'schueler' nor 'lehrer'" >> $errorfile
            continue
        fi
        echo $group
        foundUsers[index++]=$accname
        getent group $group || groupadd $group
        getent passwd $user  > /dev/null
        if [ $? -eq 0 ] && [ $everythingEvenIfUserExist = false ]; then
            echo "User exists"
        else
            useradd -p $(openssl passwd -1 $password) -g $group $accname
            useradderr=$?
            if [ $useradderr -ne 0 ]; then
                extra=""
                if [ $useradderr -eq 1 ]; then
                    extra="Could not update password file"
                elif [ $useradderr -eq 4 ]; then
                    extra="UID already in use"
                elif [ $useradderr -eq 6 ]; then
                    extra="Group Not Found"
                elif [ $useradderr -eq 9 ]; then
                    extra="Username already in use"
                elif [ $useradderr -eq 10]; then
                    extra="Could not update group file"
                fi
                echo "Error: did not create user $accname for $group $name ($extra)" >> $errorfile
                errors=$(($errors+1))
                continue
            fi
            # passwd -e $accname
            passwderr=$?
            if [ $passwderr -ne 0 ]; then
                {
                    if [ $passwderr -eq 3 ]; then
                        echo "Error: passwd unexpected failure endet with exit code 3 (nothing done) please rerun the code with the option -a"
                    elif [ $passwderr -eq 4 ]; then
                        echo "Error: passwd unexpected failure endet with exit code 4 (passwd file missing) please rerun the code with the option -a"
                    elif [ $passwderr -eq 5 ]; then
                        echo "Error: passwd file busy try again with option -a"
                    fi
                } >> $errorfile
            fi
            homedir="/home/$group/$accname/"
            mkdir -p $homedir
            chown -R $accname: $homedir
            cp "/home/default/$group/.bash_profile" "$homedir"
            cp "/home/default/$group/.bashrc" "$homedir"
            touch "$homedir.bash_logout"
            chown -R $accname: "$homedir.bash_profile"
            chown -R $accname: "$homedir.bashrc"
            chown -R $accname: "$homedir.bash_logout"
            usermod -d $homedir $accname
        fi
    } &> /dev/null
done < $filename

#remove users that are not in the list and do have the schueler or lehrer group
for user in ${users[@]}; do
    found=false
    for fuser in ${foundUsers[@]}; do
        if [ $fuser = $user ]; then
            found=true
        fi
    done
    if [ $found = false ]; then
        {
            if id -nG "$user" | grep -qw "$lehrerGroup"; then
                userdel "$user"
                rm -dr "/home/$lehrerGroup/$user"
            elif id -nG "$user" | grep -qw "$schuelerGroup"; then
                userdel "$user"
                rm -dr "/home/$schuelerGroup/$user"
            fi
        } &> /dev/null
    fi
done

# priint if errors occurred for information
if [ $errors -ne 0 ]; then
    echo "Some Errors Occurred please check '$errorfile' for more information"
fi

# helpful
# https://melvingeorge.me/blog/change-home-directory-of-user-account-linux
# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
# https://stackoverflow.com/questions/2150882/how-to-automatically-add-user-account-and-password-with-a-bash-script#comment32552129_2328528
# https://www.baeldung.com/linux/csv-parsing
# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
# https://www.cyberciti.biz/faq/howto-change-rename-user-name-id/#:~:text=How%20do%20I%20change%20or,text%20editor%20such%20as%20vi.
# https://melvingeorge.me/blog/change-home-directory-of-user-account-linux
# https://linuxhint.com/give-user-folder-permission-linux/
# https://unix.stackexchange.com/questions/145348/short-simple-command-to-create-a-group-if-it-doesnt-already-exist
# https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-directory-does-not-already-exist
# https://askubuntu.com/questions/6723/change-folder-permissions-and-ownership
# https://www.computernetworkingnotes.com/linux-tutorials/linux-user-profile-management-and-environment-variable.html
# https://stackoverflow.com/questions/26289176/bash-bash-profile-no-such-file-or-directory
# https://www.cyberciti.biz/faq/linux-set-change-password-how-to/
# https://stackoverflow.com/questions/2150882/how-to-automatically-add-user-account-and-password-with-a-bash-script
# https://www.freecodecamp.org/news/linux-how-to-add-users-and-create-users-with-useradd/
# https://stackoverflow.com/questions/2150882/how-to-automatically-add-user-account-and-password-with-a-bash-script#comment32552129_2328528
# https://de.godaddy.com/help/einen-linux-nutzer-hinzufugen-19158
# https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement
# https://linuxtect.com/linux-bash-not-equal-ne-operators-tutorial/
# https://linuxhint.com/bash_if_else_examples/
# https://linuxize.com/post/how-to-list-users-in-linux/
# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
# https://www.freecodecamp.org/news/bash-array-how-to-declare-an-array-of-strings-in-a-bash-script/
# https://stackoverflow.com/questions/10586153/how-to-split-a-string-into-an-array-in-bash
# https://stackoverflow.com/questions/2953646/how-can-i-declare-and-use-boolean-variables-in-a-shell-script
# https://stackoverflow.com/questions/18431285/check-if-a-user-is-in-a-group
# https://stackoverflow.com/questions/18062778/how-to-hide-command-output-in-bash
# https://stackoverflow.com/questions/14810684/check-whether-a-user-exists
# https://linuxize.com/post/bash-break-continue/
# https://stackoverflow.com/questions/17049564/command-usr-sbin-chown-failed-with-exit-code-1
# https://unix.stackexchange.com/questions/47584/in-a-bash-script-using-the-conditional-or-in-an-if-statement
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
# https://stackoverflow.com/questions/24705637/linux-gnu-getopt-ignore-unknown-optional-arguments
# https://stackoverflow.com/questions/34480877/how-to-use-getopts-option-without-argument-at-the-end-in-bash
# https://linuxize.com/post/how-to-list-users-in-linux/
# https://linuxize.com/post/bash-increment-decrement-variable/