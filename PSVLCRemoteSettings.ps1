#################################################################################################
# Name			: 	PSVLCRemoteSettings.ps1
# Description	: 	
# Author		: 	Axel Pokrandt (-XP)
# License		:	
# Date			: 	20.11.2015 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Set-StrictMode -Version Latest	
# Change: 
#			0.1.0		20.11.2015	First Version ...
#
#################################################################################################
#
# Globals
#
#region LoadAssemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#endregion LoadAssemblies

#region ScriptVariables

#Configuration Variables
$script:xmlConfigFilename = Join-Path $script:PSVLCRemoteScriptConfigurationPath "PSVLCRemote.config.xml"
$script:ConfigurationDataSetName = "PSVLCRemote"
$script:xmlConfig = New-Object System.Data.DataSet($script:ConfigurationDataSetName)

$script:DummyID = "00000000-0000-0000-0000-000000000000"

# Window ID for Bounds-Settings
$script:BoundsMainWindowID					= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00001"
$script:BoundsPlaylistWindowID				= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00002"
$script:BoundsExplorerWindowID				= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00003"
$script:BoundsConnectionManagerWindowID		= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00004"
$script:BoundsNetworkStreamManagerWindowID	= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00005"
$script:BoundsNetworkStreamFavoriteWindowID	= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00006"
$script:BoundsPlaySettingsWindowID			= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00007"
$script:BoundsSettingsDialogWindowID		= "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00008"

#region OPACITY_SETTINGS
$script:Opacity_Activated_Main				= 1.0
$script:Opacity_Deactivate_Main				= 1.0		# 0.45

$script:Opacity_Activated_Playlist			= 1.0
$script:Opacity_Deactivate_Playlist			= 1.0		# 0.45

$script:Opacity_Activated_Fileexplorer		= 1.0
$script:Opacity_Deactivate_Fileexplorer		= 1.0		# 0.45

$script:Opacity_Activated_Networkstreams	= 1.0
$script:Opacity_Deactivate_Networkstreams	= 1.0		# 0.45
#endregion OPACITY_SETTINGS

#region PLAYER_SETTINGS
$script:UseMarqueeOnMainPlayer				= $True

#endregion PLAYER_SETTINGS

$script:formSettingsDialog	= $Null

