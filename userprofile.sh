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

{
    while getopts s:l:i:o: flag
    do
        case "${flag}" in
            s) schuelerGroup=${OPTARG};;
            l) lehrerGroup=${OPTARG};;
            i) filename="${OPTARG}";;
            o) errorfile=${OPTARG};;
        esac
    done
} &> /dev/null

echo $schuelerGroup

touch $errorfile
while read line
do
    {
        IFS='|' read -ra ARR <<< "$line"
        withklassen=false
        if [ ${#ARR[@]} -lt 3 ]; then
            echo "Error: line '$line' does have less than 3 elements" >> $errorfile
            continue
        fi
        if [ ${#ARR[@]} -eq 4 ]; then
            withklassen=true
        fi
        accname="${ARR[0]}"
        name="${ARR[1]}"
        group="${ARR[2]}"
        class=""

        if [ $withklassen = true ]; then
            class="${ARR[3]}"
        fi

        if [ $group = "schueler" ]; then
            group="$schuelerGroup"
        elif [ $group = "lehrer" ]; then
            group="$lehrerGroup"
        else
            echo "Error: group '$group' for user '$name' is neither 'schueler' nor 'lehrer'" >> $errorfile
            errors=$(($errors+1))
            continue
        fi
        echo $group
        foundUsers[index++]=$accname
        getent group "$group" || groupadd $group
        homedir="/home/$group/$accname/"
	# create /home/$group
	ls "/home/$group/" &> /dev/null || mkdir "/home/$group"
        getent passwd "$user" || useradd -p $(openssl passwd -1 $password) -c "$name" -g $group -m -d $homedir $accname
        useradderr=$?
        # echo "getent passwd "$user" || useradd -p $(openssl passwd -1 $password) -c "$name" -g $group -m -d $homedir $accname" >> "test.txt"
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
        if [ $withklassen = true ] ; then 
            getent group "$class" || groupadd $class
	    ls "/home/klassen" &> /dev/null || mkdir "/home/klassen"
            if [ ! -d "/home/klassen/$class" ] ; then
                # echo "mkdir -r \"/home/klassen/$class/\"" >> "test.txt"
                mkdir "/home/klassen/$class/"
                chown -R ":$class" "/home/klassen/$class/"
                chmod -R 770 "/home/klassen/$class/"
            fi
            usermod -a -G $class $accname
        fi
        cp -RT "/home/default/$group" "$homedir"
        chown -R $accname $homedir
        chmod -R 700 $homedir
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
            dir=""
            gr=""
            if id -nG "$user" | grep -qw "$lehrerGroup"; then
                userdel "$user"
                gr="$lehrerGroup"
                dir="/home/$lehrerGroup/$user"
                bdir="/home/backup/$user-$gr"
                mkdir "$bdir"
                cp -RT "$dir/" "$bdir/"
                rm -drf "$dir"
                # echo "mv -r \"$dir/*\" \"$bdir/\"" > "test.txt"
                # rm -dr 
            elif id -nG "$user" | grep -qw "$schuelerGroup"; then
                userdel "$user"
                gr="$schuelerGroup"
                dir="/home/$schuelerGroup/$user"
                bdir="/home/backup/$user-$gr"
                mkdir "$bdir"
                cp -RT "$dir/" "$bdir/"
                rm -drf "$dir"
                # echo "mv -r \"$dir/*\" \"$bdir\"" >> "test.txt"
            fi
        } &> /dev/null
    fi
done

# priint if errors occurred for information
if [ $errors -ne 0 ]; then
    echo "Some Errors Occurred please check '$errorfile' for more information"
fi

# helpful
# https://www.baeldung.com/linux/csv-parsing
# https://stackoverflow.com/questions/10586153/how-to-split-a-string-into-an-array-in-bash
# https://stackoverflow.com/questions/14810684/check-whether-a-user-exists
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
