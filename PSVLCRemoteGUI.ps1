#################################################################################################
# Name			: 	PSVLCRemoteGUI.ps1
# Description	: 	
# Author		: 	Axel Pokrandt (-XP)
# License		:	
# Date			: 	16.11.2015 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Set-StrictMode -Version Latest	
# Change: 
#			0.1.0		16.11.2015	First Version ...
#
#################################################################################################
#
# Globals
#
#region LoadAssemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

Add-Type –assemblyName WindowsBase -IgnoreWarnings
#endregion LoadAssemblies
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#region SCRIPT VARIABLES
	$script:LastPlaylistID = "-1"
	$script:IsMuting = $false
	$script:LastVolumeLevel = 0

	$script:RefreshCounterFailure = 0
	$script:RefreshCounterStatus = 0		# 0 = OK, 1 = FailureIntervall, 2 = FailureStop
	$script:RefreshTimerIntervalSeconds = 1
	
	$script:RefreshTimerIntervalFailureSeconds = 5
	$script:RefreshFailureCounter = 10
	$script:RefreshFailureCountStop = 60
	$script:RefreshTimerIntervalFailureStopSeconds = 120
	
	$script:tmrTick = New-Object System.Windows.Threading.DispatcherTimer 
	$script:tmrTick.Stop()
	$script:tmrTick.IsEnabled = $false
	$script:tmrTick.Interval = [System.TimeSpan]::FromSeconds($script:RefreshTimerIntervalSeconds)
	
	$Script:CurrentStatus = $null
	
	$script:CommonVLCRemoteController = $null
	
	$Script:NotifyIcon			= New-Object System.Windows.Forms.NotifyIcon
		$Script:NIContextMenu		= New-Object System.Windows.Forms.ContextMenu
			$Script:NIMenuItemShowHideMain	= New-Object System.Windows.Forms.MenuItem
			$Script:NIMenuItemToFront		= New-Object System.Windows.Forms.MenuItem
			$Script:NIMenuItemExit			= New-Object System.Windows.Forms.MenuItem
	
	$script:formMainDialog = $null
	
	$Script:playRateSettings = 	@(
	
									"0.0",
									"0.03125",				# Small
									"0.0625",
									"0.10000000149012",		# Small
									"0.125",
									"0.20000000298023",		# Small
									"0.25",
									"0.30002999305725",		# Small
									"0.33333334326744",
									"0.40000000596046",		# Small
									"0.5",					# Big and Small
									"0.60024011135101",		# Small
									"0.66666668653488",
									"0.70028012990952",		# Small
									"0.80000001192093",		# Small
									"0.9000900387764",		# Small
									"1.0",
									"1.1001100540161",		# Small
									"1.200480222702",		# Small
									"1.300390124321",		# Small
									"1.400560259819",		# Small
									"1.5015015602112",		# Big and Small
									"1.6000000238419",		# Small
									"1.7006802558899",		# Small
									"1.8018018007278",		# Small
									"1.9011406898499",		# Small
									"2.0",
									"2.1008403301239",		# Small
									"2.2026431560516",		# Small
									"2.3041474819183",		# Small
									"2.4038462638855",		# Small
									"2.5",					# Small
									"2.6041667461395",		# Small
									"2.7027027606964",		# Small
									"2.8011205196381",		# Small
									"2.9069766998291",		# Small
									"3.0030031204224",		# Big and Small
									"4.0",
									"8.0",
									"16.12903213501",
									"31.25",
									"64.0"
								)
	$script:aspectRatioSettings = @(
									"default",
									"1:1" ,
									"4:3" ,
									"5:4" ,
									"16:9" ,
									"16:10" ,
									"221:100" ,
									"235:100" , 
									"239:100"
									)
#endregion SCRIPT VARIABLES


#
#################################################################################################
#
Function  Set-VLCRemoteWindowText  {
[CmdletBinding()]
Param	()

	$Script:NotifyIcon.Text = "$script:ScriptName $script:ScriptVersion`nConnected to $($script:CommonVLCRemoteController.HostnameOrIp)"
	
	$script:formMainDialog.Text = "$script:ScriptName : $($script:CommonVLCRemoteController.HostnameOrIp)"
	
	if ($script:formMainFileExplorer -ne $null) {
		$script:formMainFileExplorer.Text = "$script:ScriptName : FileExplorer : $($script:CommonVLCRemoteController.HostnameOrIp)"
	}
	if ($script:formMainPlaylist -ne $null) {
		$script:formMainPlaylist.Text = "$script:ScriptName : Playlist : $($script:CommonVLCRemoteController.HostnameOrIp)"
	}
	if ($script:formMainNetworkStreamsManager -ne $null) {
		$script:formMainNetworkStreamsManager.Text = "$script:ScriptName : Network Streams Manager : !!! ---Experimental--- !!! : $($script:CommonVLCRemoteController.HostnameOrIp)"
	}	
}