#endregion ScriptVariables
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-UINT32ValueFromText {
[CmdletBinding()]
Param	(
			[Parameter(ValueFromPipeline=$True)][System.String]$txtValue,
			[Parameter()][System.UInt32]$DefaultValue,
			[Parameter()][System.UInt32]$MinValue,
			[Parameter()][System.UInt32]$MaxValue
		)
	BEGIN {
		[System.UInt32]$UInt32Value = 0
	}
	PROCESS {
		if ([System.String]::IsNullOrEmpty($txtValue)) {$txtValue = "0"}
		$ParseValid = [System.UInt32]::TryParse($txtValue,([ref]$Uint32Value))
		
		if ($ParseValid) {
			if ($PSBoundParameters.ContainsKey("MinValue")) {
				if ($UInt32Value -lt $MinValue) {
					$UInt32Value = $MinValue
				}
			}
			if ($PSBoundParameters.ContainsKey("MaxValue")) {
				if ($UInt32Value -gt $MaxValue) {
					$UInt32Value = $MaxValue
				}			
			}
		} else {
			if ($PSBoundParameters.ContainsKey("DefaultValue")) {
				$UInt32Value = $DefaultValue
			} else {
				# TryParse writes 0 to [ref]Value on error
			}
		}
	}
	END {
		Write-Output $UInt32Value
	}
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Load-AllScriptSettingValues {
[CmdletBinding()]
Param	()

	$script:RefreshTimerIntervalSeconds 			= Get-ScriptSettingsValue "RefreshTimerIntervalSeconds" -DefaultValue $script:RefreshTimerIntervalSeconds		
	$script:RefreshTimerIntervalFailureSeconds		= Get-ScriptSettingsValue "RefreshTimerIntervalFailureSeconds" -DefaultValue $script:RefreshTimerIntervalFailureSeconds
	$script:RefreshFailureCounter 					= Get-ScriptSettingsValue "RefreshFailureCounter"  -DefaultValue $script:RefreshFailureCounter
	$script:RefreshTimerIntervalFailureStopSeconds 	= Get-ScriptSettingsValue "RefreshTimerIntervalFailureStopSeconds" -DefaultValue $script:RefreshTimerIntervalFailureStopSeconds
	$script:RefreshFailureCountStop					= Get-ScriptSettingsValue "RefreshFailureCountStop" -DefaultValue 	$script:RefreshFailureCountStop

	$script:Opacity_Activated_Main 					= (Get-ScriptSettingsValue "Opacity_Activated_Main" -DefaultValue ($script:Opacity_Activated_Main*100))/100
	$script:Opacity_Deactivate_Main 				= (Get-ScriptSettingsValue "Opacity_Deactivate_Main" -DefaultValue ($script:Opacity_Deactivate_Main*100))/100	
	$script:Opacity_Activated_Playlist 				= (Get-ScriptSettingsValue "Opacity_Activated_Playlist"  -DefaultValue ($script:Opacity_Activated_Playlist*100))/100
	$script:Opacity_Deactivate_Playlist				= (Get-ScriptSettingsValue "Opacity_Deactivate_Playlist" -DefaultValue ($script:Opacity_Deactivate_Playlist*100))/100	
	$script:Opacity_Activated_Fileexplorer 			= (Get-ScriptSettingsValue "Opacity_Activated_Fileexplorer"  -DefaultValue ($script:Opacity_Activated_Fileexplorer*100))/100
	$script:Opacity_Deactivate_Fileexplorer 		= (Get-ScriptSettingsValue "Opacity_Deactivate_Fileexplorer" -DefaultValue ($script:Opacity_Deactivate_Fileexplorer*100))/100
	$script:Opacity_Activated_Networkstreams 		= (Get-ScriptSettingsValue "Opacity_Activated_Networkstreams" -DefaultValue ($script:Opacity_Activated_Networkstreams*100))/100
	$script:Opacity_Deactivate_Networkstreams		= (Get-ScriptSettingsValue "Opacity_Deactivate_Networkstreams" -DefaultValue ($script:Opacity_Deactivate_Networkstreams*100))/100

	$UInt32Value = Get-ScriptSettingsValue "UseMarqueeOnMainPlayer" -DefaultValue 1
	$script:UseMarqueeOnMainPlayer	= if ($UInt32Value -eq 1) {$True} else {$False}
	
	$Theme = Get-ScriptSettingsValue "Theme" -DefaultValue $script:VLVRemoteCurrentTheme
	Set-VLCRemoteTheme $Theme
}
Function Load-Settings {
[CmdletBinding()]
Param	()

	$script:xmlConfigFilename = Join-Path $script:PSVLCRemoteScriptConfigurationPath "PSVLCRemote.config.xml"

	$retVal = ReLoad-Config -XmlConfigFile $script:xmlConfigFilename -CreateNewIfNeeded:$true

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Save-Settings {
[CmdletBinding()]
Param( )
	
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptName		= $script:ScriptName
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptDate		= $script:ScriptDate
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptVersion	= $script:ScriptVersion
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptAuthor		= $script:ScriptAuthor
	$script:xmlConfig.Tables["Script"].Rows[0].ConfigVersion	= $script:ConfigVersion
	
	#
	# ADD HERE ALL other required settings
	#
	
			
	try {
		$script:xmlConfig.AcceptChanges()
		[void]$script:xmlConfig.WriteXml($script:xmlConfigFilename)
	} catch {
	}

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function ReLoad-Config {
	Param	( [string]$xmlConfigFilename,
			  [switch]$CreateNewIfNeeded=$false
			)
	
	$bRetVal = $false

    if (Test-Path $xmlConfigFilename) { #The config exists, read it.
	
		try {
			$script:xmlConfig.clear()
			$script:xmlConfig = New-Object System.Data.DataSet($script:ConfigurationDataSetName)
			$script:xmlConfig.ReadXml($xmlConfigFilename) | Out-Null
			$script:xmlConfig.AcceptChanges()
			$bRetVal = $true
		} catch {
			Write-Host -fore red "ERROR LOADING FILE $($xmlConfigFilename)" 
			$_ | out-host
		}
	    
		if ($bRetVal -and (Validate-Config $script:xmlConfig)) {
			$script:xmlConfigFilename = $xmlConfigFilename
		} else {
			$bRetVal = $false
		}
	} 	
    if (!$bRetVal) {
		
		if ($CreateNewIfNeeded) {
	
			$script:xmlConfig = Create-NewConfigurationDataSet
			
			try {
				$script:xmlConfig.AcceptChanges()
				[void]$script:xmlConfig.WriteXml($script:xmlConfigFilename)
			} catch {
				$_ | out-host
			}
		}	
	}
	
	$bRetVal 	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Validate-Config{
    param([System.Data.DataSet]$DataSet)
	
    try {
		#Read settings table from the XML dataset.
		$SettingsInfo = $DataSet.Tables["Script"].Rows[0]
	
        if (($SettingsInfo.ScriptName -eq $script:ScriptName) -and
			($SettingsInfo.ScriptAuthor -eq $script:ScriptAuthor) -and
			($SettingsInfo.ConfigVersion -eq $script:ConfigVersion)) {
			
			return $True
		} else {
			return $False
		}
	} catch{ 
		$_ | out-host
		return $False
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Create-NewConfigurationDataSet {
[CmdletBinding()]
Param	(
		)
    #Create a brand new dataset.
    $ConfigurationDataSet = New-Object System.Data.DataSet($script:ConfigurationDataSetName)
	# -------------------------------------------------------------------------------------------------------------------------
	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
	# -------------------------------------------------------------------------------------------------------------------------
	
    #Define table structures for the config tables.
    $htTableStructure_Script = @{
        DataSet=$ConfigurationDataSet
        TableName="Script"
        Columns=@("ScriptName", "ScriptDate", "ScriptVersion", "ScriptAuthor", "ConfigVersion")
    }
    $htTableStructure_Settings = @{
        DataSet=$ConfigurationDataSet
        TableName="Settings"
        Columns=@("DefaultConnectionID")
    }	
	$htTableStructure_Bounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        Columns=@("ID","Name","XPos","YPos","Width","Height","IsSet")
    }
    $htTableStructure_Connections = @{
        DataSet=$ConfigurationDataSet
        TableName="Connections"
        Columns=@(	"ID",
					"Description",
					"HostnameOrIP",	
					"Port",		
					"Password",
					"UseAutoIP")
    }
	
    #Add base configuration tables to the dataset.
    Add-Table @htTableStructure_Script
	Add-Table @htTableStructure_Settings
    Add-Table @htTableStructure_Bounds
    Add-Table @htTableStructure_Connections
    
	# -------------------------------------------------------------------------------------------------------------------------
	
	$htDataScript = @{
        DataSet=$ConfigurationDataSet
        TableName="Script"
        RowData = @{
            ScriptName		= $script:ScriptName
			ScriptDate		= $script:ScriptDate
            ScriptVersion	= $script:ScriptVersion
            ScriptAuthor	= $script:ScriptAuthor
			ConfigVersion 	= $script:ConfigVersion
        }
    }
	Add-Row @htDataScript
	$htDataSettings = @{
        DataSet=$ConfigurationDataSet
        TableName="Settings"
        RowData = @{
            DefaultConnectionID	= $NewConnectionGUID
        }
    }
	Add-Row @htDataSettings
    $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsMainWindowID
			Name		= "MainWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= "-1"
			Height		= "-1"
			IsSet		= "0"
        }
    }

    Add-Row @htDataBounds	
    $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsPlaylistWindowID
			Name		= "PlaylistWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= "0"
			Height		= "0"
			IsSet		= "0"
        }
    }
    Add-Row @htDataBounds	
   $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsExplorerWindowID
			Name		= "ExplorerWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= "0"
			Height		= "0"
			IsSet		= "0"
        }
    }
   Add-Row @htDataBounds	

   $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsConnectionManagerWindowID
			Name		= "ConnectionManagerWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= "0"
			Height		= "0"
			IsSet		= "0"
        }
    }
   Add-Row @htDataBounds
 
   $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsNetworkStreamManagerWindowID
			Name		= "NetworkStreamManagerWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= "0"
			Height		= "0"
			IsSet		= "0"
        }
    }
   Add-Row @htDataBounds
   
	$htDataConnections = @{
        DataSet=$ConfigurationDataSet
        TableName="Connections"
        RowData = @{
            ID				= $NewConnectionGUID
			Description		= "LOCALHOST"
			HostnameOrIP	= "LOCALHOST"
			Port			= "8080"
			Password		= "1234"
			UseAutoIP		= "1"		
        }
    }
   Add-Row @htDataConnections
    
	Write-Output $ConfigurationDataSet
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Add-Table {
    Param(	[System.Data.Dataset]$DataSet,
			[string]$TableName,
			[array]$Columns)
			
    $dtTable = New-Object System.Data.DataTable($TableName)
    $dtTable.Columns.AddRange(@($Columns))
    $DataSet.Tables.Add($dtTable)
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Add-Row {
    Param(	[System.Data.DataSet]$DataSet,
			[string]$TableName,
			[hashtable]$RowData)
			
    $NewRow = $DataSet.Tables[$TableName].NewRow()
    $RowData.keys | % {$NewRow.$_ = $RowData.$_}
    $DataSet.Tables[$TableName].Rows.Add($NewRow)
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Save-ConnectionData {
[CmdletBinding()]
Param	(
			[string]$ID,
			[PSObject]$Data
		)

	$Connection = $script:xmlconfig.Tables["Connections"].Select(("ID = '"+$ID+"'"))
	
	if ($Connection) {
		#$Connection[0].ID = $ID
		$Connection[0].Description		= $Data.Description
		$Connection[0].HostnameOrIP		= $Data.HostnameOrIP
		$Connection[0].Port				= $Data.Port
		$Connection[0].Password			= $Data.Password
		$Connection[0].UseAutoIP		= $Data.UseAutoIP
		
		$Connection.AcceptChanges()
	} else {
		$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
		
		$htDataConnection = @{
			DataSet=$script:xmlconfig
			TableName="Connections"
			RowData = @{
				ID				= $NewConnectionGUID
				Description		= $Data.Description
				HostnameOrIP	= $Data.HostnameOrIP
				Port			= $Data.Port
				Password		= $Data.Password
				UseAutoIP		= $Data.UseAutoIP
			}
		}
		Add-Row @htDataConnection
	}
	Save-Settings	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Remove-ConnectionData {
[CmdletBinding()]
Param	(
			[string]$ID
		)
	$Connection = $script:xmlconfig.Tables["Connections"].Select(("ID = '"+$ID+"'"))
	
	if ($Connection) {
		$Connection.Delete()
		$Connection.AcceptChanges()
		
		Save-Settings
	}
		
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-DefaultConnection {
[CmdletBinding()]
Param	(
			[string]$ID
		)
	$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
	if ($SettingsObject) {
#		if ($SettingsObject[0].DefaultConnectionID) {
			$SettingsObject[0].DefaultConnectionID = $ID
#		}
		$SettingsObject.AcceptChanges()
		
		Save-Settings
	} 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Remove-DefaultConnection {
[CmdletBinding()]
Param	(
		)
	$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
	if ($SettingsObject) {
		$SettingsObject[0].DefaultConnectionID = ""
		$SettingsObject.AcceptChanges()
		
		Save-Settings
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-SettingsWindowBoundsObject {
[CmdletBinding()]
Param	(
			[string]$ID
		)
		
	$Bounds = New-Object PSObject -Property @{
            ID			= $ID
			Name		= ""
			XPos		= 0
			YPos		= 0
			Width		= -1
			Height		= -1
			IsSet		= "0"	
	}
	Write-Output $Bounds
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-SettingsWindowBounds {
[CmdletBinding()]
Param	(
			[string]$ID
		)
		
	$Bounds = New-SettingsWindowBoundsObject -ID $ID
	
	$SettingsObject = $script:xmlconfig.Tables["Bounds"].Select(("ID = '"+$ID+"'"))
		
	if ($SettingsObject) {
		
		$Bounds.ID			= $SettingsObject[0].ID
		$Bounds.Name		= $SettingsObject[0].Name
		$Bounds.XPos		= [int]$SettingsObject[0].XPos
		$Bounds.YPos		= [int]$SettingsObject[0].YPos
		$Bounds.Width		= [int]$SettingsObject[0].Width
		$Bounds.Height		= [int]$SettingsObject[0].Height
		$Bounds.IsSet		= $SettingsObject[0].IsSet
		
		$WorkingArea = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -eq 'True'} | Select-Object -Expand WorkingArea
		$ScreenWidth = $WorkingArea.Width
		$ScreenHeight = $WorkingArea.Height
		
		if (($Bounds.XPos -gt $ScreenWidth) -or ($Bounds.XPos -lt 0)) {$Bounds.XPos = 0}
		if (($Bounds.YPos -gt $ScreenHeight) -or ($Bounds.YPos -lt 0)) {$Bounds.YPos = 0}
	
	}
	
	Write-Output $Bounds
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-SettingsWindowBounds {
[CmdletBinding()]
Param	(
			[string]$ID,
			[System.Drawing.Rectangle]$FormsBound
		)
		
	$SettingsObject = $script:xmlconfig.Tables["Bounds"].Select(("ID = '"+$ID+"'"))
		
	if ($SettingsObject) {
	
		$SettingsObject[0].XPos   = [String]$FormsBound.X
		$SettingsObject[0].YPos   = [String]$FormsBound.Y
		$SettingsObject[0].Width  = [String]$FormsBound.Width
		$SettingsObject[0].Height = [String]$FormsBound.Height
		$SettingsObject[0].IsSet  = [string]"1"
		$SettingsObject.AcceptChanges()	
		
	} else {
	
		$htDataBounds = @{
			DataSet=$script:xmlConfig
			TableName="Bounds"
			RowData = @{
				ID			= $ID
				Name		= ""
				XPos		= [String]$FormsBound.X
				YPos		= [String]$FormsBound.Y
				Width		= [String]$FormsBound.Width
				Height		= [String]$FormsBound.Height
				IsSet		= "1"
			}
		}

		Add-Row @htDataBounds	
	}

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-ScriptSettingsValue {
[CmdletBinding()]
Param	(
			[string]$SettingsName,
			$SettingsValue
		)
	if ($script:xmlconfig.Tables["Settings"]) {
		if ( !($script:xmlconfig.Tables["Settings"].Columns.Contains($SettingsName))) {
			$script:xmlconfig.Tables["Settings"].Columns.Add($SettingsName)
			$script:xmlConfig.AcceptChanges()
		} 
		$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
		if ($SettingsObject) {
			$SettingsObject[0].($SettingsName) = $SettingsValue
			$SettingsObject.AcceptChanges()
		}
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-ScriptSettingsValue {
[CmdletBinding()]
Param	(
			[string]$SettingsName,
			$DefaultValue
		)
	$SettingsValue = $DefaultValue
	
	if ($script:xmlconfig.Tables["Settings"]) {
		if ( $script:xmlconfig.Tables["Settings"].Columns.Contains($SettingsName)) {
			$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
			if ($SettingsObject) {
				$SettingsValue = $SettingsObject[0].($SettingsName)
			}
		}
	}

	Write-Output $SettingsValue
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Show-SettingsDialog {
[CmdletBinding()]
Param	(

		)
	# ---------------------------------------------------------------------------------------------------------------------
	$script:formSettingsDialog		= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.TableLayoutPanel
			$lblVersion  				= New-Object System.Windows.Forms.Label
			$PanelConnectionSettings	= New-Object System.Windows.Forms.Panel
				$lblTextConnectionSettings	= New-Object System.Windows.Forms.Label
					$lblRefreshTick  		= New-Object System.Windows.Forms.Label
					$textBoxRefreshTick	 	= New-Object System.Windows.Forms.Textbox

					$lblRefreshTickFailure		= New-Object System.Windows.Forms.Label
					$textBoxRefreshTickFailure 	= New-Object System.Windows.Forms.Textbox
					
					$lblRefreshTickFailureCount	= New-Object System.Windows.Forms.Label
					$textBoxRefreshFailureCount	= New-Object System.Windows.Forms.Textbox
					
					$lblRefreshTickFailureStop	= New-Object System.Windows.Forms.Label
					$textBoxRefreshFailureStop	= New-Object System.Windows.Forms.Textbox

					$lblRefreshTickFailureStopCount	= New-Object System.Windows.Forms.Label
					$textBoxRefreshFailureStopCount	= New-Object System.Windows.Forms.Textbox
			$PanelInterfaceSettings	= New-Object System.Windows.Forms.Panel
				$lblTextInterfaceSettings	= New-Object System.Windows.Forms.Label

					$lblOpacityActivated_MAIN  		= New-Object System.Windows.Forms.Label
					$textBoxOpacityActivated_MAIN 	= New-Object System.Windows.Forms.Textbox
					$lblOpacityDeactivate_MAIN		= New-Object System.Windows.Forms.Label
					$textBoxOpacityDeactivate_MAIN 	= New-Object System.Windows.Forms.Textbox

					$lblOpacityActivated_PLAYLIST  		= New-Object System.Windows.Forms.Label
					$textBoxOpacityActivated_PLAYLIST 	= New-Object System.Windows.Forms.Textbox
					$lblOpacityDeactivate_PLAYLIST		= New-Object System.Windows.Forms.Label
					$textBoxOpacityDeactivate_PLAYLIST 	= New-Object System.Windows.Forms.Textbox
					
					$lblOpacityActivated_EXPLORER  		= New-Object System.Windows.Forms.Label
					$textBoxOpacityActivated_EXPLORER 	= New-Object System.Windows.Forms.Textbox
					$lblOpacityDeactivate_EXPLORER		= New-Object System.Windows.Forms.Label
					$textBoxOpacityDeactivate_EXPLORER 	= New-Object System.Windows.Forms.Textbox
					
					$lblOpacityActivated_NETWORKSTREAMS		= New-Object System.Windows.Forms.Label
					$textBoxOpacityActivated_NETWORKSTREAMS	= New-Object System.Windows.Forms.Textbox
					$lblOpacityDeactivate_NETWORKSTREAMS	= New-Object System.Windows.Forms.Label
					$textBoxOpacityDeactivate_NETWORKSTREAMS= New-Object System.Windows.Forms.Textbox
					
					$checkboxUseMarqueeOnMainPlayer			= New-Object System.Windows.Forms.Checkbox
					
					$lblTheme						  		= New-Object System.Windows.Forms.Label
					$comboBoxTheme							= New-Object System.Windows.Forms.ComboBox
		$PanelBottom = New-Object System.Windows.Forms.Panel
			$buttonSet = New-Object System.Windows.Forms.Button		
	# ---------------------------------------------------------------------------------------------------------------------
	$formWidth = 540
	$formHeight = 500 
	$dist = 3
	$labelWidth = 190
	$labelHeight = 22
	$buttonWidth = 120
	$buttonHeight = 20
	
	$consoleFont = New-Object System.Drawing.Font("Lucida Console", 9, [System.Drawing.FontStyle]::Regular)
	
	$FontBig   = New-Object System.Drawing.Font("Segoe UI",11, [System.Drawing.FontStyle]::Bold)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$labelWidthHeader = $formWidth - 10
	$tmpLabel = New-Object System.Windows.Forms.Label
	$g = $tmpLabel.CreateGraphics()
		
	$sf = $g.MeasureString("Allgemein",$FontBig,$labelWidthHeader)
	$labelHeightHeader = [math]::round($sf.Height)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# ---------------------------------------------------------------------------------------------------------------------	
	$xPos = 0
	$YPos = 0
	$lblVersion  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(($FormWidth-10),170)
		$_.Margin = New-Object System.Windows.Forms.Padding (5)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.BorderStyle = "FixedSingle"
		$_.TabStop = $false
		$_.Text = $Script:VersionText
		$_.Font = $consoleFont
	}
	# ---------------------------------------------------------------------------------------------------------------------	
#region CONNECTION SETTINGS
	$xPos = 5
	$YPos = 0
	$lblTextConnectionSettings  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(($FormWidth-10),$labelHeightHeader)
		$_.Margin = New-Object System.Windows.Forms.Padding (5,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Font = $FontBig
		$_.TabStop = $false
		$_.Text = "Connection"
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$xPos = 5
	$yPos += ($labelHeightHeader + $dist)
	$lblRefreshTick | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (5,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Refresh on Alive (Sec)"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxRefreshTick  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]$script:RefreshTimerIntervalSeconds
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblRefreshTickFailure | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (5,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Refresh on Failure (Sec)"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxRefreshTickFailure  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]$script:RefreshTimerIntervalFailureSeconds
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$xPos +=(40 + $dist)
	$lblRefreshTickFailureCount | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Failure Count"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxRefreshFailureCount  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]$script:RefreshFailureCounter
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$yPos += ($labelHeight + $dist)
	$xPos = 5
	$lblRefreshTickFailureStop | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Refresh on Failure Stop (Sec)"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxRefreshFailureStop  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(40, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]$script:RefreshTimerIntervalFailureStopSeconds
	}	
	
	$xPos +=(40 + $dist)
	$lblRefreshTickFailureStopCount | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Failure Stop Count"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxRefreshFailureStopCount  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]$script:RefreshFailureCountStop
	}	

	
	$PanelConnectionSettings | % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.TabStop = $false
		$_.Controls.Add($lblTextConnectionSettings)
		$_.Controls.Add($lblRefreshTick)
		$_.Controls.Add($textBoxRefreshTick)		
		$_.Controls.Add($lblRefreshTickFailure)
		$_.Controls.Add($textBoxRefreshTickFailure)		
		$_.Controls.Add($lblRefreshTickFailureCount)
		$_.Controls.Add($textBoxRefreshFailureCount)
		$_.Controls.Add($lblRefreshTickFailureStop)
		$_.Controls.Add($textBoxRefreshFailureStop)		
		$_.Controls.Add($lblRefreshTickFailureStopCount)
		$_.Controls.Add($textBoxRefreshFailureStopCount)	
				
	}
	# ---------------------------------------------------------------------------------------------------------------------	
#endregion CONNECTION SETTINGS
	# ---------------------------------------------------------------------------------------------------------------------	
#region INTERFACE Settings
	$xPos = 5
	$YPos = 0
	$lblTextInterfaceSettings  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(($FormWidth-10),$labelHeightHeader)
		$_.Margin = New-Object System.Windows.Forms.Padding (5,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Font = $FontBig
		$_.TabStop = $false
		$_.Text = "Interface"
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$yPos += ($labelHeightHeader + $dist)
	$xPos = 5
	$lblOpacityActivated_MAIN | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Player : Activated"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityActivated_MAIN  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(40, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Activated_Main*100.0))
	}	
	
	$xPos +=(40 + $dist)
	$lblOpacityDeactivate_MAIN | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Player : Deactivate"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityDeactivate_MAIN  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Deactivate_Main*100.0))
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$yPos += ($labelHeight + $dist)
	$xPos = 5
	$lblOpacityActivated_PLAYLIST | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Playlist : Activated"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityActivated_PLAYLIST  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(40, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Activated_Playlist*100.0))
	}	
	
	$xPos +=(40 + $dist)
	$lblOpacityDeactivate_PLAYLIST | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Playlist : Deactivate"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityDeactivate_PLAYLIST  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Deactivate_Playlist*100.0))
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$yPos += ($labelHeight + $dist)
	$xPos = 5
	$lblOpacityActivated_EXPLORER | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Explorer : Activated"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityActivated_EXPLORER  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(40, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Activated_Fileexplorer*100.0))
	}	
	$xPos +=(40 + $dist)
	$lblOpacityDeactivate_EXPLORER | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Explorer : Deactivate"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityDeactivate_EXPLORER  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Deactivate_Fileexplorer*100.0))
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$yPos += ($labelHeight + $dist)
	$xPos = 5
	$lblOpacityActivated_NETWORKSTREAMS | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Streams : Activated"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityActivated_NETWORKSTREAMS  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(40, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Activated_Networkstreams*100.0))
	}	
	$xPos +=(40 + $dist)
	$lblOpacityDeactivate_NETWORKSTREAMS | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Opacity (%) Streams : Deactivate"
	}
	$xPos +=($labelWidth + $dist)
	$textBoxOpacityDeactivate_NETWORKSTREAMS  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(30, $labelHeight)
		$_.TabStop = $false
		$_.Text = [string]([int]([double]$script:Opacity_Deactivate_Networkstreams*100.0))
	}	
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$checkboxUseMarqueeOnMainPlayer   | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(180, $labelHeight)
		$_.TabStop = $false
		$_.Text = "Use Marquee On MainPlayer"
		$_.Checked = if ($script:UseMarqueeOnMainPlayer) {$True} else {$False}
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$xPos = 5
	$yPos += ($labelHeight + $dist)
	$lblTheme | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
		$_.Text = "Theme (Restart required)"
	}
	$xPos +=($labelWidth + $dist)
	$comboBoxTheme| % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(120, $labelHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
		$comboBoxTheme.Items.Clear()
		$comboBoxTheme.Items.AddRange($Script:ThemeList)
		$comboBoxTheme.Text = $script:VLVRemoteCurrentTheme
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$PanelInterfaceSettings | % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.TabStop = $false
		$_.Controls.Add($lblTextInterfaceSettings)
		
		$_.Controls.Add($lblOpacityActivated_MAIN)
		$_.Controls.Add($textBoxOpacityActivated_MAIN)
		$_.Controls.Add($lblOpacityDeactivate_MAIN)
		$_.Controls.Add($textBoxOpacityDeactivate_MAIN)

		$_.Controls.Add($lblOpacityActivated_PLAYLIST)
		$_.Controls.Add($textBoxOpacityActivated_PLAYLIST)
		$_.Controls.Add($lblOpacityDeactivate_PLAYLIST)
		$_.Controls.Add($textBoxOpacityDeactivate_PLAYLIST)		

		$_.Controls.Add($lblOpacityActivated_EXPLORER)
		$_.Controls.Add($textBoxOpacityActivated_EXPLORER)
		$_.Controls.Add($lblOpacityDeactivate_EXPLORER)
		$_.Controls.Add($textBoxOpacityDeactivate_EXPLORER)		

		$_.Controls.Add($lblOpacityActivated_NETWORKSTREAMS)
		$_.Controls.Add($textBoxOpacityActivated_NETWORKSTREAMS)
		$_.Controls.Add($lblOpacityDeactivate_NETWORKSTREAMS)
		$_.Controls.Add($textBoxOpacityDeactivate_NETWORKSTREAMS)	
		
		$_.Controls.Add($checkboxUseMarqueeOnMainPlayer)		

		$_.Controls.Add($lblTheme)		
		$_.Controls.Add($comboboxTheme)		
	}
#endregion INTERFACE Settings
	# ---------------------------------------------------------------------------------------------------------------------	

	# ---------------------------------------------------------------------------------------------------------------------	
#region PANEL BOTTOM
	$XPos = 5
	$YPos = 5
	$buttonSet | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "CancelButton"
		$_.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
		$_.Text = "SET"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $true
	}	
	$PanelBottom | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Size = New-Object System.Drawing.Size($formWidth, (10+$buttonHeight))
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.TabStop = $false
		$_.Controls.Add($buttonSet)
	}
#endregion PANEL BOTTOM
	# ---------------------------------------------------------------------------------------------------------------------	
	$panelMain | % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.TabStop = $false
		$_.AutoScroll = $true
		#$_.FlowDirection = "TopDown"
		#$_.WrapContents = $true
		$_.ColumnCount = 1
		$_.RowCount = 3
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 100))) | Out-Null
		$_.Controls.Add($lblVersion,0,0)
		$_.Controls.Add($PanelConnectionSettings,0,1)
		$_.Controls.Add($PanelInterfaceSettings,0,2)
		
	}
	# ---------------------------------------------------------------------------------------------------------------------	
	$script:formSettingsDialog | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		$_.BackColor = [System.Drawing.Color]::White
		$_.Controls.Add($panelMain)
		$_.Controls.Add($PanelBottom)
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.Name = "formSettingsDialog"
		$_.ControlBox = $true
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $true
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Script Settings"
		
		$_.Font = $Script:FontBase
		
		<#
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsSettingsDialogWindowID
		
		if ($Bounce.IsSet -eq "1") {
			$xpos = [int]$Bounce.XPos
			$ypos = [int]$Bounce.YPos
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.StartPosition = "Manual"
			
		} else {
			$_.StartPosition = "CenterParent"
			$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		}
		#>
		$_.StartPosition = "CenterParent"
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)	
	}

	# ---------------------------------------------------------------------------------------------------------------------	
	$script:formSettingsDialog.Add_FormClosing({
		#
	})
	# ---------------------------------------------------------------------------------------------------------------------	
	$buttonSet.Add_Click({
		#
		[System.UInt32]$UIntValue = 0
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxRefreshTick.Text -MinValue 1 -DefaultValue 1
		$script:RefreshTimerIntervalSeconds = $UIntValue
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxRefreshTickFailure.Text -MinValue 1 -DefaultValue 1
		$script:RefreshTimerIntervalFailureSeconds = $UIntValue
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxRefreshFailureCount.Text -MinValue 2 -DefaultValue 2
		$script:RefreshFailureCounter = $UIntValue
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxRefreshFailureStop.Text -MinValue 1 -DefaultValue 1
		$script:RefreshTimerIntervalFailureStopSeconds = $UIntValue
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxRefreshFailureStopCount.Text  -MinValue 2 -DefaultValue 2
		$script:RefreshFailureCountStop = $UIntValue
		#
		$script:RefreshCounterStatus = 0
		$script:RefreshCounterFailure = 0
		$script:tmrTick.Interval = [System.TimeSpan]::FromSeconds($script:RefreshTimerIntervalSeconds)
		#
		Refresh-Dialog
		#
		# Set back Variables
		#
		$textBoxRefreshTick.Text			= [string]$script:RefreshTimerIntervalSeconds
		$textBoxRefreshTickFailure.Text		= [string]$script:RefreshTimerIntervalFailureSeconds
		$textBoxRefreshFailureCount.Text	= [string]$script:RefreshFailureCounter
		$textBoxRefreshFailureStop.Text 	= [string]$script:RefreshTimerIntervalFailureStopSeconds
		$textBoxRefreshFailureStopCount.Text= [string]$script:RefreshFailureCountStop
		
		Set-ScriptSettingsValue "RefreshTimerIntervalSeconds" 				$script:RefreshTimerIntervalSeconds
		Set-ScriptSettingsValue "RefreshTimerIntervalFailureSeconds" 		$script:RefreshTimerIntervalFailureSeconds
		Set-ScriptSettingsValue "RefreshFailureCounter" 					$script:RefreshFailureCounter
		Set-ScriptSettingsValue "RefreshTimerIntervalFailureStopSeconds" 	$script:RefreshTimerIntervalFailureStopSeconds
		Set-ScriptSettingsValue "RefreshFailureCountStop" 					$script:RefreshFailureCountStop
		#
		# #####################################################################################################################
		#
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityActivated_MAIN.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Activated_Main = [System.Double]([System.Double]$UIntValue/100.0)
	
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityDeactivate_MAIN.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Deactivate_Main = [System.Double]([System.Double]$UIntValue/100.0)
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityActivated_PLAYLIST.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Activated_Playlist = [System.Double]([System.Double]$UIntValue/100.0)
	
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityDeactivate_PLAYLIST.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Deactivate_Playlist = [System.Double]([System.Double]$UIntValue/100.0)
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityActivated_EXPLORER.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Activated_Fileexplorer = [System.Double]([System.Double]$UIntValue/100.0)
	
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityDeactivate_EXPLORER.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Deactivate_Fileexplorer = [System.Double]([System.Double]$UIntValue/100.0)
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityActivated_NETWORKSTREAMS.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Activated_Networkstreams = [System.Double]([System.Double]$UIntValue/100.0)
	
		$UIntValue = Get-UINT32ValueFromText $textBoxOpacityDeactivate_NETWORKSTREAMS.Text  -MinValue 1 -MaxValue 100 -DefaultValue 100
		$script:Opacity_Deactivate_Networkstreams = [System.Double]([System.Double]$UIntValue/100.0)
		
		Set-ScriptSettingsValue "Opacity_Activated_Main" 				($script:Opacity_Activated_Main*100)
		Set-ScriptSettingsValue "Opacity_Deactivate_Main" 				($script:Opacity_Deactivate_Main*100)
		Set-ScriptSettingsValue "Opacity_Activated_Playlist" 			($script:Opacity_Activated_Playlist*100)
		Set-ScriptSettingsValue "Opacity_Deactivate_Playlist" 			($script:Opacity_Deactivate_Playlist*100)
		Set-ScriptSettingsValue "Opacity_Activated_Fileexplorer" 		($script:Opacity_Activated_Fileexplorer*100)
		Set-ScriptSettingsValue "Opacity_Deactivate_Fileexplorer" 		($script:Opacity_Deactivate_Fileexplorer*100)
		Set-ScriptSettingsValue "Opacity_Activated_Networkstreams" 		($script:Opacity_Activated_Networkstreams*100)
		Set-ScriptSettingsValue "Opacity_Deactivate_Networkstreams" 	($script:Opacity_Deactivate_Networkstreams*100)

		$UIntValue = if ($checkboxUseMarqueeOnMainPlayer.Checked) {1} else {0}	
		Set-ScriptSettingsValue "UseMarqueeOnMainPlayer" $UIntValue
		
		$StringValue = $comboboxTheme.Text
		Set-ScriptSettingsValue "Theme" $StringValue		
		
	})
	# ---------------------------------------------------------------------------------------------------------------------	
	# ---------------------------------------------------------------------------------------------------------------------	
	# ---------------------------------------------------------------------------------------------------------------------	
	$script:formSettingsDialog.ShowDialog() | out-null	
	# ---------------------------------------------------------------------------------------------------------------------	
	# ---------------------------------------------------------------------------------------------------------------------	
	# ---------------------------------------------------------------------------------------------------------------------	
	
}

