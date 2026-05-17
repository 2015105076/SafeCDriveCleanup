[Version]
Class=IEXPRESS
SEDVersion=3

[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=Safe C Drive Cleanup installer has finished.
TargetName=dist\SafeCDriveCleanupInstaller.exe
FriendlyName=Safe C Drive Cleanup Installer
AppLaunched=Install-SafeCDriveCleanup.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles

[Strings]
FILE0=SafeCDriveCleanup.ps1
FILE1=Install-SafeCDriveCleanup.cmd

[SourceFiles]
SourceFiles0=.

[SourceFiles0]
%FILE0%=
%FILE1%=
