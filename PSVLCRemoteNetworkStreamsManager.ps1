#################################################################################################
# Name			: 	PSVLCRemoteNetworkStreamsManager.ps1
# Description	: 	
# Author		: 	Axel Anderson (-XP)
# License		:	
# Date			: 	05.12.2015 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Set-StrictMode -Version Latest	
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
#region ScriptVariable
#endregion ScriptVariable
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Select-FolderDialog {
[CmdletBinding()]
	Param(
			[string]$message="Select a folder",
			[string]$InitialDirectory=""
		 )
	$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
		Description = $message
		SelectedPath = $InitialDirectory
		ShowNewFolderButton = $false
	}
 
	if ($FolderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
		Write-output $FolderBrowser.SelectedPath
	} else {
		Write-output $Null
	}

} 
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-NetworkStreamConfigurationValue {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$NetworkStreamFileData
		)
	$xmlDataSet = $null

	$xmlDataSet = Load-NetworkStreamData $NetworkStreamFileData.Filename $script:NetworkStreamDataSetName
	
	if ($xmlDataSet) {	
		if ($xmlDataSet.Tables["Configuration"]) {
			$Config = $xmlDataSet.Tables["Configuration"].Select() | Select-Object -First 1 
		} else {
			$Config = $null
		}	

		if ($Config) {
			$Config.Name    = $NetworkStreamFileData.Name
			$Config.Comment = $NetworkStreamFileData.Description
			$Config.AcceptChanges()
			
			$bRetVal = Save-NetworkStreamDataSet -XmlNetworkStreamDataSet $xmlDataSet -XmlNetworkStreamFilename $NetworkStreamFileData.Filename
		}
	}
		
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#

