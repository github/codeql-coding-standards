. "$PSScriptRoot/Config.ps1"
function Create-Summary-Report {
    param([Parameter(Mandatory)] 
        [string]
        $DataFile,
        [Parameter(Mandatory)] 
        [string]
        $OutputFile
    )

    $csv = $DataFile
    $firstRowColumnNames = "Yes"

    $provider = (New-Object System.Data.OleDb.OleDbEnumerator).GetElements() | Where-Object { $_.SOURCES_NAME -like "Microsoft.ACE.OLEDB.*" } 

    if ($provider -is [system.array]) { 
        $provider = $provider[0].SOURCES_NAME 
    }
    else {  
        $provider = $provider.SOURCES_NAME 
    }

    $connstring = "Provider=$provider;Data Source=$(Split-Path $csv);Extended Properties='text;HDR=$firstRowColumnNames;';"

    $tablename = (Split-Path $csv -leaf).Replace(".", "#")

    $sql = $REPORT_QUERY -f $tablename

    $conn = New-Object System.Data.OleDb.OleDbconnection
    $conn.ConnectionString = $connstring
    $conn.Open()
    $cmd = New-Object System.Data.OleDB.OleDBCommand
    $cmd.Connection = $conn
    $cmd.CommandText = $sql

    $dt = New-Object System.Data.DataTable
    $dt.Load($cmd.ExecuteReader("CloseConnection"))

    $cmd.dispose | Out-Null; $conn.dispose | Out-Null

    $dt | Export-CSV $OutputFile -NoTypeInformation
}