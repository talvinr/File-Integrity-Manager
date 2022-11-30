

Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new baseline?"
Write-Host "B) Begin monitoring files with saved baseline?"

$response = Read-Host -Prompt "Please enter A or B"

Function Calculate-File-Hash($filepath) {
    
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash

}


Function Erase-Baseline-If-Already-Exists() {

    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists) {

        # Delete it
        Remove-Item -Path .\baseline.txt

    }

}

if ($response -eq "A".ToUpper()) {
   
    #Delete baseline.txt if it exists
    Erase-Baseline-If-Already-Exists
   
    # Calculate Hash from the target files and store in baseline.txt

    # Calculate all files in target folder
    $files = Get-ChildItem -Path .\Files
    $files

    # Calculate hash for each file and write to baseline.txt
    foreach ($f in $files) {
        
      $hash = Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append


    }
    

}
elseif ($response -eq "B".ToUpper()) {
   
    #Load file:hash from baseline.txt and store in dictionary
    $fileHashDictionary = @{}

    $filePathsAndHashes = Get-Content -Path .\baseline.txt
    
    foreach ($f in $filePathsAndHashes) {

       $fileHashDictionary.add($f.Split("|")[0],($f.Split("|")[1]))
    }

    
    #Start monitoring files with saved Baseline
    while ($true) {
        
        Start-Sleep -Seconds 1
        
        $files = Get-ChildItem -Path .\Files


        foreach ($key in $fileHashDictionary.Keys) {
           $baselineFileStillExists = Test-Path -Path $key
           if (-Not $baselineFileStillExists) {
               #One of the baseline files must have been deleted, notify user
               Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed

            }

        }
   

        # Calculate hash for each file and write to baseline.txt
        foreach ($f in $files) {
        
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append


            #Notify if a new file has been created
            if ( $fileHashDictionary[$hash.Path] -eq $null) {

                #A file has been created
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green

            }
            else{



                #Notify if a new file has been changed
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    #The file has not changed

            
            }
            else {
                #the file has been compromised, notify user
                Write-Host "$($hash.Path) has been changed!" -ForegroundColor Yellow
            }

        }

      

    }
    
}
   
   
    #Start monitoring files with saved Baseline
    Write-Host "Read baseline.txt, start monitoring files" -ForegroundColor Green

}