Function New-VLCRemoteNetworkStreamsManagerDataObject {
[CmdletBinding()]
Param	(	[String]$Filename,
			[string]$Name,
			[string]$Description
		)
	$Data = New-Object PSObject -Property @{
		Filename		= $Filename
		Name			= $Name
		Description		= $Description
	}
	
	Write-Output $data
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-FilesDataFromPath {
[CmdletBinding()]
Param	(	
			[String]$Path
		)
	$Data = @()
	
	$Files = Get-ChildItem $Path | Where-Object {$_.Name -like "*.NetworkStream.xml"} | Foreach-Object {$_.FullName}
	
	foreach ($File in $Files) {
		$xmlDataSet = $null
	
		$xmlDataSet = Load-NetworkStreamData $File $script:NetworkStreamDataSetName
		
		if ($xmlDataSet) {	
			if ($xmlDataSet.Tables["Configuration"]) {
				$Config = $xmlDataSet.Tables["Configuration"].Select() | Select-Object -First 1 
			} else {
				$Config = $null
			}	

			if ($Config) {
				$Object = New-VLCRemoteNetworkStreamsManagerDataObject -Filename $File -Name $Config.Name -Description $Config.Comment
				$Data += $Object
			}
		}
	}
	
	Write-Output $Data
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Manage-VLCRemoteNetworkStreamFiles {
[CmdletBinding()]
Param	()

	Function Load-FilesDataList {
	[CmdletBinding()]
	Param	(
				[string]$Path
			)
		$Data = Get-FilesDataFromPath  $Path 

		$listView.BeginUpdate()
		$listView.Items.Clear()
		
		Foreach($D in $Data) {
			$item = new-object System.Windows.Forms.ListViewItem($D.Name)
			$item.SubItems.Add($D.Description) | out-null		
			$item.SubItems.Add($D.Filename)  | out-null				
			
			$item.tag = $D
			$listView.Items.Add($item)	| out-null
		}
		
		$listView.EndUpdate()

	}

	$script:PSVLCRemoteStreamConfigurationPath_Manager = $script:PSVLCRemoteStreamConfigurationPath
	
#region OBJECT Definitions	
	$formNetworkStreamFilesManager		= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.Panel
			$PanelLeft		= New-Object System.Windows.Forms.Panel
				$listView	= New-Object System.Windows.Forms.ListView
				$labelPath	= New-Object System.Windows.Forms.Label
			$PanelRight		= New-Object System.Windows.Forms.FlowLayoutPanel
				$buttonChangePath	= New-Object System.Windows.Forms.Button
				$buttonNew			= New-Object System.Windows.Forms.Button
				$buttonEdit			= New-Object System.Windows.Forms.Button
				$buttonMerge		= New-Object System.Windows.Forms.Button
				$buttonSelect		= New-Object System.Windows.Forms.Button

	$FontLabel = New-Object System.Drawing.Font("Segoe UI",9, [System.Drawing.FontStyle]::Bold)	

	$borderDist  = 5
	$dist = 3
	
	$ButtonWidth = 120 
	$ButtonHeight = 21
	
	$formWidth = 440 + (4*$BorderDist) + $buttonWidth
	$formHeight = 320 
	$labelHeightSingle = 20

	
	$listViewHeight = $formHeight - (2*$BorderDist)
	$listViewWidth  = $formWidth - (4*$BorderDist) - $buttonWidth
		
	$xPos = $borderDist
	$yPos = $borderDist
	$listView | % {
		$_.Name = "listView"	
		$_.CheckBoxes = $False
		$_.DataBindings.DefaultDataSourceUpdateMode = 0
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_ConnectionManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_ConnectionManager
		
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		#$_.Size = New-Object System.Drawing.Size(($listViewWidth),($listViewHeight))
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.HeaderStyle = "NonClickable"
		$_.FullRowSelect = $True
		$_.GridLines = $False
		$_.HideSelection = $False
		$_.MultiSelect = $false		
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
	}	
	$listView.Clear()
	$listView.Columns.Add("Name",180) | out-null
	$listView.Columns.Add("Comment",200) | out-null
	$listView.Columns.Add("Filename",600) | out-null

	$labelPath  | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Font = $FontLabel
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		#$_.Location = New-Object System.Drawing.Point(5, $yPos)
		$_.Size = New-Object System.Drawing.Size(0, 24)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_ConnectionManagerButtonPanel
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.TabStop = $false
		$_.Text = ("Current Path : "+$script:PSVLCRemoteStreamConfigurationPath_Manager)
	}
	
	$panelLeft | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($listView)
		$_.Controls.Add($labelPath)
	}
	$xPos = $borderDist
	$yPos = $borderDist
	$buttonChangePath| % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonNew"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Change Path"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}

	$buttonNew | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonNew"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "New"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonEdit | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonEdit"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Edit"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonMerge | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonMerge"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Merge"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonSelect | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSelect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Select"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	
	$PanelRight | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Right
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_ConnectionManagerButtonPanel
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_ConnectionManagerButtonPanel 
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.FlowDirection = "TopDown"
		$_.Controls.Add($buttonChangePath)
		$_.Controls.Add($buttonNew)
		$_.Controls.Add($buttonEdit)
		$_.Controls.Add($buttonMerge)
		$_.Controls.Add($buttonSelect)
	}
	$panelMain | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.Controls.Add($panelLeft)
		$_.Controls.Add($panelRight)
	}
	$formNetworkStreamFilesManager | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_ConnectionManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_ConnectionManager
		
		$_.Controls.Add($panelMain)
		$_.Name = "formDialogController"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Networkstream File-Manager"
		
		$_.Font = $Script:FontBase
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsNetworkStreamFilesManagerWindowID
		
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
	
	$formNetworkStreamFilesManager.Add_FormClosing({
		Set-SettingsWindowBounds -ID $script:BoundsNetworkStreamFilesManagerWindowID -FormsBound $formNetworkStreamFilesManager.Bounds

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$listView.Add_MouseDoubleClick({
		Param($Object,$Event)

		if ($Event.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
			$hit = $listView.HitTest($Event.Location)

			if($hit.Item) {
				$Object = $hit.Item.Tag
				
				$script:xmlNetworkStreamFilename = $Object.Filename
				$script:PSVLCRemoteStreamConfigurationPath = (Split-Path $Object.Filename)
				
				$formNetworkStreamFilesManager.close()
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonNew.Add_Click({
	
		$Object = New-VLCRemoteNetworkStreamsManagerDataObject -Filename "Please give a Filename" -Name "Please give a new Name" -Description "Please give a description"

		$NewObject = Edit-VLCRemoteNetworkStreamFileData $Object -Mode "New"
		
		if ($NewObject -ne $null) {
			if ($NewObject.Filename -ne "") {
				$Text = $NewObject.Filename
				$Illegalchars = [string]::join('',([System.IO.Path]::GetInvalidFileNameChars())) -replace '\\','\\'
				$F = $Text -replace "[$illegalchars]",'_'	
				$FullFilename = Join-Path $script:PSVLCRemoteStreamConfigurationPath_Manager ($F+$script:xmlNetworkStreamFilenameExtension)
				
				$xmlDataSet = New-NetworkStreamDataSet -NetworkStreamDataSetName $NetworkStreamDataSetName
		
				$bRetVal = Save-NetworkStreamDataSet -XmlNetworkStreamDataSet $xmlDataSet -XmlNetworkStreamFilename $FullFilename

				$DataObject = New-VLCRemoteNetworkStreamsManagerDataObject -Filename $FullFilename -Name $NewObject.Name -Description $NewObject.Description
				Set-NetworkStreamConfigurationValue $DataObject
				
				#
				# BRUTE FORCE
				#
				Load-FilesDataList $script:PSVLCRemoteStreamConfigurationPath_Manager				
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonEdit.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			$F = (Split-Path $Object.Filename -Leaf)
			$Filename = $F.Substring(0,($F.IndexOf('.')))
			$DataObject = New-VLCRemoteNetworkStreamsManagerDataObject -Filename $Filename -Name $Object.Name -Description $Object.Description
			
			$NewObject = Edit-VLCRemoteNetworkStreamFileData $DataObject -Mode "Edit"
			
			#$NewObject | out-host			
			
			if ($NewObject -ne $null) {
				$Object.Name 		= $NewObject.Name
				$Object.Description = $NewObject.Description
				
				Set-NetworkStreamConfigurationValue $Object
				
				#
				# BRUTE FORCE
				#
				Load-FilesDataList $script:PSVLCRemoteStreamConfigurationPath_Manager
			}
		}	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonMerge.Add_Click({
		Show-ComingSoon
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSelect.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			$script:xmlNetworkStreamFilename = $Object.Filename
			$script:PSVLCRemoteStreamConfigurationPath = (Split-Path $Object.Filename)
			
			$formNetworkStreamFilesManager.close()
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonChangePath.Add_Click({
		
		$NewFolder = Select-FolderDialog "Einen anderen Ort wählen..." $script:PSVLCRemoteStreamConfigurationPath_Manager
		
		if ($NewFolder -ne $Null) {
			$script:PSVLCRemoteStreamConfigurationPath_Manager = $NewFolder
			
			Load-FilesDataList $script:PSVLCRemoteStreamConfigurationPath_Manager
			
			$labelPath.Text = ("Current Path : "+$script:PSVLCRemoteStreamConfigurationPath_Manager)
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Load-FilesDataList $script:PSVLCRemoteStreamConfigurationPath_Manager
	
	$formNetworkStreamFilesManager.ShowDialog() | out-null	
	
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Edit-VLCRemoteNetworkStreamFileData {
[CmdletBinding()]
Param	(
		[Parameter(Mandatory=$true)][PSObject]$NetworkStreamFileData,
		[Parameter(Mandatory=$true)][string]$Mode
		)
	$script:NewNetworkStreamFileData = New-Object PSObject -Property @{
		Filename		= $NetworkStreamFileData.Filename
		Name			= $NetworkStreamFileData.Name
		Description		= $NetworkStreamFileData.Description
	}	
	
	$formDialog			= New-Object System.Windows.Forms.Form	
		$tablePanelDialog = New-Object System.Windows.Forms.TableLayoutPanel
			$PanelTop = New-Object System.Windows.Forms.Panel
				$lblFileName  			= New-Object System.Windows.Forms.Label
				$lblName  			= New-Object System.Windows.Forms.Label
				$lblDescription  	= New-Object System.Windows.Forms.Label
				
				$textboxFileName		= New-Object System.Windows.Forms.Textbox
				$textboxName		= New-Object System.Windows.Forms.Textbox
				$textboxDescription	= New-Object System.Windows.Forms.Textbox
				
			$PanelBottom = New-Object System.Windows.Forms.Panel
				$buttonOK 			= New-Object System.Windows.Forms.Button
				$buttonCancel		= New-Object System.Windows.Forms.Button
	
	$lblDescription.Text = "Beschreibung"
	$lblName.Text	 	 = "Name"
	$lblFileName.Text	 = "Filename"

	
	$textboxDescription.Text = $script:NewNetworkStreamFileData.Description
	$textboxName.Text 		 = $script:NewNetworkStreamFileData.Name
	$textboxFileName.Text 		 = $script:NewNetworkStreamFileData.FileName

	$xPos = 5
	$yPos = 5
	$dist = 3
	$labelWidth = 120
	$labelHeight = 20
	
	$formWidth   = 580
	$formHeight  = 152
	
	$tabIndex	 = 1
	
	$lblFileName, $lblName, $lblDescription | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$ypos += ($labelHeight + $dist)
		$_.TabStop = $false
	}
	$xPos = 5 + $labelWidth + $dist
	$yPos = 5
	$textboxFileName | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(150, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	if ($Mode -eq "Edit") {
		$textboxFileName.ReadOnly = $True
	}
	$textboxName | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(150, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxDescription | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(350, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 


	$panelTop | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelTop"
		$_.TabStop = $false
		$_.Controls.Add($lblFileName)
		$_.Controls.Add($lblName)
		$_.Controls.Add($lblDescription)

		$_.Controls.Add($textboxFileName)
		$_.Controls.Add($textboxName)
		$_.Controls.Add($textboxDescription)
		
	}
	$xPos = 5
	$yPos = 5
	$dist = 3
	$buttonWidth = 120
	$buttonHeight = 20
	$buttonOk | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "OkButton"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Ok"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	}
	$xpos = $xPos + $buttonWidth + $dist
	$buttonCancel | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "CancelButton"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "Cancel"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	}		
	
	$panelBottom | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelBottom"
		$_.TabStop = $false
		$_.Controls.Add($buttonOK)
		$_.Controls.Add($buttonCancel)
	}
	$tablePanelDialog | % {
		$_.Autosize = $True
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ColumnCount = 1
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.Controls.Add($PanelBottom, 0, 1)
		$_.Controls.Add($PanelTop, 0, 0)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Location = New-Object System.Drawing.Point(0, 0)
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.Name = "tablePanelDialog"
		$_.RowCount = 2;
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 30))) | Out-Null
		$_.TabStop = $false
	}		
	$formDialog | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		$_.BackColor = [System.Drawing.Color]::WhiteSmoke

		$_.Controls.Add($tablePanelDialog)
		$_.Name = "formDialog"
		$_.ControlBox = $false
		$_.StartPosition = "CenterScreen"
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		$_.Text = ("$script:ScriptName : Edit File Data") 
		$_.AcceptButton = $buttonOk
		$_.CancelButton = $buttonCancel
	}
	
	$buttonOk.Add_Click({
		$script:NewNetworkStreamFileData.Description	= $textboxDescription.Text
		$script:NewNetworkStreamFileData.Name			= $textboxName.Text
		$script:NewNetworkStreamFileData.Filename		= $textboxFilename.Text
		
		$formDialog.Close()
	})
	$buttonCancel.Add_Click({
		
		$script:NewNetworkStreamFileData = $null
		
		$formDialog.Close()
		
	})	
	$formDialog.ShowDialog() | out-null	
	
	Write-Output $script:NewNetworkStreamFileData
}

#
# ---------------------------------------------------------------------------------------------------------------------------------
#


