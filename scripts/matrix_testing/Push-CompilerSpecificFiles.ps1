. "$PSScriptRoot/Config.ps1"
function Push-CompilerSpecificFiles {
    param([Parameter(Mandatory)] 
        [System.IO.FileSystemInfo[]]
        $FileSet,
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        $Language 
    )

    # for each file, move it to a temporary location
    foreach($f in $FileSet){
        # 
        # Convention is as follows:
        #
        # For test files:
        #
        # file.c/cpp is used for ALL compilers 
        # file.c.<configuration>/file.cpp.<configuration> is used for <configuration>
        #
        # file.expected is used for all compilers 
        # file.expected.<configuration> is used for <configuration> 

        $tmp = New-TemporaryFile

        #
        # Note -- it is not necessary for the file we are going to replace
        # to exist. If it DOES NOT exist, we simply delete the compiler specific
        # file afterwards. 

        # transform the compiler specific file to the generic one
        $originFilePath = $f.FullName.Replace(".$Configuration", "")

        # IF it exists, copy the originFile to a temp location and replace it 
        # with the specific file. 
        if(Test-Path $originFilePath){

            $originFile = Get-Item $originFilePath 

            Write-Host "Moving generic file $originFile to $tmp..."
            Move-Item -Force -Path $originFile -Destination $tmp 
            Write-Host "Copying $f to generic file $originFile"
            Copy-Item -Path $f -Destination $originFile 

            @{"origin"=$originFile; "temp"=$tmp;}
        }else{

            $originFile = New-Item $originFilePath

            Write-Host "Copying $f to generic file $originFile"
            Copy-Item -Path $f -Destination $originFile 

            #we set $temp to $null since we don't want to copy anything 
            # back 
            @{"origin"=$originFile; "temp"=$null;}
        }
    }
}