Function Show-VLCRemoteMainForm {
[CmdletBinding()]
Param	(
			#[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
		
	Load-AllScriptSettingValues
	
	$Script:CurrentStatus = Get-VLCRemote-Status -VLCRemoteController $script:CommonVLCRemoteController

	# -------------------------------------------------------------------------------------------------------------------------
	Function Refresh-Dialog {
		$Script:CurrentStatus = Get-VLCRemote-Status -VLCRemoteController $script:CommonVLCRemoteController

		#$Script:CurrentStatus.Currentplid | out-host
		
		if ($Script:CurrentStatus -ne $null) {
			if ($script:RefreshCounterStatus -gt 0) {
				$script:RefreshCounterStatus = 0
				$script:tmrTick.Interval = [System.TimeSpan]::FromSeconds($script:RefreshTimerIntervalSeconds)
			}
		
			$script:RefreshCounterFailure = 0
		
			$picBoxAlive.Image = $script:ImageAliveGreen
		
			$TitleText = ""
			
			if ($Script:CurrentStatus.State -ieq "stopped") {
				$TitleText = "Now Playing"
			} else {
			   if ($Script:CurrentStatus.NowPlaying -ne "") {
					$TitleText = $Script:CurrentStatus.NowPlaying
					if ($Script:CurrentStatus.title -ne "") {
						$TitleText.Text += " ("+$Script:CurrentStatus.title+")"
					}
				} elseif ($Script:CurrentStatus.title -eq "") {
					$TitleText = $Script:CurrentStatus.filename
				} else {
					$TitleText = $Script:CurrentStatus.title 
					if ($Script:CurrentStatus.artist -ne "") {
						$TitleText += " - " + $Script:CurrentStatus.artist
					}
					if ($Script:CurrentStatus.album -ne "") {
						$TitleText += " - " + $Script:CurrentStatus.album
					}
				}
			}
			if ($script:UseMarqueeOnMainPlayer) {
				$script:MarqueeController = Set-MarqueeText -MC $script:MarqueeController -PicBox $script:picBoxTitle -Text $TitleText
			} else {
				$lblTitle.Text = $TitleText
			}

			$ts = [System.Timespan]::FromSeconds($Script:CurrentStatus.time)
			$lblPosCurrent.Text = $ts.ToString()
			
			$ts = [System.Timespan]::FromSeconds($Script:CurrentStatus.length)
			$lblPosEnd.Text = $ts.ToString()
			
			$trackPosition.Maximum = $Script:CurrentStatus.length
			$trackPosition.Value = [math]::min([math]::max(0,$Script:CurrentStatus.time),$trackPosition.Maximum)
			
			if ([int]$Script:CurrentStatus.length -gt 0) {
				$trackPosition.TickFrequency = ($Script:CurrentStatus.length / 20)
			} else {
				$trackPosition.TickFrequency = 5
			}
			
			if ($Script:CurrentStatus.State -ieq "playing") {
				$picBoxPlayPause.Image = $script:ImagePause
			} else {
				$picBoxPlayPause.Image = $script:ImagePlay
			}
			if ($Script:CurrentStatus.Fullscreen) {
				$picBoxScreen.Image = $script:ImageScreenNormal
			} else {
				$picBoxScreen.Image = $script:ImageScreenFull
			}
			if (!$script:IsMuting) {
				$Vol = [math]::min($Script:CurrentStatus.Volume,320)
				$trackVolume.Value = $Vol
				$script:LastVolumeLevel = $Vol
				$Percent = [int](($Vol/256)*100)
				$ToolTip.SetToolTip($trackVolume, "Lautstärke : $($Percent)%")
			} else {
				$Percent = [int](($script:LastVolumeLevel/256)*100)
				$ToolTip.SetToolTip($trackVolume, "Lautstärke : $($Percent)% (MUTING)")
			}
			
			if ($Script:CurrentStatus.Loop) {
				$picBoxLoop.Image = $script:ImageLoop	
			} else {
				$picBoxLoop.Image = $script:ImageNoLoop
			}
			if ($Script:CurrentStatus.Repeat) {
				$picBoxRepeat.Image = $script:ImageRepeat	
			} else {
				$picBoxRepeat.Image = $script:ImageNoRepeat
			}			
			if ($Script:CurrentStatus.Random) {
				$picBoxRandom.Image = $script:ImageRandom	
			} else {
				$picBoxRandom.Image = $script:ImageNoRandom
			}			
			if ($script:formMainPlaylist -ne $null) {
				foreach ($Item in $script:listViewPlaylist.Items) {
					$ID = $Item.Tag.Id
					if ($ID -eq $Script:CurrentStatus.Currentplid) {
						$Item.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_PlaylistCurrent
					} else {
						$Item.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Playlist
					}
				}
			}
			
		} else {
			$script:RefreshCounterFailure++
			if ($script:UseMarqueeOnMainPlayer) {
				$script:MarqueeController = Set-MarqueeText -MC $script:MarqueeController -PicBox $script:picBoxTitle -Text "Now Playing"
			} else {
				$lblTitle.Text = "Now Playing"
			}			
			
			$picBoxAlive.Image = $script:ImageAliveRed
			
			$trackPosition.Maximum = 100
			$trackPosition.Value = 0
			$trackPosition.TickFrequency = 5
			$lblPosCurrent.Text = "00:00:00"
			$lblPosEnd.Text = "00:00:00"	
			$trackVolume.Value = 0
			
			$ToolTip.SetToolTip($trackVolume, "Lautstärke : 0 %")
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if 		 ($script:RefreshCounterStatus -eq 0) {
			if ($script:RefreshCounterFailure -ge $script:RefreshFailureCounter) {
				$script:RefreshCounterStatus = 1
				$script:RefreshCounterFailure = 0
				$script:tmrTick.Interval = [System.TimeSpan]::FromSeconds($script:RefreshTimerIntervalFailureSeconds)
			}
		} elseif ($script:RefreshCounterStatus -eq 1) {
			if ($script:RefreshCounterFailure -ge $script:RefreshFailureCountStop) {
				$script:RefreshCounterStatus = 2
				$script:tmrTick.Interval = [System.TimeSpan]::FromSeconds($script:RefreshTimerIntervalFailureStopSeconds)
			}
		} elseif ($script:RefreshCounterStatus -eq 2) {
			#
			#
			#
		}

		#"{0} RefreshCounterStatus {1} RefreshCounterFailure: {2}" -f (Get-Date).ToString(), $script:RefreshCounterStatus, $script:RefreshCounterFailure | out-host
	}
	# -------------------------------------------------------------------------------------------------------------------------

	# -------------------------------------------------------------------------------------------------------------------------
	$script:formMainDialog			= New-Object System.Windows.Forms.Form	
		$tablePanelDialog = New-Object System.Windows.Forms.TableLayoutPanel
			$PanelDisplay = New-Object System.Windows.Forms.Panel
				if ($script:UseMarqueeOnMainPlayer) {
					$script:picBoxTitle	= New-Object System.Windows.Forms.PictureBox
				} else {
					$lblTitle 		= New-Object System.Windows.Forms.Label
				}
			$PanelPosition = New-Object System.Windows.Forms.Panel
				$lblPosCurrent	= New-Object System.Windows.Forms.Label
				$lblPosEnd		= New-Object System.Windows.Forms.Label
				$trackPosition  = New-Object System.Windows.Forms.TrackBar
			$PanelControl = New-Object System.Windows.Forms.Panel
				$picBoxPrevTrack = New-Object System.Windows.Forms.PictureBox
				$picBoxStop		 = New-Object System.Windows.Forms.PictureBox
				$picBoxPlayPause = New-Object System.Windows.Forms.PictureBox
				$picBoxNextTrack = New-Object System.Windows.Forms.PictureBox
				$picBoxScreen	 = New-Object System.Windows.Forms.PictureBox
				
				$picBoxLoop	 	 = New-Object System.Windows.Forms.PictureBox
				$picBoxRepeat	 = New-Object System.Windows.Forms.PictureBox
				$picBoxRandom	 = New-Object System.Windows.Forms.PictureBox
				
				$picBoxMute		 = New-Object System.Windows.Forms.PictureBox
				$trackVolume	 = New-Object System.Windows.Forms.TrackBar
			$PanelPlaylistControl = New-Object System.Windows.Forms.Panel
				$picBoxPlaylistSelect  = New-Object System.Windows.Forms.PictureBox
				$picBoxSelectFiles = New-Object System.Windows.Forms.PictureBox
				$picBoxNetworkStream = New-Object System.Windows.Forms.PictureBox
				$picBoxPlaySettings  = New-Object System.Windows.Forms.PictureBox
				$picBoxScriptSettings  = New-Object System.Windows.Forms.PictureBox
				$picBoxExit  = New-Object System.Windows.Forms.PictureBox
				$picBoxAlive  = New-Object System.Windows.Forms.PictureBox
				$picBoxTraydown  = New-Object System.Windows.Forms.PictureBox
				$picBoxHTTPLink  = New-Object System.Windows.Forms.PictureBox
				
	#$script:formMainDialog | fl * | out-host
	
	$ToolTip = New-Object System.Windows.Forms.ToolTip 
	$ToolTip.BackColor = [System.Drawing.Color]::LightGoldenrodYellow 
	$ToolTip.IsBalloon = $false 
	$ToolTip.InitialDelay = 500 
	$ToolTip.ReshowDelay = 500 
	
	#$formWidth   = 310
	$formWidth   = 350
	$formHeight  = 134
	$borderDist  = 5
	$OffsetMarquee	= 8
	
	$xPos = 3
	$yPos = 3
	$dist = 3
	$labelWidth = ($formWidth - (2*$borderDist))
	
	$labelHeight = 34
	$labelHeightSingle = 17
	$labelWidthMediatype = 55
	$labelWidthCodec = ($formWidth - (2*$borderDist)) - $labelWidthMediatype
	
	$picboxCOntrolWidth = 44
	$picboxCOntrolWidthSmall = 24
	
	$trackbarHeight = 32
	
	$labelPosWidth = 40
	$trackbarWidth = ($formWidth - (2*$borderDist) - (2*$labelPosWidth) -(2*$dist))
	
	$FontBig   = New-Object System.Drawing.Font("Segoe UI",10, [System.Drawing.FontStyle]::Bold)
	$FontSmall = New-Object System.Drawing.Font("Segoe UI",8, [System.Drawing.FontStyle]::Bold)
	$FontSmaller = New-Object System.Drawing.Font("Segoe UI",7, [System.Drawing.FontStyle]::Regular)
	
	# -------------------------------------------------------------------------------------------------------
	$tmpLabel = New-Object System.Windows.Forms.Label
	$g = $tmpLabel.CreateGraphics()
		
	$sf = $g.MeasureString("Axel Anderson",$FontSmall,$labelWidth)
	$lblTitleHeight = ([math]::round($sf.Height) * 3)
	$labelHeightSingle = [math]::round($sf.Height)
	
	if ($script:UseMarqueeOnMainPlayer) {
		$formHeight = ($labelHeightSingle+$OffsetMarquee+$Dist) + ($trackbarHeight+$dist) + (([math]::max($picboxCOntrolWidthSmall,$trackbarHeight)) +$dist) + ($picboxCOntrolWidthSmall+$dist)
	} else {
		$formHeight = ($lblTitleHeight+$Dist) + ($trackbarHeight+$dist) + (([math]::max($picboxCOntrolWidthSmall,$trackbarHeight)) +$dist) + ($picboxCOntrolWidthSmall+$dist)
	}

	# -------------------------------------------------------------------------------------------------------
	if ($script:UseMarqueeOnMainPlayer) {
		$script:picBoxTitle | % {
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.Size = New-Object System.Drawing.Size($labelWidth,($labelHeightSingle+$OffsetMarquee))
			$_.BackColor = [System.Drawing.Color]::Transparent
			$_.Margin = New-Object System.Windows.Forms.Padding (0)	
			$_.Image = $script:ImagePlay
			$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Normal
			#$_.BorderStyle = "FixedSingle"
			
			$script:MarqueeController = New-MarqueeController $script:picBoxTitle
			$script:MarqueeController = Set-MarqueeText -MC $script:MarqueeController -PicBox $script:picBoxTitle -Text "Now Playing"
		}
	} else {
		$lblTitle  | % {
			$_.Font = $fontSmall
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.Size = New-Object System.Drawing.Size($labelWidth, $lblTitleHeight)
			$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
			#$_.BackColor = [System.Drawing.Color]::Transparent
			#$_.ForeColor = [System.Drawing.Color]::Blue
		
			$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerDisplay
			$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_PlayerDisplay 
		
			$_.Margin = New-Object System.Windows.Forms.Padding (0)
			$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
			$_.Text = ""
		}
	}
	$panelDisplay | % {
		$_.Autosize = $True
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelTop"
		$_.TabStop = $false
		if ($script:UseMarqueeOnMainPlayer) {
			$_.Controls.Add($script:picBoxTitle)
		} else {
			$_.Controls.Add($lblTitle)
		}
	}
	$xPos = $borderDist
	$yPos = 0

	$lblPosCurrent  | % {
		
		$_.Font = $FontSmaller
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelPosWidth, $labelHeightSingle)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "0:00:00"
	}
	$xPos += ($labelPosWidth + $dist)
	$trackPosition  | % {
		$_.Font = $FontSmaller
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($trackbarWidth,$trackbarHeight)
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Player
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Player 
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.Orientation = "Horizontal"
		$_.TickFrequency = 5
		$_.TickStyle = "TopLeft"
		$_.Minimum = 0
		$_.Maximum = 100
		$_.SmallChange = 1
		$_.LargeChange = 10
		$_.Value = 0
	}
	$xPos += ($trackbarWidth + $dist)
	$lblPosEnd  | % {
		
		$_.Font = $FontSmaller
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelPosWidth, $labelHeightSingle)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "0:00:00"
	}

	$panelPosition | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		#$_.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
		#$_.BackColor = [System.Drawing.Color]::FromArgb(255,255,224,0)
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($lblPosCurrent)
		$_.Controls.Add($lblPosEnd)
		$_.Controls.Add($trackPosition)
		#$_.BorderStyle = "FixedSingle"
		$_.BorderStyle = "None"
	}
	$xPos = $borderDist
	$yPos = $Dist + 4
	$picBoxPlayPause | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
				
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImagePlay
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + 3*$borderDist)
	#$Ypos += (($picboxCOntrolWidth - $picboxCOntrolWidthSmall))
	$picBoxPrevTrack | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageStepback
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + $Dist)
	$picBoxStop | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageStop
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + $Dist)
	$picBoxNextTrack | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageStepforward
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + 3*$borderDist)
	$picBoxScreen | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageScreenNormal
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + $Dist)
	$picBoxLoop | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageNoLoop	
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + $Dist)
	$picBoxRepeat | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageNoRepeat	
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + $Dist)
	$picBoxRandom | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageNoRandom
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
		$_.BorderStyle = "FixedSingle"
	}
	$xPos += ($picboxCOntrolWidthSmall + 2*$borderDist)
	$picBoxMute | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageMuteOff
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$xPos = $xPos + $picboxCOntrolWidthSmall
	$calcWidth = $formWidth - $xpos - $Dist
	$yPos -= 4
	$trackVolume  | % {
		#$_.Font = $fontSmall
		$_.Autosize = $false
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($calcWidth,$trackbarHeight)
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Player
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Player 
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Orientation = "Horizontal"
		$_.TickFrequency = 48
		$_.TickStyle = "TopLeft"
		$_.Minimum = 0
		$_.Maximum = 320
		$_.SmallChange = 1
		$_.LargeChange = 10
		$_.Value = 0
	}
	$panelControl | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($picBoxPrevTrack)
		$_.Controls.Add($picBoxStop)
		$_.Controls.Add($picBoxPlayPause)
		$_.Controls.Add($picBoxNextTrack)
		$_.Controls.Add($picBoxScreen)
		$_.Controls.Add($picBoxMute)
		$_.Controls.Add($trackVolume)
		
		$_.Controls.Add($picBoxLoop)
		$_.Controls.Add($picBoxRepeat)
		$_.Controls.Add($picBoxRandom)
	}

	$xPos = $borderDist
	$yPos = $Dist
	$picBoxPlaylistSelect | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImagePlaylistSelect
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$xPos = $xPos + ($picboxCOntrolWidthSmall +$dist)	
	$picBoxSelectFiles | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageSelectFiles
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}	
	$xPos = $xPos + ($picboxCOntrolWidthSmall +$dist)	
	$picBoxNetworkStream | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageStream
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$xPos = $xPos + ($picboxCOntrolWidthSmall +$dist)	
	$picBoxHTTPLink | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageHTTPLink
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}		
	
	$xPos = $formWidth - $borderDist - $picboxCOntrolWidthSmall
	$picBoxExit | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageExit
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}	
	$xPos = $xPos -(2*$dist) - $picboxCOntrolWidthSmall
	$picBoxScriptSettings | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageScriptSettings
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}	
	$xPos = $xPos -$dist - $picboxCOntrolWidthSmall
	$picBoxPlaySettings | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image  = $script:ImagePlaySettings
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}	
	$xPos = $xPos -$dist - $picboxCOntrolWidthSmall
	$picBoxAlive | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageAliveGreen
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$xPos = $xPos -$dist - $picboxCOntrolWidthSmall
	$picBoxTraydown  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlayerPictureButton

		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageTrayDown
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$PanelPlaylistControl | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.BackColor = [System.Drawing.Color]::Wheat
		
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Player
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Player 
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPlaylistControl"
		$_.TabStop = $false
		$_.Controls.Add($picBoxPlaylistSelect)
		$_.Controls.Add($picBoxSelectFiles)
		$_.Controls.Add($picBoxNetworkStream)
		$_.Controls.Add($picBoxHTTPLink)
		$_.Controls.Add($picBoxPlaySettings)
		$_.Controls.Add($picBoxScriptSettings)
		$_.Controls.Add($picBoxExit)
		$_.Controls.Add($picBoxAlive)
		$_.Controls.Add($picBoxTraydown)
	}
	$tablePanelDialog | % {
		$_.Autosize = $True
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ColumnCount = 1
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.Controls.Add($PanelDisplay, 0, 0)	
		$_.Controls.Add($PanelPosition, 0, 1)
		$_.Controls.Add($PanelControl, 0, 2)			
		$_.Controls.Add($PanelPlaylistControl, 0, 4)			
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Location = New-Object System.Drawing.Point(0, 0)
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.Name = "tablePanelDialog"
		$_.RowCount = 5;
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.TabStop = $false
	}		
	$script:formMainDialog | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Player
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Player 
		
		$_.Controls.Add($tablePanelDialog)
		$_.Name = "formDialogController"
		$_.ControlBox = $false
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskBar = $false
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsMainWindowID

		if ($Bounce.IsSet  -eq "1") {
			$xpos = [int]$Bounce.XPos
			$ypos = [int]$Bounce.YPos
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.StartPosition = "Manual"
		} else {
			$_.StartPosition = "CenterScreen"
		}
		
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : $($script:CommonVLCRemoteController.HostnameOrIp)"
		
		$_.Font = $Script:FontBase

	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$ToolTip.SetToolTip($picBoxPlaylistSelect, "Playlist öffnen/schließen.")
	$ToolTip.SetToolTip($picBoxSelectFiles, "Fileexplorer öffnen/schließen.")
	$ToolTip.SetToolTip($picBoxAlive, "Verbindungsmanager.")
	$ToolTip.SetToolTip($picBoxPlaySettings, "Abspieleinstellungen.")
	$ToolTip.SetToolTip($picBoxScriptSettings, "Scripteinstellungen.")
	$ToolTip.SetToolTip($picBoxExit, "Script/VLC beenden.")
	$ToolTip.SetToolTip($picBoxTraydown, "Fenster minimieren.")
	$ToolTip.SetToolTip($picBoxNetworkStream, "Network Streams Manager.")
	$ToolTip.SetToolTip($picBoxHTTPLink, "Direkteingabe Netzwerk Stream")
	
	$ToolTip.SetToolTip($picBoxScreen, "Fullscreen")
	$ToolTip.SetToolTip($picBoxLoop, "Playlist Wiederholen")
	$ToolTip.SetToolTip($picBoxRepeat, "Einzelstück wiederholen")
	$ToolTip.SetToolTip($picBoxRandom, "Playlist zufällig abspielen")
	
	$ToolTip.SetToolTip($trackVolume, "Lautstärke :")
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$trackPosition.Add_ValueChanged({
		param($object,[System.EventArgs]$e)
		#
		# DON'T USE
		#
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$trackPosition.Add_Scroll({
		param($object,$e)

		[int]$Value = $object.value
		$script:tmrTick.Stop()
		Send-VLCRemote-Seek $script:CommonVLCRemoteController $Value
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$trackPosition.Add_Mousedown({
	
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
			if ([int]($Script:CurrentStatus.length) -gt 0) {
				$script:tmrTick.Stop()
				$DoResume = $False
				
				# ToDo : Set Track Position Dialog
				if ($Script:CurrentStatus.State -ieq "playing") {
					Send-VLCRemote-Pause $script:CommonVLCRemoteController
					$DoResume = $True
					Start-Sleep -MilliSeconds 100
				}
				Refresh-Dialog
				
				Set-PlayPositionDialog
				
				if ($DoResume) {
					Send-VLCRemote-Resume $script:CommonVLCRemoteController
				}
				$script:tmrTick.Start()
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxPrevTrack.Add_MouseClick({
		$script:tmrTick.Stop()
		Send-VLCRemote-PreviousTrack $script:CommonVLCRemoteController
		Refresh-Dialog		
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxStop.Add_MouseClick({
		$script:tmrTick.Stop()
		Send-VLCRemote-Stop $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxPlayPause.Add_MouseClick({
		$script:tmrTick.Stop()
		if ($Script:CurrentStatus.State -ieq "playing") {
			Send-VLCRemote-Pause $script:CommonVLCRemoteController
		} elseif ($Script:CurrentStatus.State -ieq "paused") {
			Send-VLCRemote-Resume $script:CommonVLCRemoteController
		} else {	
			Send-VLCRemote-Play $script:CommonVLCRemoteController
		}
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxNextTrack.Add_MouseClick({
		$script:tmrTick.Stop()
		Send-VLCRemote-NextTrack $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxScreen.Add_MouseClick({
		$script:tmrTick.Stop()
		Send-VLCRemote-ToggleFullScreen $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxLoop.Add_MouseClick({
		$script:tmrTick.Stop()
		# LOOP
		Send-VLCRemote-ToggleLoop $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxRepeat.Add_MouseClick({
		$script:tmrTick.Stop()
		# LOOP
		Send-VLCRemote-ToggleRepeat $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$picBoxRandom.Add_MouseClick({
		$script:tmrTick.Stop()
		# RANDOM
		Send-VLCRemote-ToggleRandom $script:CommonVLCRemoteController
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$trackVolume.Add_Scroll({
		param($object,$e)

		[int]$Value = $object.value
		if ($script:IsMuting) {
			$script:LastVolumeLevel = $Value
		} else {
			$script:tmrTick.Stop()
			Send-VLCRemote-SetVolumeLevel $script:CommonVLCRemoteController $Value
			Refresh-Dialog
			$script:tmrTick.Start()
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxMute.Add_MouseClick({
		$script:tmrTick.Stop()
		if ($script:IsMuting) {

			$script:IsMuting = $false
			#$trackVolume.Enabled = $true
			$picBoxMute.Image = $script:ImageMuteOff
			Send-VLCRemote-SetVolumeLevel $script:CommonVLCRemoteController $script:LastVolumeLevel
			
		} else {
			$script:IsMuting = $true
			#$trackVolume.Enabled = $false
			$picBoxMute.Image = $script:ImageMuteOn
			Send-VLCRemote-SetVolumeLevel $script:CommonVLCRemoteController 0
		}
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxPlaylistSelect.Add_MouseClick({
	
		if ($script:formMainPlaylist -eq $null) {
			Show-VLCRemotePlaylist
			
		} else {
			if ($script:formMainPlaylist.Visible) {
				$script:formMainPlaylist.Visible = $false
			} else {
				$script:formMainPlaylist.Visible = $true
			}
		}
	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxSelectFiles.Add_MouseClick({
	
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Left){
			if ($script:formMainFileExplorer -eq $null) {
				Show-VLCRemoteFileExplorer
			} else {
				if ($script:formMainFileExplorer.Visible) {
					$script:formMainFileExplorer.Visible = $false
				} else {
					$script:formMainFileExplorer.Visible = $true
				}
			}
		} elseif ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
			if ($script:formMainFileExplorer -eq $null) {
				Show-VLCRemoteFileExplorer
			} else {
				$script:formMainFileExplorer.Visible = $true
				$script:listViewFiles.Items.Clear()
				TV-Add-RootsTree				
				
			}		
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxExit.Add_MouseClick({
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Left){
			<#
			if ((Show-MessageYesNoAnswer ("Möchtest du das Script '" + $script:ScriptName + "' " + $script:ScriptVersion + " von " + $script:ScriptAuthor + " wirklich beenden ?")) -ieq "Yes") {
				$script:formMainDialog.Close()
			}
			#>
			$script:formMainDialog.Close()
			
		} elseif ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
			if ((Show-MessageYesNoAnswer "Möchtest du den VLC-Player der aktuellen Verbindung wirklich beenden ?") -ieq "Yes") {
				Send-VLCRemote-QuitVLC $script:CommonVLCRemoteController
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxTraydown.Add_MouseClick({
		
		Set-SettingsWindowBounds -ID $script:BoundsMainWindowID -FormsBound $script:formMainDialog.Bounds

		$script:formMainDialog.WindowState = [ System.Windows.Forms.FormWindowState]::Minimized
		$script:tmrTick.Stop()
		
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
			if ($script:formMainFileExplorer -ne $null){
				$script:formMainFileExplorer.Visible = $False
			}
			if ($script:formMainPlaylist -ne $null){
				$script:formMainPlaylist.Visible = $False
			}		
			if ($script:formMainNetworkStreamsManager -ne $null){
				$script:formMainNetworkStreamsManager.Visible = $False
			}		
	
		}
		
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_Load({

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxAlive.add_MouseDown({
		$MouseX = $_.X
		$MouseY = $_.Y
		
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Left){
			
			$script:tmrTick.Stop()
			Manage-VLCRemoteConnections
			
			if ($Script:ConnectionChanged) {
				if ($script:formMainPlaylist -ne $null) {
					Load-Playlist
				}
				#
				if ($script:formMainFileExplorer -ne $null) {
					TV-Add-RootsTree
					$script:listViewFiles.Items.Clear()
				}
				#
				$script:LastPlaylistID = "-1"
				$script:IsMuting = $false
				$script:LastVolumeLevel = 0
	
				Set-VLCRemoteWindowText
	
				Refresh-Dialog
			}
			
			$script:tmrTick.Start()
		} elseif ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
			Refresh-Dialog
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxNetworkStream.add_MouseDown({
	
		<#
		# Radio Paradiso
		$Stream = "http://klang.center:8080/paradiso.bln.mp3"
		
		# 104.6 RTL Berlins Hit-Radio
		$Stream = "http://stream.104.6rtl.com/rtl-live/mp3-192"
		
		# Radio 38 Braunschweig
		$Stream = "http://stream.radio38.de/bs/mp3-128/stream.radio38.de/play.m3u"
		Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Stream
		#>
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Left){
		
			if ($script:formMainNetworkStreamsManager -eq $null) {
				Show-VLCRemoteNetworkStreamsManagerSimple
			} else {
				if ($script:formMainNetworkStreamsManager.Visible) {
					$script:formMainNetworkStreamsManager.Visible = $false
				} else {
					$script:formMainNetworkStreamsManager.Visible = $true
				}
			}		
		} elseif ($_.Button -eq [Windows.Forms.MouseButtons]::Right) {
			$Tag = Select-NetworkStreamFavorite
			if ($Tag) {
				Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Tag.Url			
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxHTTPLink.add_MouseDown({
		Set-DirectLinkDialog
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxPlaySettings.Add_MouseClick({
		if ($Script:CurrentStatus) {
			Set-PlaySettingsDialog
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxScriptSettings.Add_MouseClick({
		Show-SettingsDialog
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	$script:formMainDialog.Add_FormClosing({

		if ($script:formMainDialog.WindowState -eq [System.Windows.Forms.FormWindowState]::Normal) {
			Set-SettingsWindowBounds -ID $script:BoundsMainWindowID -FormsBound $script:formMainDialog.Bounds
		}
		
		if ($script:formMainFileExplorer -ne $null) {
			Set-SettingsWindowBounds -ID $script:BoundsExplorerWindowID -FormsBound $script:formMainFileExplorer.Bounds
		
			$script:formMainFileExplorer.close()
		}
		if ($script:formMainPlaylist -ne $null) {
			Set-SettingsWindowBounds -ID $script:BoundsPlaylistWindowID -FormsBound $script:formMainPlaylist.Bounds

			$script:formMainPlaylist.close()
		}	
		if ($script:formMainNetworkStreamsManager -ne $null) {
			Set-SettingsWindowBounds -ID $script:BoundsNetworkStreamManagerWindowID -FormsBound $script:formMainNetworkStreamsManager.Bounds
		
			$script:formMainNetworkStreamsManager.close()
		}
		Save-Settings
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_FormClosed({
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_Resize({
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_Move({
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_Activated({
		$script:formMainDialog.Opacity = $script:Opacity_Activated_Main
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainDialog.Add_DeActivate({
		$script:formMainDialog.Opacity = $script:Opacity_Deactivate_Main
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$script:tmrTick.Add_Tick({
		$script:tmrTick.Stop()
		Refresh-Dialog
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$Script:NotifyIcon.Add_MouseClick({
		#
		# One Click means, if windows are open and on screen, show them
		#
		if (($script:formMainFileExplorer -ne $null) -and ($script:formMainFileExplorer.Visible )){
			$script:formMainFileExplorer.Show()
			$script:formMainFileExplorer.Activate()			
		}
		if (($script:formMainPlaylist -ne $null) -and ($script:formMainPlaylist.Visible )){
			$script:formMainPlaylist.Show()
			$script:formMainPlaylist.Activate()			
		}	
		if (($script:formMainNetworkStreamsManager -ne $null) -and ($script:formMainNetworkStreamsManager.Visible))  {
			$script:formMainNetworkStreamsManager.Show()
			$script:formMainNetworkStreamsManager.Activate()		
		}
		
		$script:formMainDialog.Show()
		$script:formMainDialog.Activate()		
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$Script:NotifyIcon.Add_MouseDoubleClick({
		#
		# Double Click means, if windows are open, make them visible and show all
		#
		$script:tmrTick.Start()
		
		if ($script:formMainFileExplorer -ne $null){
			$script:formMainFileExplorer.Visible = $True
			$script:formMainFileExplorer.Show()
			$script:formMainFileExplorer.Activate()			
		}
		if ($script:formMainPlaylist -ne $null){
			$script:formMainPlaylist.Visible = $True
			$script:formMainPlaylist.Show()
			$script:formMainPlaylist.Activate()			
		}		
		if ($script:formMainNetworkStreamsManager -ne $null){
			$script:formMainNetworkStreamsManager.Visible = $True
			$script:formMainNetworkStreamsManager.Show()
			$script:formMainNetworkStreamsManager.Activate()			
		}		
		$script:formMainDialog.WindowState = [System.Windows.Forms.FormWindowState]::Normal
		$script:formMainDialog.Visible = $True
		$script:formMainDialog.Show()
		$script:formMainDialog.Activate()	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# ##### Notify MenuItem
	# #########################################################################################################################
	$Script:NIContextMenu		= New-Object System.Windows.Forms.ContextMenu
		$Script:NIMenuItemExit		= New-Object System.Windows.Forms.MenuItem	
		$Script:NIMenuItemHideShowPlayer = New-Object System.Windows.Forms.MenuItem	
	
	$Script:NotifyIcon.ContextMenu = $Script:NIContextMenu
	
	# --------------------------------------------------------------------------------
	
	$Script:NIMenuItemExit.Text = "&Exit"
	$Script:NIMenuItemExit.add_Click({
		$script:formMainDialog.Close()
	})
	# --------------------------------------------------------------------------------
	$Script:NIMenuItemHideShowPlayer.Text = "&Hide/Show PlayerWindow"
	$Script:NIMenuItemHideShowPlayer.add_Click({
		if ($script:formMainDialog.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
			$script:tmrTick.Start()
			$script:formMainDialog.WindowState = [System.Windows.Forms.FormWindowState]::Normal
			$script:formMainDialog.Activate()
		} else {
			Set-SettingsWindowBounds -ID $script:BoundsMainWindowID -FormsBound $script:formMainDialog.Bounds
			
			$script:tmrTick.Stop()
			$script:formMainDialog.WindowState = [ System.Windows.Forms.FormWindowState]::Minimized
		}
	})
	# --------------------------------------------------------------------------------

	$Script:NIMenuItemHideShowPlayer.Index = 1
	$Script:NIMenuItemExit.Index = 2
	
	$Script:NotifyIcon.ContextMenu.MenuItems.AddRange(@($Script:NIMenuItemHideShowPlayer,$Script:NIMenuItemExit))
	# #########################################################################################################################
	
	$script:tmrTick.IsEnabled = $true
	$script:tmrTick.Start()	
	
	
	$Script:NotifyIcon.Icon = $script:ScriptIcon
	$Script:NotifyIcon.Visible = $True
	
	Set-VLCRemoteWindowText
	
	$script:formMainDialog.ShowDialog() | out-null	
	
	$Script:NotifyIcon.Visible = $False
	$Script:NotifyIcon.Dispose()	
	
	$script:tmrTick.Stop()
	$script:tmrTick.IsEnabled = $false
	$script:tmrTick.Add_Tick({})
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-PlayPositionDialog {
[CmdletBinding()]
Param	(
		)
		

	# ---------------------------------------------------------------------------------------------------------------------
	$formPlayPositionDialog		= New-Object System.Windows.Forms.Form
		$lblText  			= New-Object System.Windows.Forms.Label
		$dateTimePicker 	= New-Object System.Windows.Forms.DateTimePicker
		$buttonSet 			= New-Object System.Windows.Forms.Button

	$xPos = 5
	$yPos = 10
	$dist = 3
	$labelWidth = 120
	$labelHeight = 20
	
	$formWidth = 400 
	$formHeight = 20 + $labelHeight
	
	
	$lblText | % {
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Zu Zeitpunkt gehen"
	}
	$xPos +=($labelWidth + $dist)
	$dateTimePicker  | % {
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false	
		$_.Format = [System.Windows.Forms.DateTimePickerFormat]::Time
		$_.ShowUpDown = $True
	}
	$xPos +=($labelWidth + $dist)
	$buttonSet | % {
		$_.AutoSize = $False
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSet"
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$formPlayPositionDialog | % {
		$_.AutoSize = $False
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Player
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Player 
				
		$_.Controls.Add($lblText)
		$_.Controls.Add($dateTimePicker)
		$_.Controls.Add($buttonSet)
		$_.Name = "formPlayPositionDialog"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Set Track Position"
		
		$_.Font = $Script:FontBase

		$_.StartPosition = "CenterParent"
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSet.Add_Click({
		$dt = $dateTimePicker.Value
		
		$Seconds = ($dt.Hour * 3600) + ($dt.Minute * 60) + $dt.Second

		Send-VLCRemote-Seek $script:CommonVLCRemoteController $Seconds
		Start-Sleep -MilliSeconds 100
		Refresh-Dialog
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$dateTimePicker.MinDate = (New-Object System.DateTime(2016,1,1,0,0,0))
	$dateTimePicker.MaxDate = (New-Object System.DateTime(2016,1,1,0,0,0)).AddSeconds($Script:CurrentStatus.length)
	
	$dateTimePicker.Value = (New-Object System.DateTime(2016,1,1,0,0,0)).AddSeconds($Script:CurrentStatus.time)
	$formPlayPositionDialog.ShowDialog() | out-null	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-DirectLinkDialog {
[CmdletBinding()]
Param	(
		)
		

	# ---------------------------------------------------------------------------------------------------------------------
	$formDirectLinkDialog		= New-Object System.Windows.Forms.Form
		$lblText  			= New-Object System.Windows.Forms.Label
		$textboxDirectLink 	= New-Object System.Windows.Forms.Textbox
		$buttonSet 			= New-Object System.Windows.Forms.Button

	$xPos = 5
	$yPos = 10
	$dist = 3
	$labelWidth = 120
	$labelHeight = 20
	
	$formWidth = 506
	$formHeight = 20 + $labelHeight
	
	
	$lblText | % {
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Netstream Link"
	}
	$xPos +=($labelWidth + $dist)
	$textboxDirectLink  | % {
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(250, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false	
	}
	$xPos +=(250 + $dist)
	$buttonSet | % {
		$_.AutoSize = $False
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSet"
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Text = "Play"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$formDirectLinkDialog | % {
		$_.AutoSize = $False
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
		
		$_.Controls.Add($lblText)
		$_.Controls.Add($textboxDirectLink)
		$_.Controls.Add($buttonSet)
		$_.Name = "formDirectLinkDialog"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Netstream Link"
		
		$_.Font = $Script:FontBase

		$_.StartPosition = "CenterParent"
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSet.Add_Click({
		$NetstreamLink = $textboxDirectLink.Text
		
		if ($NetstreamLink -ne "") {
			Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $NetstreamLink	
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	$formDirectLinkDialog.ShowDialog() | out-null	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-PlaySettingsDialog {
[CmdletBinding()]
Param	(
		)
		

	# ---------------------------------------------------------------------------------------------------------------------
	$formPlaySettingsDialog		= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.FlowLayoutPanel
			$PanelCommon		= New-Object System.Windows.Forms.Panel
				$lblTextCommon			= New-Object System.Windows.Forms.Label
			
				$lblRate  				= New-Object System.Windows.Forms.Label
				$comboBoxRate	 		= New-Object System.Windows.Forms.ComboBox
				$buttonSetRate 			= New-Object System.Windows.Forms.Button
				
				$buttonRateFasterFine		= New-Object System.Windows.Forms.Button
				$buttonRateFaster 			= New-Object System.Windows.Forms.Button
				$buttonRateNormal 			= New-Object System.Windows.Forms.Button
				$buttonRateSlower 			= New-Object System.Windows.Forms.Button
				$buttonRateSlowerFine		= New-Object System.Windows.Forms.Button

				
			$PanelVideo		= New-Object System.Windows.Forms.Panel
				$lblTextVideo				= New-Object System.Windows.Forms.Label
				
				$lblAudioTrack  			= New-Object System.Windows.Forms.Label
				$comboBoxAudioTrack	 		= New-Object System.Windows.Forms.ComboBox
				$buttonSetAudioTrack		= New-Object System.Windows.Forms.Button

				$lblAudioDelay  			= New-Object System.Windows.Forms.Label
				$textBoxAudioDelay	 		= New-Object System.Windows.Forms.Textbox
				$buttonSetAudioDelay		= New-Object System.Windows.Forms.Button
				
				$lblSubtitle  				= New-Object System.Windows.Forms.Label
				$comboBoxSubtitle	 		= New-Object System.Windows.Forms.ComboBox
				$buttonSetSubtitle			= New-Object System.Windows.Forms.Button

				$lblSubtitleDelay  			= New-Object System.Windows.Forms.Label
				$textBoxSubtitleDelay	 	= New-Object System.Windows.Forms.Textbox
				$buttonSetSubtitleDelay		= New-Object System.Windows.Forms.Button

				$lblRatio  				= New-Object System.Windows.Forms.Label
				$comboBoxRatio	 		= New-Object System.Windows.Forms.ComboBox
				$buttonSetRatio			= New-Object System.Windows.Forms.Button
				
				$lblCrop  				= New-Object System.Windows.Forms.Label
				$buttonCropCycle			= New-Object System.Windows.Forms.Button
				
			$PanelAudio		= New-Object System.Windows.Forms.Panel
				$lblTextAudio			= New-Object System.Windows.Forms.Label
				
				$lblAudioDevice				= New-Object System.Windows.Forms.Label
				$buttonAudioDeviceCycle 	= New-Object System.Windows.Forms.Button
				
	Function Set-DialogValues {
		Refresh-Dialog		
	
		$comboBoxRate.Items.Clear()
		$comboBoxRate.Items.AddRange($Script:playRateSettings)
		$comboBoxRate.Text = $Script:CurrentStatus.Rate
		
		if ($Script:CurrentStatus.Typ -ieq "Video") {
			$comboBoxAudioTrack.Items.Clear()
			$comboBoxAudioTrack.Items.Add("Deaktivieren")
			foreach ($AT in $Script:CurrentStatus.AudioStreams) {
				$Text = $AT.StreamText
				$comboBoxAudioTrack.Items.Add($Text)
			}
			$comboBoxAudioTrack.SelectedIndex = 1	

			$textBoxAudioDelay.Text  = $Script:CurrentStatus.AudioDelay

			if ($Script:CurrentStatus.SubtitleStreams -and ($Script:CurrentStatus.SubtitleStreams.count -gt 0)) {
				$comboBoxSubtitle.Items.Clear()
				$comboBoxSubtitle.Items.Add("Deaktivieren")
				foreach ($AT in $Script:CurrentStatus.SubtitleStreams) {
					$Text = $AT.StreamText
					$comboBoxSubtitle.Items.Add($Text)
				}
				$comboBoxSubtitle.SelectedIndex = 1	
			} else {
				$lblSubtitle.Enabled = $false
				$comboBoxSubtitle.Enabled = $False
				$buttonSetSubtitle.Enabled = $False
				$lblSubtitleDelay.Enabled = $False  		
				$textBoxSubtitleDelay.Enabled = $False	
				$buttonSetSubtitleDelay.Enabled = $False	
			}
			$textBoxSubtitleDelay.Text  = $Script:CurrentStatus.SubtitleDelay
			
			$comboBoxRatio.Items.Clear()
			$comboBoxRatio.Items.AddRange($script:aspectRatioSettings)
			$comboBoxRatio.Text = $Script:CurrentStatus.AspectRatio
			
		}
	}
	
	$xPos = 5
	$yPos = 5
	$dist = 3
	$labelWidth = 120
	$labelHeight = 22
	
	$buttonWidth  = 80
	$buttonHeight = 22
	
	$comboBoxRateWidth = 170
	
	$formWidth = 390
	$formHeight = 400

	$FontBig   = New-Object System.Drawing.Font("Segoe UI",12, [System.Drawing.FontStyle]::Bold)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$labelWidthHeader = $formWidth - 10
	$tmpLabel = New-Object System.Windows.Forms.Label
	$g = $tmpLabel.CreateGraphics()
		
	$sf = $g.MeasureString("Allgemein",$FontBig,$labelWidthHeader)
	$labelHeightHeader = [math]::round($sf.Height)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$lblTextCommon  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidthHeader, $labelHeightHeader)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Font = $FontBig
		$_.TabStop = $false
		$_.Text = "Allgemein"
	}
	$xPos = 5
	$yPos += ($labelHeightHeader + $dist)
	$lblRate | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Geschwindigkeit"
	}
	$xPos +=($labelWidth + $dist)
	$comboBoxRate  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxRateWidth, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetRate | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$yPos += ($labelHeight + $dist)
	$xPos = (5 + $labelWidth + $dist)
	$buttonRateSlowerFine, $buttonRateSlower, $buttonRateNormal, $buttonRateFaster, $buttonRateFasterFine | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
		$xPos += (30 + 2*$Dist)
	}	
	$buttonRateSlowerFine.Text	= "<<"
	$buttonRateSlower.Text			= "<"
	$buttonRateNormal.Text			= "N"
	$buttonRateFaster.Text			= ">"
	$buttonRateFasterFine.Text		= ">>"
	
	$PanelCommon | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($lblTextCommon)
		$_.Controls.Add($lblRate)
		$_.Controls.Add($comboBoxRate)
		$_.Controls.Add($buttonSetRate)
		$_.Controls.Add($buttonRateSlowerFine)
		$_.Controls.Add($buttonRateSlower)
		$_.Controls.Add($buttonRateNormal)
		$_.Controls.Add($buttonRateFaster)
		$_.Controls.Add($buttonRateFasterFine)
	}
	# -----------------
	$xPos = 5
	$yPos = 5
	$lblTextVideo  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidthHeader, $labelHeightHeader)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Font = $FontBig
		$_.TabStop = $false
		$_.Text = "Video"
	}
	$xPos = 5
	$yPos += ($labelHeightHeader + $dist)
	$lblAudioTrack | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Audio-Track"
	}
	$xPos +=($labelWidth + $dist)
	$comboBoxAudioTrack  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxRateWidth, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetAudioTrack | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblAudioDelay | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Audio-Delay (+-Sec)"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxAudioDelay  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TabStop = $false
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetAudioDelay | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblSubtitle | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Subtitle"
	}
	$xPos +=($labelWidth + $dist)
	$comboBoxSubtitle  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxRateWidth, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetSubtitle | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblSubtitleDelay | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Subtitle-Delay"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxSubtitleDelay  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TabStop = $false
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetSubtitleDelay | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblRatio | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Aspect-Ratio"
	}
	$xPos +=($labelWidth + $dist)
	$comboBoxRatio  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxRateWidth, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos =($formWidth - 5 - $buttonWidth)
	$buttonSetRatio | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetRate"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Set"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblCrop  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Crop"
	}		
	$xPos = (5 + $labelWidth + $dist)
	$buttonCropCycle	 | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "buttonCropDown"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = " Cycle "
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	
	$PanelVideo | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($lblTextVideo)
		$_.Controls.Add($lblAudioTrack)
		$_.Controls.Add($comboBoxAudioTrack)
		$_.Controls.Add($buttonSetAudioTrack)
		$_.Controls.Add($lblAudioDelay)
		$_.Controls.Add($textBoxAudioDelay)
		$_.Controls.Add($buttonSetAudioDelay)	
		$_.Controls.Add($lblSubtitle)
		$_.Controls.Add($comboBoxSubtitle)
		$_.Controls.Add($buttonSetSubtitle)	
		$_.Controls.Add($lblSubtitleDelay)
		$_.Controls.Add($textBoxSubtitleDelay)
		$_.Controls.Add($buttonSetSubtitleDelay)
		$_.Controls.Add($lblRatio)
		$_.Controls.Add($comboBoxRatio)
		$_.Controls.Add($buttonSetRatio)

		$_.Controls.Add($lblCrop) 		
		$_.Controls.Add($buttonCropCycle)	
	}
	# -----------------
	$xPos = 5
	$yPos = 5
	$lblTextAudio  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidthHeader, $labelHeightHeader)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Font = $FontBig
		$_.TabStop = $false
		$_.Text = "Audio"
	}
	$xPos = 5
	$yPos += ($labelHeightHeader + $dist)
	$lblAudioDevice  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Audio Device"
	}		
	$xPos = (5 + $labelWidth + $dist)
	$buttonAudioDeviceCycle	 | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "buttonCropDown"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = " Cycle "
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false
	}
	$PanelAudio | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($lblTextAudio)
		
		$_.Controls.Add($lblAudioDevice)
		$_.Controls.Add($buttonAudioDeviceCycle)
	}	
	$PanelMain | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.FlowDirection = "TopDown"
		$_.Controls.Add($PanelCommon)
		$_.Controls.Add($PanelVideo)
		$_.Controls.Add($PanelAudio)
	}
	$formPlaySettingsDialog | % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
		$_.BackColor = [System.Drawing.Color]::White
		$_.Controls.Add($PanelMain)
		$_.Name = "formPlaySettingsDialog"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Play Settings"
		
		$_.Font = $Script:FontBase

		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsPlaySettingsWindowID
		
		if ($Bounce.IsSet -eq "1") {
			$xpos = [int]$Bounce.XPos
			$ypos = [int]$Bounce.YPos
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.StartPosition = "Manual"
			
			$width = [int]$Bounce.Width
			$height = [int]$Bounce.Height			
			$_.Size = New-Object System.Drawing.Size($Width, $Height)
		} else {
			$_.StartPosition = "CenterParent"
			$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		}	
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$formPlaySettingsDialog.Add_FormClosing({
		Set-SettingsWindowBounds -ID $script:BoundsPlaySettingsWindowID -FormsBound $formPlaySettingsDialog.Bounds
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetRate.Add_Click({
		
		$NewRate = $comboBoxRate.Text
		if ($NewRate -ne "") {
			$NewRate = $NewRate -Replace ",","."
			try {
				$dblValue = [double]$NewRate
			} catch {
				$dblValue = -1
			}
			if (($dblValue -ge 0.0) -and ($dblValue -le 64.0)) {
				Send-VLCRemote-SetRateValue $script:CommonVLCRemoteController ([string]$dblValue)
				Start-Sleep -MilliSeconds 100
				Set-DialogValues
			}
		}
	})
	$buttonRateSlowerFine.Add_Click({
		Send-VLCRemote-SetRateSlowerFine $script:CommonVLCRemoteController
		Start-Sleep -MilliSeconds 100
		Set-DialogValues
	})
	$buttonRateSlower.Add_Click({
		Send-VLCRemote-SetRateSlower $script:CommonVLCRemoteController
		Start-Sleep -MilliSeconds 100
		Set-DialogValues
	})
	$buttonRateNormal.Add_Click({
		Send-VLCRemote-SetRateNormal $script:CommonVLCRemoteController
		Start-Sleep -MilliSeconds 100
		Set-DialogValues
	})
	$buttonRateFaster.Add_Click({
		Send-VLCRemote-SetRateFaster $script:CommonVLCRemoteController
		Start-Sleep -MilliSeconds 100
		Set-DialogValues
	})
	$buttonRateFasterFine.Add_Click({
		Send-VLCRemote-SetRateFasterFine $script:CommonVLCRemoteController
		Start-Sleep -MilliSeconds 100
		Set-DialogValues
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetAudioTrack.Add_Click({
		
		$TrackNumber = ""
		$SelText = $comboBoxAudioTrack.Text
		if ($SelText -ieq "Deaktivieren") {$TrackNumber = "-1"} 
		else {
			foreach ($AT in $Script:CurrentStatus.AudioStreams) {
				if ($AT.StreamText -ieq $SelText) {
					$TrackNumber = $AT.StreamNumber
				}
			}				
		}
		Send-VLCRemote-SetAudioTrackValue $script:CommonVLCRemoteController $TrackNumber
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetAudioDelay.Add_Click({
		$DelayValue = $textboxAudioDelay.Text
		
		if ($DelayValue -ne "") {
		
			$DelayValue = $DelayValue -Replace ",","."
			try {
				$dblValue = [double]$DelayValue
			} catch {
				$dblValue = 0.0
			}
			
			Send-VLCRemote-SetAudioDelayValue $script:CommonVLCRemoteController ([string]$dblValue)
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetSubtitle.Add_Click({
		$SubtitleNumber = ""
		$SelText = $comboBoxSubtitle.Text
		if ($SelText -ieq "Deaktivieren") {
			$SubtitleNumber = "-1"
		} else {
			foreach ($AT in $Script:CurrentStatus.SubtitleStreams) {
				if ($AT.StreamText -ieq $SelText) {
					$SubtitleNumber = $AT.StreamNumber
				}
			}				
		}
		Send-VLCRemote-SetSubtitleValue $script:CommonVLCRemoteController $SubtitleNumber
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$buttonSetSubtitleDelay.Add_Click({
		$DelayValue = $textboxSubtitleDelay.Text
		
		if ($DelayValue -ne "") {
		
			$DelayValue = $DelayValue -Replace ",","."
			try {
				$dblValue = [double]$DelayValue
			} catch {
				$dblValue = 0.0
			}
			
			#Send-VLCRemote-SetAudioDelayValue $script:CommonVLCRemoteController ([string]$dblValue)
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetRatio.Add_Click({
		
		$NewRatio = $comboBoxRatio.Text
		if ($NewRatio -ne "") {
			Send-VLCRemote-SetAspectRatio $script:CommonVLCRemoteController $NewRatio
			Start-Sleep -MilliSeconds 100
			Set-DialogValues
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonCropCycle.Add_Click({
	
		Send-VLCRemote-SetKey -VLCRemoteController $script:CommonVLCRemoteController -KeyValue "crop"

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonAudioDeviceCycle.Add_Click({
	
		Send-VLCRemote-SetKey -VLCRemoteController $script:CommonVLCRemoteController -KeyValue "audiodevice-cycle"

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#$Script:CurrentStatus | out-host
	
	Set-DialogValues
	
	if (!($Script:CurrentStatus.Typ -ieq "Video")) {
		$PanelVideo.Enabled = $false
	}
	
	$formPlaySettingsDialog.ShowDialog() | out-null	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#