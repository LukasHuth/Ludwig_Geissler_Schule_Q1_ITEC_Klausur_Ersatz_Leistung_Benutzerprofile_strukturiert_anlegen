USERPROFILE

NAME
    
    userprofile - Erstellt Benutzer aus einer Datei und löscht Benutzer, die sich nicht mehr in der Datei befinden

SYNOPSIS
    
    userprofile.sh [OPTIONEN]...

BESCHREIBUNG
    
    Erstellt Benutzer von einer Datei und weist ihnen die Gruppe "lehrer" oder "schueler" zugewiesen.

    Benutzer der Gruppen "lehrer" und "schueler" die nicht mehr in der Datei gelistet sind, werden gelöscht und ihre home (~) Ordner werden in /home/backup/<benutzername>-<gruppe> verschoben.

    Außerdem werden nicht existierende Gruppen automatisch erstellt

    Das standart Benutzer vormat in der Datei lautet:

    <benutzername>|<Vor- und Nachname>|<schueler oder lehrer>

    wenn ein Benutzer in eine Klasse hinzugefügt werden soll, und ein passendes Tauschordner verzeichniss bei /home/klassen/<klasse> angelegt werden soll, verwenden sie dieses Format:

    <benutzername>|<Vor- und Nachname>|<schueler oder lehrer>|<klasse>

    Dies sind die Argument optionen, die das Program bietet:

    -i DATEI    Ändert die Datei aus der die Benutzer ausgelesen werden (Standart: people.file)

    -o DATEI    Ändert die Datei in die die Fehler ausgegeben werden (Standart: errors.txt)

    -l WORT     Ändert den namen der Gruppe den die Benutzer der Gruppe "lehrer" zugewiesen bekommen

    -s WORT     Ändert den namen der Gruppe den die Benutzer der Gruppe "schueler" zugewiesen bekommen