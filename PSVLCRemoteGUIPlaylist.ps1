#################################################################################################
# Name			: 	PSVLCRemoteGUIPlaylist.ps1
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
#endregion LoadAssemblies
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
$script:formMainPlaylist = $null
$script:listViewPlaylist = $null
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
	$script:contextMenuLVPlaylist = New-Object System.Windows.Forms.ContextMenu
		$menuItem_PL_Play					= $contextMenuLVPlaylist.MenuItems.Add("Abspielen")
		$menuItem_PL_Delete				= $contextMenuLVPlaylist.MenuItems.Add("Entfernen")
		$menuItem_PL_Refresh				= $contextMenuLVPlaylist.MenuItems.Add("Refresh")
		$menuItem_PL_Delimiter1			= $contextMenuLVPlaylist.MenuItems.Add("-")
		$menuItem_PL_DeletePlaylist		= $contextMenuLVPlaylist.MenuItems.Add("Playlist löschen")
#
# ---------------------------------------------------------------------------------------------------------------------
Function Load-Playlist {
[CmdletBinding()]
Param	(
		)
	if ($script:listViewPlaylist) {
		$script:listViewPlaylist.BeginUpdate()
		$script:listViewPlaylist.Items.Clear()
		
		$Files = Get-VLCRemote-Playlist -VLCRemoteController $script:CommonVLCRemoteController | Sort-Object Id
		#$Files | ft -autosize | out-host
		
		Foreach($F in $Files) {
			$item = new-object System.Windows.Forms.ListViewItem($F.Id)
			$item.SubItems.Add($F.Name) | out-null		
			$item.SubItems.Add(([timespan]::fromseconds($F.Duration)).ToString())  | out-null				
			$item.SubItems.Add($F.Uri)  | out-null		
			
			$item.tag = $F
			$script:listViewPlaylist.Items.Add($item)	| out-null
		}
		$script:listViewPlaylist.EndUpdate()
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------	

Function Show-VLCRemotePlaylist {
[CmdletBinding()]
Param	(
		)
	# ---------------------------------------------------------------------------------------------------------------------
	# ---------------------------------------------------------------------------------------------------------------------
	# ---------------------------------------------------------------------------------------------------------------------
	# ---------------------------------------------------------------------------------------------------------------------
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#region OBJECT Definitions	
	$script:formMainPlaylist						= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.Panel
			$PanelPlaylist = New-Object System.Windows.Forms.Panel
				$script:listViewPlaylist = New-Object System.Windows.Forms.ListView
			$PanelPlaylistControl = New-Object System.Windows.Forms.Panel
				$picBoxPlaylistRefresh = New-Object System.Windows.Forms.PictureBox
				$picBoxPlaylistClear = New-Object System.Windows.Forms.PictureBox
				$picBoxTraydown  = New-Object System.Windows.Forms.PictureBox
	

		
	$formWidth   = 300
	$formHeight  = 400
	$borderDist  = 5
	$picboxCOntrolWidth = 36
	$picboxCOntrolWidthSmall = 24
	$xPos = 0
	$yPos = 0
	$script:listViewPlaylist | % {
		$_.Name = "listViewPlaylist"	
		$_.CheckBoxes = $False
		$_.DataBindings.DefaultDataSourceUpdateMode = 0
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Playlist 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Playlist 
		
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.HeaderStyle = "NonClickable"
		$_.FullRowSelect = $True
		$_.GridLines = $False
		$_.HideSelection = $False
		$_.MultiSelect = $true		
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
		$_.ContextMenu = $script:contextMenuLVPlaylist
	}
	$script:listViewPlaylist.Clear()
	$script:listViewPlaylist.Columns.Add("ID",30) | out-null
	$script:listViewPlaylist.Columns.Add("Titel",140) | out-null
	$script:listViewPlaylist.Columns.Add("Laufzeit",60) | out-null
	$script:listViewPlaylist.Columns.Add("Pfad",300) | out-null
	
	$PanelPlaylist | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPlaylist"
		$_.TabStop = $false
		$_.Controls.Add($script:listViewPlaylist)
		#$_.BorderStyle = "FixedSingle"
	}
	$xPos = $borderDist
	$yPos = $borderDist
	$picBoxPlaylistRefresh | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageRefresh
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}

	$xPos = $xPos + ($picboxCOntrolWidthSmall +$dist)
	$picBoxPlaylistClear | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageClearPlaylist
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}		
	$yPos = $borderDist
	$xPos = $FormWidth - $BorderDist - $picboxCOntrolWidthSmall
	$picBoxTraydown | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Right)
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageTrayDown
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}	
	$PanelPlaylistControl | % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Size = New-Object System.Drawing.Size($formWidth, ($picboxCOntrolWidthSmall+(2*$borderDist)))
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_PlaylistBottom 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_PlaylistBottom 
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPlaylistControl"
		$_.TabStop = $false
		$_.Controls.Add($picBoxPlaylistRefresh)
		$_.Controls.Add($picBoxPlaylistClear)
		$_.Controls.Add($picBoxTraydown)
	}	
	$PanelMain  | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "PanelMain"
		$_.TabStop = $false
		$_.Controls.Add($PanelPlaylist)
		$_.Controls.Add($PanelPlaylistControl)		
	}
	
	$script:formMainPlaylist | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_Playlist 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_Playlist 
		
		$_.Name = "formMainPlaylist"
		$_.ControlBox = $false
		$_.ShowInTaskbar = $false
		$_.Padding = New-Object System.Windows.Forms.Padding (3,3,3,3)
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsPlaylistWindowID
		
		if ($Bounce.IsSet -eq "1") {
			$xpos = [int]$Bounce.XPos
			$ypos = [int]$Bounce.YPos
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.StartPosition = "Manual"
			
			$width = [int]$Bounce.Width
			$height = [int]$Bounce.Height
			$_.Size = New-Object System.Drawing.Size($Width, $Height)
		} else {
			$_.StartPosition = "CenterScreen"
			$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		}
		
		$_.Text = "$script:ScriptName : Playlist"
		$_.Controls.Add($PanelMain)
		
		$_.Font = $Script:FontBase
	
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainPlaylist.Add_Activated({
		$script:formMainPlaylist.Opacity = $script:Opacity_Activated_Playlist
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainPlaylist.Add_DeActivate({
		$script:formMainPlaylist.Opacity = $script:Opacity_Deactivate_Playlist
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$listViewPlaylist.Add_MouseDoubleClick({
		Param($Object,$Event)

		if ($Event.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
			$hit = $listViewPlaylist.HitTest($Event.Location)

			if($hit.Item) {
				$Object = $hit.Item.Tag
				$script:tmrTick.Stop()
				Send-VLCRemote-PlayItemFromPlaylist $script:CommonVLCRemoteController $Object.Id
				$script:tmrTick.Start()
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$listViewPlaylist.add_MouseDown({
		$MouseX = $_.X
		$MouseY = $_.Y
		
		$listViewPlaylist.ContextMenu = $null
		
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
		
			[System.Windows.Forms.ListViewHitTestInfo] $HitTestInfo = $listViewPlaylist.HitTest($MouseX, $MouseY)

			if ($HitTestInfo.Item) {
				$listViewPlaylist.ContextMenu = $script:contextMenuLVPlaylist
			}
		} 
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$picBoxPlaylistRefresh.Add_MouseClick({
		Load-Playlist	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxPlaylistClear.Add_MouseClick({
		$script:tmrTick.Stop()
		Send-VLCRemote-ClearPlaylist -VLCRemoteController $script:CommonVLCRemoteController
		Refresh-Dialog
		Load-Playlist
		$script:tmrTick.Start()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:contextMenuLVPlaylist.add_Popup({
	
		$menuItem_PL_Play.Enabled = $false
		
		if ($listViewPlaylist.SelectedItems.count -eq 1) {
			$menuItem_PL_Play.Enabled = $true
		} 
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItem_PL_Play.Add_Click({
		Param($o,$e)
		
		$Item = $listViewPlaylist.FocusedItem
		if ($Item) {
			$Object = $Item.Tag
			$script:tmrTick.Stop()
			Send-VLCRemote-PlayItemFromPlaylist $script:CommonVLCRemoteController $Object.Id
			$script:tmrTick.Start()
		}	
	})			
	$menuItem_PL_Delete.Add_Click({
		if ($listViewPlaylist.SelectedItems.Count -gt 0) {
			Foreach ($Item in $listViewPlaylist.SelectedItems) {
				$Tag = $Item.Tag
				
				$script:tmrTick.Stop()
				Send-VLCRemote-RemoveFromPlaylist $script:CommonVLCRemoteController $Tag.Id
				$script:tmrTick.Start()
			}
			Load-Playlist
		} 
	
	})			
	$menuItem_PL_Refresh.Add_Click({
		Load-Playlist
	})				

	$menuItem_PL_DeletePlaylist.Add_Click({
		$script:tmrTick.Stop()
		Send-VLCRemote-ClearPlaylist -VLCRemoteController $script:CommonVLCRemoteController
		Refresh-Dialog
		Load-Playlist
		$script:tmrTick.Start()	
	})			
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxTraydown.Add_MouseClick({
		$script:formMainPlaylist.Visible = $false
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	Load-Playlist
	
	$script:formMainPlaylist.Show() | out-null	

}