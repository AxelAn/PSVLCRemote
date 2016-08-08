#################################################################################################
# Name			: 	PSVLCRemoteGUIConnect.ps1
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
$Script:ConnectionChanged = $false

#region LoadAssemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#endregion LoadAssemblies
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-VLCRemoteConnectionDataObject {
[CmdletBinding()]
Param	(	[String]$Description,
			[string]$HostnameOrIP,
			[string]$Port,
			[string]$Username,
			[string]$Password,
			[string]$UseAutoIP
		)
	$Data = New-Object PSObject -Property @{
		Description		= $Description
		HostnameOrIP	= $HostnameOrIP
		Port			= $Port
		Username		= $Username
		Password		= $Password
		UseAutoIP		= $UseAutoIP
	}
	
	Write-Output $data
}
#
#################################################################################################
#
Function Show-MessageConnectionFailed {
[CmdletBinding()]
Param	(
		[PSObject]$VLCRemoteConnectionData = $null
		)
	$SB = new-Object text.stringbuilder
	$SB = $SB.AppendLine($script:ScriptName)
	$SB = $SB.AppendLine("`n")
	$SB = $SB.AppendLine("Die Verbindung kann nicht hergestellt werden!`n")
	if ($VLCRemoteConnectionData) {
		$SB = $SB.AppendLine("HostnameOrIP: "+$VLCRemoteConnectionData.HostnameOrIP)
		$SB = $SB.AppendLine("Port: "+$VLCRemoteConnectionData.Port)
		$SB = $SB.AppendLine("Password: "+$VLCRemoteConnectionData.Password)
		$SB = $SB.AppendLine("`n")
	}
	$SB = $SB.AppendLine("Mögliche Fehlerquellen könnten sein : Der Rechner kann nicht erreicht werden (Name kann nicht aufgelöst werden, IP-Adresse falsch)")
	$SB = $SB.AppendLine("oder der Rechner läuft überhaupt nicht oder der VLC läuft nicht auf dem Rechner oder das Kennwort ist nicht korrekt...`n")
	$SB = $SB.AppendLine("...oder irgendeine andere Gemeinheit, die sich Computer so ausdenken.`n")

	$d = Show-MessageBox "$script:ScriptName" $SB.toString() "Ok" "Information"
	
	Write-output $d
}
#
#################################################################################################
#
Function Edit-VLCRemoteConnectionData {
[CmdletBinding()]
Param	(
		[Parameter(Mandatory=$true)][PSObject]$VLCRemoteConnectionData
		)
	$ConnectionData = New-Object PSObject -Property @{
		Description		= $VLCRemoteConnectionData.Description
		HostnameOrIP	= $VLCRemoteConnectionData.HostnameOrIP
		Port			= $VLCRemoteConnectionData.Port
		Username		= $VLCRemoteConnectionData.Username
		Password		= $VLCRemoteConnectionData.Password
		UseAutoIP		= $VLCRemoteConnectionData.UseAutoIP
	}	
	
	$formDialog			= New-Object System.Windows.Forms.Form	
		$tablePanelDialog = New-Object System.Windows.Forms.TableLayoutPanel
			$PanelTop = New-Object System.Windows.Forms.Panel
				$lblDescription  	= New-Object System.Windows.Forms.Label
				$lblHostname  	= New-Object System.Windows.Forms.Label
				$lblPort		= New-Object System.Windows.Forms.Label
				$lblPassword  	= New-Object System.Windows.Forms.Label
				$lblUseAutoIP  	= New-Object System.Windows.Forms.Label
				
				$textboxDescription	= New-Object System.Windows.Forms.Textbox
				$textboxHostname	= New-Object System.Windows.Forms.Textbox
				$textboxPort		= New-Object System.Windows.Forms.Textbox
				$textboxPassword	= New-Object System.Windows.Forms.Textbox
				$checkBoxUseAutoIP  = New-Object System.Windows.Forms.CheckBox
				
			$PanelBottom = New-Object System.Windows.Forms.Panel
				$buttonOK 			= New-Object System.Windows.Forms.Button
				$buttonCancel		= New-Object System.Windows.Forms.Button
	
	$lblDescription.Text = "Beschreibung"
	$lblHostname.Text	 = "Hostname or IP"
	$lblPort.Text		 = "Port"
	$lblPassword.Text	 = "Kennwort"
	$lblUseAutoIP.Text   = "AutoIP"
	
	$textboxDescription.Text = $VLCRemoteConnectionData.Description
	$textboxHostname.Text = $VLCRemoteConnectionData.HostnameOrIP
	$textboxPort.Text = $VLCRemoteConnectionData.Port
	$textboxPassword.Text = $VLCRemoteConnectionData.Password
	$checkBoxUseAutoIP.Checked = if ($VLCRemoteConnectionData.UseAutoIP -eq "1") {$true} else {$false}
	
	$xPos = 5
	$yPos = 5
	$dist = 3
	$labelWidth = 120
	$labelHeight = 20
	
	$formWidth   = 580
	$formHeight  = 152
	
	$tabIndex	 = 1
	
	$lblDescription, $lblHostname, $lblPort,$lblPassword, $lblUseAutoIP  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$ypos += ($labelHeight + $dist)
		$_.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240)
		$_.TabStop = $false
	}
	$xPos = 5 + $labelWidth + $dist
	$yPos = 5
	$textboxDescription | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(350, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxHostname | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(150, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxPort | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(50, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxPassword | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(100, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$checkBoxUseAutoIP | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(100, $labelHeight)
		$ypos += (($labelHeight) + 3)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++	
	}
	$panelTop | % {
		$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::FromArgb(255,255,224,192)
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelTop"
		$_.TabStop = $false
		$_.Controls.Add($lblDescription)
		$_.Controls.Add($lblHostname)
		$_.Controls.Add($lblPort)
		$_.Controls.Add($lblPassword)
		$_.Controls.Add($lblUseAutoIP)
		$_.Controls.Add($textboxDescription)
		$_.Controls.Add($textboxHostname)
		$_.Controls.Add($textboxPort)
		$_.Controls.Add($textboxPassword)
		$_.Controls.Add($checkBoxUseAutoIP)
		
	}
	$xPos = 5
	$yPos = 5
	$dist = 3
	$buttonWidth = 120
	$buttonHeight = 20
	$buttonOk | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
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
		$_.BackColor = [System.Drawing.Color]::FromArgb(255,245,245,220)
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
		$_.Text = ("$script:ScriptName : Edit Connection Data") 
		$_.AcceptButton = $buttonOk
		$_.CancelButton = $buttonCancel
	}
	
	$buttonOk.Add_Click({
		$ConnectionData.Description		= $textboxDescription.Text
		$ConnectionData.HostnameOrIP	= $textboxHostname.Text
		$ConnectionData.Port			= $textboxPort.Text
		$ConnectionData.Password		= $textboxPassword.Text
		$ConnectionData.UseAutoIP		= if ($checkBoxUseAutoIP.Checked) {"1"} else {"0"}
		
		$formDialog.Close()
	})
	$buttonCancel.Add_Click({
		
		$formDialog.Close()
		
	})	
	$formDialog.ShowDialog() | out-null	
	
	Write-Output $ConnectionData
}
#
#################################################################################################
#
Function Manage-VLCRemoteConnections {
[CmdletBinding()]
Param	()

	Function Load-ConnectionList {
	[CmdletBinding()]
	Param	(
			)
		$DefaultConnectionID = $Script:DummyID
		
		if ($script:xmlconfig.Tables["Settings"]) {
			$SettingsObject = $script:xmlconfig.Tables["Settings"]
			if ($SettingsObject) {
				$DefaultConnectionID = $SettingsObject[0].DefaultConnectionID
			}
		}
		$listView.BeginUpdate()
		$listView.Items.Clear()
		
		$Connections = $script:xmlconfig.Tables["Connections"].Select()
		#$Connections | ft -autosize | out-host
		
		Foreach($C in $Connections) {
			$T = $C.Description 
			if ($C.ID -eq $DefaultConnectionID) {$T += " [Default]"}
			$item = new-object System.Windows.Forms.ListViewItem($T)
			$item.SubItems.Add("---") | out-null		
			$item.SubItems.Add($C.HostnameOrIP)  | out-null				
			$item.SubItems.Add($C.Port)  | out-null		
			
			$item.tag = $C
			$listView.Items.Add($item)	| out-null
		}
		$listView.EndUpdate()

	}

	#region OBJECT Definitions	
	$formRemoteConnectionManager		= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.Panel
			$PanelLeft		= New-Object System.Windows.Forms.Panel
				$listView	= New-Object System.Windows.Forms.ListView
			$PanelRight		= New-Object System.Windows.Forms.FlowLayoutPanel
				$buttonNew			= New-Object System.Windows.Forms.Button
				$buttonEdit			= New-Object System.Windows.Forms.Button
				$buttonDelete		= New-Object System.Windows.Forms.Button
				$buttonSetAsDefault	= New-Object System.Windows.Forms.Button
				$buttonRemoveDefault	= New-Object System.Windows.Forms.Button
				$buttonTest			= New-Object System.Windows.Forms.Button
				$buttonConnect		= New-Object System.Windows.Forms.Button


	$borderDist  = 5
	$dist = 3
	
	$ButtonWidth = 120 
	$ButtonHeight = 21
	
	$formWidth = 385 + (4*$BorderDist) + $buttonWidth
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
		$_.BackColor = [System.Drawing.Color]::Wheat
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		#$_.Size = New-Object System.Drawing.Size(($listViewWidth),($listViewHeight))
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.HeaderStyle = "NonClickable"
		$_.FullRowSelect = $True
		$_.GridLines = $True
		$_.HideSelection = $False
		$_.MultiSelect = $false		
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
	}	
	$listView.Clear()
	$listView.Columns.Add("Bechreibung",180) | out-null
	$listView.Columns.Add("Test",60) | out-null
	$listView.Columns.Add("Server",100) | out-null
	$listView.Columns.Add("Port",50) | out-null

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
	}
	$xPos = $borderDist
	$yPos = $borderDist
	$buttonNew | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonNew"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "New"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonEdit | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonEdit"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Edit"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonDelete | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonDelete"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Delete"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonSetAsDefault | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetAsDefault"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Set as Default"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonRemoveDefault | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonRemoveDefault"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Remove Default"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonTest | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonTest"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Test"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonConnect | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Connect"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	
	$PanelRight | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Right
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelPosition"
		$_.TabStop = $false
		$_.FlowDirection = "TopDown"
		$_.Controls.Add($buttonNew)
		$_.Controls.Add($buttonEdit)
		$_.Controls.Add($buttonDelete)
		$_.Controls.Add($buttonSetAsDefault)
		$_.Controls.Add($buttonRemoveDefault)
		$_.Controls.Add($buttonTest)
		$_.Controls.Add($buttonConnect)

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
	$formRemoteConnectionManager | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.Controls.Add($panelMain)
		$_.Name = "formDialogController"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Connection manager"
		
		$_.Font = $Script:FontBase
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsConnectionManagerWindowID
		
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
	
	$formRemoteConnectionManager.Add_FormClosing({
		Set-SettingsWindowBounds -ID $script:BoundsConnectionManagerWindowID -FormsBound $formRemoteConnectionManager.Bounds

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$listView.Add_MouseDoubleClick({
		Param($Object,$Event)

		if ($Event.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
			$hit = $listView.HitTest($Event.Location)

			if($hit.Item) {
				$Object = $hit.Item.Tag

				
				Connect-RemoteHost $Object
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Function Connect-RemoteHost {
		Param (
				[PsObject]$Object
			  )
	
		#$Object | out-host
		
		$ConnectionData = New-VLCRemoteConnectionDataObject `
								-Description $Object.Description `
								-HostnameOrIP $Object.HostnameOrIP `
								-Port $Object.Port `
								-Username "" `
								-Password $Object.Password `
								-UseAutoIP $Object.UseAutoIP
		
		$RemoteController = New-VLCRemoteController `
								-HostnameOrIP $ConnectionData.HostnameOrIP `
								-Port $ConnectionData.Port `
								-Username $ConnectionData.Username `
								-Password $ConnectionData.Password 	`
								-UseAutoIP $ConnectionData.UseAutoIP
								
		$Status = Get-VLCRemote-Status -VLCRemoteController $RemoteController
		
		#$Status | out-host
		if ($status -ne $null) {
			$script:VLCRemoteConnectionData = $ConnectionData
			$script:VLCRemoteController = $RemoteController
			
			$script:CommonVLCRemoteController = $RemoteController
			$Script:ConnectionChanged = $True
			
			$formRemoteConnectionManager.Close()
			
		} else {
			Show-MessageConnectionFailed  $ConnectionData
		}	
	
	}
	$buttonNew.Add_Click({
			$ConnectionData = New-VLCRemoteConnectionDataObject `
							-Description "" `
							-HostnameOrIP "" `
							-Port "8080" `
							-Username "" `
							-Password "" `
							-UseAutoIP "0"
		
			$ConnectionData = Edit-VLCRemoteConnectionData $ConnectionData
			
			if (($ConnectionData.Description -ne "") -and ($ConnectionData.HostnameOrIP -ne "")) {
				Save-ConnectionData -ID $script:DummyID -Data $ConnectionData
				
				Load-ConnectionList
			}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonEdit.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			$ConnectionData = New-VLCRemoteConnectionDataObject `
							-Description $Object.Description `
							-HostnameOrIP $Object.HostnameOrIP `
							-Port $Object.Port `
							-Username "" `
							-Password $Object.Password `
							-UseAutoIP $Object.UseAutoIP
		
			$ConnectionData = Edit-VLCRemoteConnectionData $ConnectionData
			
			Save-ConnectionData -ID $Object.ID -Data $ConnectionData
			
			Load-ConnectionList
		}
	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonDelete.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			Remove-ConnectionData -ID $Object.ID
			
			Load-ConnectionList
		}
	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetAsDefault.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag	
		
			Set-DefaultConnection -ID $Object.ID
			
			Load-ConnectionList
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonRemoveDefault.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag	
		
			Remove-DefaultConnection
			
			Load-ConnectionList
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$buttonTest.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			$IsValidConnection = Test-Connection -HostnameOrIP $Object.HostnameOrIP -Port $Object.Port -Password $Object.Password
			
			$listView.SelectedItems[0].SubItems[1].Text = if ($IsValidConnection) {"OK"} else {"FAILED"}
			
			
			if (!$IsValidConnection) { Show-MessageConnectionFailed $Object }

		}	

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonConnect.Add_Click({
		if ($listView.SelectedItems -and (($listView.SelectedItems).Count -gt 0) ) {
			$Object = $listView.SelectedItems[0].Tag
			
			Connect-RemoteHost $Object

		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	$Script:ConnectionChanged = $false
	
	Load-ConnectionList
	
	$formRemoteConnectionManager.ShowDialog() | out-null	
	
	
}
#
#################################################################################################
#
