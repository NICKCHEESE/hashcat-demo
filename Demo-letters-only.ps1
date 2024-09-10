Clear-Host

$pwd_string = Read-Host -Prompt "Enter a password using only letters (upper and lower case)" -AsSecureString

$Pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd_string))

if ($Pass -notmatch "^[a-z]+$"){
	Write-Output ""
	Write-Host "Cheating detected!" -Fore Red
	Write-Host "Quitting!" -Fore Red
	exit
}


$PassLength = $Pass.length

$Chars = ""

While ( $PassLength -gt 0 ){
	$Chars = $Chars + "?1"
	$PassLength --
}

Write-Output ""
Write-Host "Calculating hash..." -Fore Green

$PassHash = [IO.MemoryStream]::new([byte[]][char[]]$Pass)

$Hash = Get-FileHash -InputStream $PassHash -Algorithm MD5 | Foreach { $_.Hash } 

$Hash | Out-File ./LettersPass.hash -Force -Encoding UTF8

Write-Output ""
Write-Host "Done!" -Fore Green

Write-Output ""
Write-Host "Password: REDACTED"
Write-Host "Password Hash: $Hash"

Write-Output ""
$Answer = Read-Host "Would you like to attempt cracking? (y/n)"

If ( $Answer -eq "y" -or $Answer -eq "Y" -or $Answer -like "yes" ){	

	Remove-Item .\Cracked.txt -Force -ErrorAction SilentlyContinue
 	
	cd "hashcat-6.2.6"
	
	.\hashcat.exe -m 0 "..\LettersPass.hash" -a 3 -1?l?u $Chars -o "..\Cracked.txt" --potfile-disable
	
	cd ..
	
	$Cracked = Get-Content .\Cracked.txt
	$Cracked = $Cracked.split(':')[1]
	
	Write-output ""
	Write-Host "The password you entered was: $Cracked" -Fore Green
	
}

Else {
	Write-Output ""
	Write-Host "Quitting!" -Fore Yellow
	exit
}
