#################################################################################################
# Name			: 	PSVLCTheme.ps1
# Description	: 	
# Author		: 	Axel Anderson
# License		:	
# Date			: 	18.09.2016 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Set-StrictMode -Version Latest	
# Change: 
#			0.1.0		18.09.2016	Create...
#
#################################################################################################
#
# Globals
#
$script:ThemeStandard	= "Standard"
$script:ThemeDark 		= "Dark"

$script:ThemeElement_Player = "Player"
$script:ThemeElement_PlayerPictureButton = "PlayerPictureButton"
$script:ThemeElement_PlayerDisplay = "PlayerDisplay"
$script:ThemeElement_PlayerDisplayMarquee = "PlayerDisplayMarquee"

$script:ThemeElement_FileExplorer = "FileExplorer"
$script:ThemeElement_FileExplorerBottom = "FileExplorer_Bottom"

$script:ThemeElement_Playlist = "Playlist"
$script:ThemeElement_PlaylistBottom = "Playlist_Bottom"
$script:ThemeElement_PlaylistCurrent = "Playlist_Current"

$script:ThemeElement_NetworkStreamsManager = "NetworkStreamsManager"
$script:ThemeElement_NetworkStreamsManagerBottom = "NetworkStreamsManagerBottom"

$script:ThemeElement_ConnectionManager = "ConnectionManager"
$script:ThemeElement_ConnectionManagerButtonPanel = "ConnectionManagerButtonPanel"

$script:VLVRemoteCurrentTheme	= $script:ThemeStandard

$script:Colors = @{}
$script:Colors.Add($script:ThemeStandard,	(@{
											   $script:ThemeElement_Player				=	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::CornSilk;});
											   $script:ThemeElement_PlayerPictureButton	=	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::Transparent;});
											   $script:ThemeElement_PlayerDisplay		=	(@{	Fore=[System.Drawing.Color]::Blue;
																								Back=[System.Drawing.Color]::Transparent;});
											   $script:ThemeElement_PlayerDisplayMarquee=	(@{	Fore=[System.Drawing.Color]::Blue;
																								Back=[System.Drawing.Color]::CornSilk;});
											   $script:ThemeElement_FileExplorer		=	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::CornSilk;});
											   $script:ThemeElement_FileExplorerBottom	= 	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::Wheat;});											
											   $script:ThemeElement_Playlist			= 	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::CornSilk;});											
											   $script:ThemeElement_PlaylistBottom		= 	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::Wheat;});											
											   $script:ThemeElement_PlaylistCurrent		= 	(@{	Fore=[System.Drawing.Color]::Blue;
																								Back=[System.Drawing.Color]::CornSilk;});											
											   $script:ThemeElement_NetworkStreamsManager= 	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::CornSilk;});											
											   $script:ThemeElement_NetworkStreamsManagerBottom= 	(@{	Fore=[System.Drawing.Color]::Black;
																										Back=[System.Drawing.Color]::Wheat;});											
											   $script:ThemeElement_ConnectionManager			= 	(@{	Fore=[System.Drawing.Color]::Black;
																										Back=[System.Drawing.Color]::CornSilk;});											
											   $script:ThemeElement_ConnectionManagerButtonPanel= 	(@{	Fore=[System.Drawing.Color]::Black;
																										Back=[System.Drawing.Color]::FromArgb(255,245,245,220);});											
											}))

$script:Colors.Add($script:ThemeDark,		(@{
											   $script:ThemeElement_Player				=	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::Black;});
											   $script:ThemeElement_PlayerPictureButton	=	(@{	Fore=[System.Drawing.Color]::Black;
																								Back=[System.Drawing.Color]::White;});
											   $script:ThemeElement_PlayerDisplay		=	(@{	Fore=[System.Drawing.Color]::Yellow;
																								Back=[System.Drawing.Color]::Black;});
											   $script:ThemeElement_PlayerDisplayMarquee=	(@{	Fore=[System.Drawing.Color]::Yellow;
																								Back=[System.Drawing.Color]::Black;});
											   $script:ThemeElement_FileExplorer		=	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::Black;});
											   $script:ThemeElement_FileExplorerBottom 	=	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::DarkGray;});	
											   $script:ThemeElement_Playlist			=	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::Black;});
											   $script:ThemeElement_PlaylistBottom 		=	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::DarkGray;});																									
											   $script:ThemeElement_PlaylistCurrent		= 	(@{	Fore=[System.Drawing.Color]::Yellow;
																								Back=[System.Drawing.Color]::Black;});											
											   $script:ThemeElement_NetworkStreamsManager= 	(@{	Fore=[System.Drawing.Color]::White;
																								Back=[System.Drawing.Color]::Black;});											
											   $script:ThemeElement_NetworkStreamsManagerBottom= 	(@{	Fore=[System.Drawing.Color]::White;
																										Back=[System.Drawing.Color]::DarkGray;});											
											   $script:ThemeElement_ConnectionManager			= 	(@{	Fore=[System.Drawing.Color]::White;
																										Back=[System.Drawing.Color]::Black;});											
											   $script:ThemeElement_ConnectionManagerButtonPanel= 	(@{	Fore=[System.Drawing.Color]::White;
																										Back=[System.Drawing.Color]::DarkGray;});											
											}))

#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-VLCRemoteTheme {
[CmdletBinding()]
Param	(	
			[string]$Theme
		)

	if ($Theme -eq $script:ThemeStandard) {
		$script:VLVRemoteCurrentTheme	= $script:ThemeStandard
	} elseif ($Theme -eq $script:ThemeDark) {
		$script:VLVRemoteCurrentTheme	= $script:ThemeDark
	} else {
		$script:VLVRemoteCurrentTheme	= $script:ThemeStandard
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemoteThemeBackground {
[CmdletBinding()]
Param	(	
			[string]$Element
		)

	$BackColor = $script:Colors[$script:VLVRemoteCurrentTheme][$Element].Back

	Write-Output $BackColor
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemoteThemeForeground {
[CmdletBinding()]
Param	(	
			[string]$Element
		)
	
	$ForeColor = $script:Colors[$script:VLVRemoteCurrentTheme][$Element].Fore

	Write-Output $ForeColor
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
