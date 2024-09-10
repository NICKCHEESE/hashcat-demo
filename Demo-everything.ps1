Clear-Host

Write-Host "Enter a password using any combination of characters you want"
Write-Host "Uppercase / Lowercase letters, Numbers, Special Characters are allowed"

$pwd_string = Read-Host -Prompt "8 characters max!" -AsSecureString

$Pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd_string))

$PassLength = $Pass.length

If ( $PassLength -gt 8 ){
	Write-Output ""
	Write-Host "Cheating detected!" -Fore Red
	Write-Host "Quitting!" -Fore Red
	exit
}

$Chars = ""

While ( $PassLength -gt 0 ){
	$Chars = $Chars + "?a"
	$PassLength --
}

Write-Output ""
Write-Host "Calculating hash..." -Fore Green

$PassHash = [IO.MemoryStream]::new([byte[]][char[]]$Pass)

$Hash = Get-FileHash -InputStream $PassHash -Algorithm MD5 | Foreach { $_.Hash } 

$Hash | Out-File ./Everything.hash -Force -Encoding UTF8

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
	
	.\hashcat.exe -m 0 "..\Everything.hash" -a 3 $Chars -o "..\Cracked.txt" --potfile-disable
	
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
