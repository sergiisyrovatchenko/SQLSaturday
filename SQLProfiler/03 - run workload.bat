"C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -SHOMEPC\SQL_2016 -E -q -N -n1 -r1 -Q"DBCC FREEPROCCACHE;DBCC DROPCLEANBUFFERS;"

".\SQLInjection\SQLInjection1.exe" 1

".\ConvertImplicit\ConvertImplicit1.exe" "Berlin"

"C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -SHOMEPC\SQL_2016 -dAdventureWorks2014 -E -q -N -n1 -r1 -i".\02 - workload.sql"

".\Compilations\Compilations.exe"

"C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -SHOMEPC\SQL_2016 -dUsers -E -q -N -n1 -r1000 -Q"EXEC dbo.GetLastUsers 1"

".\ConvertImplicit\ConvertImplicit1.exe" "Odessa"
".\ConvertImplicit\ConvertImplicit1.exe" "Kharkiv"