#################################################################################################
# Name			: 	PSVLCRemoteNetworkStreams.ps1
# Description	: 	
# Author		: 	Axel Pokrandt (-XP)
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
$script:xmlNetworkStreamFilename = Join-Path $script:PSVLCRemoteStreamConfigurationPath "PSVLCRemote.NetworkStream.xml"
$script:NetworkStreamDataSetName = "StreamingStations"

$script:xmlNetworkStreamDataSet = $null

$script:formMainNetworkStreamsManager = $null

$script:TreeViewNetworkStreamsManager = $null
$script:ListViewNetworkStreams = $null
$script:checkboxShowFavorite = $null

$script:SelectNetworkStreamFavoriteTag = $null
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#
# -----------------------------------------------------------------------------
#
Function Select-FileDialog {
  param(	[string]$Title,
			[string]$filename,
			[string]$Directory,
			[string]$Filter="All Files (*.*)|*.*"
		)
	$retFN = $null
	
	$objForm = New-Object System.Windows.Forms.OpenFileDialog
	$objForm.ShowHelp = $true 
	$objForm.Filename = $filename
	$objForm.InitialDirectory = $Directory
	$objForm.Filter = $Filter
	$objForm.Title = $Title

	If ($objForm.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
		$retFN = $objForm.FileName
	} 
	$retFN
}
#
# -----------------------------------------------------------------------------
#
Function Load-NetworkStreamData {
	Param	( 
				[Parameter(Mandatory=$true)][string]$XMLNetworkStreamFilename,
				[Parameter(Mandatory=$true)][string]$NetworkStreamDataSetName
			)

	$xmlNetworkStreamDataSet = $null
	
    if (Test-Path $xmlNetworkStreamFilename) { 
	
		try {
			$xmlNetworkStreamDataSet = New-Object System.Data.DataSet($NetworkStreamDataSetName)
			$xmlNetworkStreamDataSet.ReadXml($xmlNetworkStreamFilename) | Out-Null
			$xmlNetworkStreamDataSet.AcceptChanges()
		} catch {
			
			$xmlNetworkStreamDataSet = $null
			Write-Host -fore red "ERROR LOADING FILE $($script:xmlNetworkStreamFilename)" 
			$_ | out-host
		}
	} 
	if (!$xmlNetworkStreamDataSet) {
		$xmlNetworkStreamDataSet = New-NetworkStreamDataSet -NetworkStreamDataSetName $NetworkStreamDataSetName
		
		$bRetVal = Save-NetworkStreamDataSet -XmlNetworkStreamDataSet $xmlNetworkStreamDataSet -XmlNetworkStreamFilename $XMLNetworkStreamFilename

	}
	Write-Output $xmlNetworkStreamDataSet 	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-NetworkStreamDataSet {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][string]$NetworkStreamDataSetName
		)
    #Create a brand new dataset.
    $NetworkStreamDataSet = New-Object System.Data.DataSet($NetworkStreamDataSetName)
	# -------------------------------------------------------------------------------------------------------------------------
	
	# -------------------------------------------------------------------------------------------------------------------------
	
    $htTableStructure_NetworkStream = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        Columns=@(	"ID",
					"StreamType",
					"Name",
					"URL",	
					"WebSite",		
					"Region",
					"Country",
					"State",
					"City"
					"Genre",
					"Bitrate",
					"Tags",
					"Rate",
					"Annotation",
					"Favorite")
    }
	
    Add-Table @htTableStructure_NetworkStream
    
	# -------------------------------------------------------------------------------------------------------------------------
	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
	$htNetworkStreamData = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        RowData = @{
            ID				= $NewConnectionGUID
			StreamType		= "WebRadio"
			Name			= "Radio Okerwelle"
			URL				= "http://www.okerwelle.de/webradio/live.m3u"
			WebSite			= "http://www.radiookerwelle.de/"
			Region			= "Europe"
			Country			= "Germany"	
			State			= "Niedersachsen"
			City			= "Braunschweig"
			Genre			= "Local Service"
			Bitrate			= "128"
			Rate			= "0"
			Tags			= ""
			Annotation		= ""
			Favorite		= "1"
        }
    }
	Add-Row @htNetworkStreamData
	
	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
 	$htNetworkStreamData = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        RowData = @{
            ID				= $NewConnectionGUID
			StreamType		= "WebRadio"
			Name			= "Radio 38 Braunschweig"
			URL				= "http://stream.radio38.de/bs/mp3-128/stream.radio38.de/play.m3u"
			WebSite			= "http://www.radio38.de"
			Region			= "Europe"
			Country			= "Germany"	
			State			= "Niedersachsen"
			City			= "Braunschweig"			
			Genre			= "Local Service"
			Bitrate			= "128"
			Rate			= "8"
			Tags			= ""			
			Annotation		= ""
			Favorite		= "1"
        }
    }
	Add-Row @htNetworkStreamData
	
	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
 	$htNetworkStreamData = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        RowData = @{
            ID				= $NewConnectionGUID
			StreamType		= "Web Live TV"
			Name			= "Das Erste TV Live"
			URL				= "http://daserste_live-lh.akamaihd.net/i/daserste_de@91204/master.m3u8"
			WebSite			= "http://www.daserste.de/"
			Region			= "Europe"
			Country			= "Germany"	
			State			= ""
			City			= ""			
			Genre			= "Live TV"
			Bitrate			= ""
			Rate			= "0"
			Tags			= ""			
			Annotation		= "See http://live.daserste.de/de/livestream.xml"
			Favorite		= "1"
        }
    }
	Add-Row @htNetworkStreamData 
	
 	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
 	$htNetworkStreamData = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        RowData = @{
            ID				= $NewConnectionGUID
			StreamType		= "Web Live TV"
			Name			= "ZDF TV Live"
			URL				= "http://zdf1314-lh.akamaihd.net/i/de14_v1@392878/master.m3u8?dw=0"
			WebSite			= "http://www.zdf.de/"
			Region			= "Europe"
			Country			= "Germany"	
			State			= ""
			City			= ""			
			Genre			= "Live TV"
			Bitrate			= ""
			Rate			= "0"
			Tags			= ""			
			Annotation		= "See https://wiki.ubuntuusers.de/Internet-TV/Stationen"
			Favorite		= "1"
        }
    }
	Add-Row @htNetworkStreamData 
	
 	$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
 	$htNetworkStreamData = @{
        DataSet=$NetworkStreamDataSet
        TableName="StreamingStations"
        RowData = @{
            ID				= $NewConnectionGUID
			StreamType		= "Web Live TV"
			Name			= "NDR TV Live"
			URL				= "http://ndr_fs-lh.akamaihd.net/i/ndrfs_nds@119224/master.m3u8"
			WebSite			= "http://www.ndr.de/fernsehen/livestream/livestream217.html"
			Region			= "Europe"
			Country			= "Germany"	
			State			= ""
			City			= ""			
			Genre			= "Live TV"
			Bitrate			= ""
			Rate			= "0"
			Tags			= ""			
			Annotation		= ""
			Favorite		= "1"
        }
    }
	Add-Row @htNetworkStreamData
 
 
	Write-Output $NetworkStreamDataSet
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Save-NetworkStreamDataSet {
[CmdletBinding()]
Param( 
		[Parameter(Mandatory=$true)][System.Data.DataSet]$xmlNetworkStreamDataSet,
		[Parameter(Mandatory=$true)][string]$xmlNetworkStreamFilename
	)
	$bRetVal = $true
	try {
		$xmlNetworkStreamDataSet.AcceptChanges()
		[void]$xmlNetworkStreamDataSet.WriteXml($xmlNetworkStreamFilename)
	} catch {
		$bRetVal = $false
	}
	Write-Output $bRetVal
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Save-NetworkStreamData {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][System.Data.DataSet]$xmlNetworkStreamDataSet,
			[Parameter(Mandatory=$true)][string]$xmlNetworkStreamFilename,
			[Parameter(Mandatory=$true)][string]$ID,
			[Parameter(Mandatory=$true)][PSObject]$Data
		)

	$NetworkStream = $xmlNetworkStreamDataSet.Tables["StreamingStations"].Select(("ID = '"+$ID+"'"))
	
	if ($NetworkStream) {
		
		$NetworkStream[0].StreamType = $Data.StreamType
		$NetworkStream[0].Name		= $Data.Name
		$NetworkStream[0].URL		= $Data.URL
		$NetworkStream[0].WebSite	= $Data.WebSite
		$NetworkStream[0].Region	= $Data.Region
		$NetworkStream[0].Country	= $Data.Country
		$NetworkStream[0].State		= $Data.State
		$NetworkStream[0].City		= $Data.City
		$NetworkStream[0].Genre		= $Data.Genre
		$NetworkStream[0].Bitrate	= $Data.Bitrate
		$NetworkStream[0].Rate		= $Data.Rate
		$NetworkStream[0].Tags		= $Data.Tags
		$NetworkStream[0].Annotation= $Data.Annotation
		$NetworkStream[0].Favorite  = $Data.Favorite
		
		$NetworkStream.AcceptChanges()
	} else {
		$NewConnectionGUID = ([string][guid]::NewGuid()).ToUpper()
		
		$htNetworkStreamData = @{
			DataSet = $xmlNetworkStreamDataSet
			TableName="StreamingStations"
			RowData = @{
				ID				= $NewConnectionGUID
				StreamType		= $Data.StreamType
				Name			= $Data.Name
				URL				= $Data.URL
				WebSite			= $Data.WebSite
				Region			= $Data.Region
				Country			= $Data.Country
				State			= $Data.State
				City			= $Data.City
				Genre			= $Data.Genre
				Bitrate			= $Data.Bitrate
				Rate			= $Data.Rate
				Tags			= $Data.Tags
				Annotation		= $Data.Annotation
				Favorite		= $Data.Favorite
			}
		}
		Add-Row @htNetworkStreamData
	}
	Save-NetworkStreamDataSet $xmlNetworkStreamDataSet $xmlNetworkStreamFilename
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Remove-NetworkStreamData {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][System.Data.DataSet]$xmlNetworkStreamDataSet,
			[Parameter(Mandatory=$true)][string]$xmlNetworkStreamFilename,
			[Parameter(Mandatory=$true)][string]$ID
		)
	$NetworkStream = $xmlNetworkStreamDataSet.Tables["StreamingStations"].Select(("ID = '"+$ID+"'"))
	
	if ($NetworkStream) {
		$NetworkStream.Delete()
		$NetworkStream.AcceptChanges()
		
		Save-NetworkStreamDataSet $xmlNetworkStreamDataSet $xmlNetworkStreamFilename
	}
		
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Import-RaimasoftXML {
[CmdletBinding()]
Param	(
			[string]$Filename
		)

	$xmlData = [xml](Get-Content $Filename)
	
	$StreamingStations = $xmlData.SelectNodes("RadioStations/RadioStations")
	
	Foreach ($Station in $StreamingStations) {
		$StationName = $Station.GetAttribute("StationName")
		$StationName | out-Host
		
		$WebSite = $Station.GetAttribute("Website")
		$Genre = $Station.GetAttribute("Genre")
		$Country = $Station.GetAttribute("Country")
		$CountryState = $Station.GetAttribute("CountryState")
		$City = $Station.GetAttribute("City")
		$Tags = $Station.GetAttribute("Tags")
		$Comment = $Station.GetAttribute("Comment")
		$RadioStreams = $Station.SelectNodes("RadioStreams")
		
		Foreach ($Stream in $RadioStreams) {
			$URL = $Stream.GetAttribute("URL")
			$BitRate = $Stream.GetAttribute("Bitrate")
		
		
			$RowData = @{
				ID				= $script:DummyID
				StreamType		= "WebRadio"
				Name			= $StationName
				URL				= $URL
				WebSite			= $WebSite
				Region			= "Europe"
				Country			= $Country
				State			= $CountryState
				City			= $City
				Genre			= $Genre
				Bitrate			= $Bitrate
				Rate			= "0"
				Tags			= $Tags
				Annotation		= $Comment
				Favorite		= "0"
			}
			
			Save-NetworkStreamData $script:xmlNetworkStreamDataSet  $script:xmlNetworkStreamFilename $script:DummyID $RowData
		}
		
	}

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Load-StationList {
[CmdletBinding()]
Param	(
			[switch]$OnlyFavorites=$false
		)

	if ($OnlyFavorites) {
		$StreamingStations = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Favorite = '1'")
	} else {
		$StreamingStations = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select()
	
	}
	$script:ListViewNetworkStreams.BeginUpdate()
	$script:ListViewNetworkStreams.Items.Clear()
	
	foreach ($Station in $StreamingStations) {
		$item = new-object System.Windows.Forms.ListViewItem($Station.Name)
		$item.SubItems.Add($Station.StreamType) | out-null
		
		<#
		$item.SubItems.Add($Station.URL) | out-null
		$item.SubItems.Add($Station.WebSite) | out-null
		
		$item.SubItems.Add($Station.Region) | out-null
		$item.SubItems.Add($Station.Country) | out-null
		$item.SubItems.Add($Station.State) | out-null
		$item.SubItems.Add($Station.City) | out-null
		#>
		$item.SubItems.Add($Station.Genre) | out-null
		$item.SubItems.Add($Station.Bitrate) | out-null
		$item.SubItems.Add($Station.Rate) | out-null
		$item.SubItems.Add($Station.Tags) | out-null
		$item.SubItems.Add($Station.Annotation) | out-null
		$item.SubItems.Add($Station.Favorite) | out-null
	
		$item.tag = $Station
		$script:ListViewNetworkStreams.Items.Add($item)	| out-null

	}
	$script:ListViewNetworkStreams.EndUpdate()

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Edit-VLCRemoteVLCRemoteNetworkStreams {
[CmdletBinding()]
Param	(
		[Parameter(Mandatory=$true)][PSObject]$VLCRemoteNetworkStreamData
		)
	$NetworkStreamData = New-Object PSObject -Property @{
		ID				= $VLCRemoteNetworkStreamData.ID
		StreamType		= $VLCRemoteNetworkStreamData.StreamType
		Name			= $VLCRemoteNetworkStreamData.Name
		URL				= $VLCRemoteNetworkStreamData.URL
		WebSite			= $VLCRemoteNetworkStreamData.WebSite
		Region			= $VLCRemoteNetworkStreamData.Region
		Country			= $VLCRemoteNetworkStreamData.Country
        State			= $VLCRemoteNetworkStreamData.State
		City			= $VLCRemoteNetworkStreamData.City
		Genre			= $VLCRemoteNetworkStreamData.Genre
		Bitrate			= $VLCRemoteNetworkStreamData.Bitrate
		Rate			= $VLCRemoteNetworkStreamData.Rate
		Tags			= $VLCRemoteNetworkStreamData.Tags
		Annotation		= $VLCRemoteNetworkStreamData.Annotation
		Favorite		=  $VLCRemoteNetworkStreamData.Favorite
	}
	
	$formDialog			= New-Object System.Windows.Forms.Form	
		$tablePanelDialog = New-Object System.Windows.Forms.TableLayoutPanel
			$PanelTop = New-Object System.Windows.Forms.Panel
				$lblName  		= New-Object System.Windows.Forms.Label
				$lblStreamType  		= New-Object System.Windows.Forms.Label
				$lblURL  		= New-Object System.Windows.Forms.Label
				$lblWebSite		= New-Object System.Windows.Forms.Label
				$lblRegion  	= New-Object System.Windows.Forms.Label
				$lblCountry  	= New-Object System.Windows.Forms.Label
				$lblState  		= New-Object System.Windows.Forms.Label
				$lblCity  		= New-Object System.Windows.Forms.Label
				$lblGenre		= New-Object System.Windows.Forms.Label
				$lblBitrate  	= New-Object System.Windows.Forms.Label
				$lblRate  		= New-Object System.Windows.Forms.Label
				$lblTags  		= New-Object System.Windows.Forms.Label
				$lblAnnotation  = New-Object System.Windows.Forms.Label
				$lblFavorite    = New-Object System.Windows.Forms.Label

				$textboxName	= New-Object System.Windows.Forms.Textbox
				$comboboxStreamType	 = New-Object System.Windows.Forms.ComboBox
				$textboxUrl		= New-Object System.Windows.Forms.Textbox
				$textboxWebSite	= New-Object System.Windows.Forms.Textbox

				$comboboxRegion	 = New-Object System.Windows.Forms.ComboBox
				$comboboxCountry = New-Object System.Windows.Forms.ComboBox
				$comboboxState	 = New-Object System.Windows.Forms.ComboBox
				$comboboxCity	 = New-Object System.Windows.Forms.ComboBox
				
				$comboboxGenre	 = New-Object System.Windows.Forms.ComboBox
				$textboxBitrate	= New-Object System.Windows.Forms.Textbox
				$comboboxRate	= New-Object System.Windows.Forms.ComboBox
				$textboxTags	= New-Object System.Windows.Forms.Textbox
				$textboxAnnotation	= New-Object System.Windows.Forms.Textbox
				$checkboxFavorite = New-Object System.Windows.Forms.Checkbox
				
			$PanelBottom = New-Object System.Windows.Forms.Panel
				$buttonOK 			= New-Object System.Windows.Forms.Button
				$buttonCancel		= New-Object System.Windows.Forms.Button
	
	$lblName.Text		= "Name" 
	$lblStreamType.Text = "StreamType"	
	$lblURL.Text		= "URL"  		
	$lblWebSite.Text	= "Website"		
	$lblRegion.Text		= "Region"  	
	$lblCountry.Text	= "Country"  
	$lblState.Text		= "State"  		
	$lblCity.Text		= "City"  		
	$lblGenre.Text		= "Genre"		
	$lblBitrate.Text	= "Bitrate"  
	$lblRate.Text		= "Rate"  		
	$lblTags.Text		= "Tags"  		
	$lblAnnotation.Text	= "Annotation"
	$lblFavorite.Text   = "Favorite"
	
	$textboxName.Text		= $NetworkStreamData.Name
	$textboxURL.Text  		= $NetworkStreamData.URL
	$textboxWebSite.Text	= $NetworkStreamData.WebSite
	
	$textboxBitrate.Text 		= $NetworkStreamData.Bitrate
	$textboxTags.Text			= $NetworkStreamData.Tags
	$textboxAnnotation.Text		= $NetworkStreamData.Annotation
	
	$checkboxFavorite.Checked = If ($NetworkStreamData.Favorite -eq "1") {$True} else {$False}
	
	$xPos = 5
	$yPos = 5
	$dist = 3
	$labelWidth = 120
	$labelHeight = 20
	
	$formWidth   = 600
	$formHeight  = 400
	
	$tabIndex	 = 1
	
	
	$lblName,$lblStreamType,$lblURL,$lblWebSite,$lblRegion,$lblCountry,$lblState,$lblCity,$lblGenre,$lblBitrate,$lblRate,$lblTags,$lblAnnotation,$lblFavorite  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$ypos += ($labelHeight + $dist)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.TabStop = $false
	}
	$xPos = 5 + $labelWidth + $dist
	$yPos = 5
	$textboxName | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(350, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$comboboxStreamType | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(200,$labelHeight)
		$_.TabIndex = $tabIndex++
	}
	$textboxUrl | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(450, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxWebSite | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(450, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$comboboxRegion | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(200,$labelHeight)
		$_.TabIndex = $tabIndex++
	}	
	$comboboxCountry | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(300,$labelHeight)
		$_.TabIndex = $tabIndex++
	}	
	$comboboxState | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(300,$labelHeight)
		$_.TabIndex = $tabIndex++
	}	
	$comboboxCity | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(300,$labelHeight)
		$_.TabIndex = $tabIndex++
	}	
	$comboboxGenre | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(300,$labelHeight)
		$_.TabIndex = $tabIndex++
	}	
	$textboxBitrate | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(150, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$comboboxRate | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$ypos += (($labelHeight) + $dist)
		$_.Size = New-Object System.Drawing.Size(80,$labelHeight)
		$_.TabIndex = $tabIndex++
	}		
	$textboxTags | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(450, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$textboxAnnotation | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(450, $labelHeight)
		$ypos += (($labelHeight) + $dist)
		$_.TabStop = $true
		$_.TabIndex = $tabIndex++
	} 
	$checkboxFavorite | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(50, $labelHeight)
		$ypos += (($labelHeight) + $dist)
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
		$_.Controls.Add($lblName)
		$_.Controls.Add($lblStreamType)
		$_.Controls.Add($lblURL)
		$_.Controls.Add($lblWebSite)
		$_.Controls.Add($lblRegion)
		$_.Controls.Add($lblCountry)
		$_.Controls.Add($lblState)
		$_.Controls.Add($lblCity)
		$_.Controls.Add($lblGenre)
		$_.Controls.Add($lblBitrate)
		$_.Controls.Add($lblRate)
		$_.Controls.Add($lblTags)
		$_.Controls.Add($lblAnnotation)
		$_.Controls.Add($lblFavorite)
		
		$_.Controls.Add($textboxName)
		$_.Controls.Add($comboboxStreamType)
		$_.Controls.Add($textboxUrl)
		$_.Controls.Add($textboxWebSite)

		$_.Controls.Add($comboboxRegion)
		$_.Controls.Add($comboboxCountry)
		$_.Controls.Add($comboboxState)
		$_.Controls.Add($comboboxCity)
		
		$_.Controls.Add($comboboxGenre)
		$_.Controls.Add($textboxBitrate)
		$_.Controls.Add($comboboxRate)
		$_.Controls.Add($textboxTags)
		$_.Controls.Add($textboxAnnotation)		
		$_.Controls.Add($checkboxFavorite)		
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
		$_.Autosize = $True
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		$_.BackColor = [System.Drawing.Color]::WhiteSmoke
		$_.Controls.Add($tablePanelDialog)
		$_.Name = "formDialog"
		$_.ControlBox = $false
		$_.StartPosition = "CenterScreen"
		#$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
		$_.Text = ("$script:ScriptName : Edit Network Stream Data") 
		$_.AcceptButton = $buttonOk
		$_.CancelButton = $buttonCancel
	}
	
	$buttonOk.Add_Click({

		$NetworkStreamData.Name 		= $textboxName.Text
		$NetworkStreamData.StreamType 	= $comboboxStreamType.Text
		$NetworkStreamData.Url 			= $textboxUrl.Text
		$NetworkStreamData.WebSite 		= $textboxWebSite.Text
		
		$NetworkStreamData.Bitrate 		= $textboxBitrate.Text
		$NetworkStreamData.Tags 		= $textboxTags.Text
		$NetworkStreamData.Annotation 	= $textboxAnnotation.Text
		
		$NetworkStreamData.Genre 		= $comboboxGenre.Text
		
		$NetworkStreamData.Rate 		= $comboboxRate.Text
		$NetworkStreamData.Favorite = If ($checkboxFavorite.Checked) {"1"} else {"0"}	
		
		$formDialog.Close()
		
	})
	$buttonCancel.Add_Click({
		
		$NetworkStreamData = $null
		$formDialog.Close()
		
	})	
	
	$comboboxRegion.Enabled = $False
	$comboboxCountry.Enabled = $False
	$comboboxState.Enabled = $False
	$comboboxCity.Enabled = $False
	
	$Rates = @("0","1","2","3","4","5","6","7","8","9")
	$comboboxRate.Items.AddRange($Rates)			
	$comboboxRate.SelectedItem = ($NetworkStreamData.Rate)

	$GenreNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Genre <> ''") | Select-Object Genre -Unique | Sort-Object Genre | Select-Object -Expand Genre
	#$GenreNames | out-host
	$comboboxGenre.Items.AddRange($GenreNames)			
	$comboboxGenre.SelectedItem = ($NetworkStreamData.Genre)

	$StreamTypeNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("StreamType <> ''") | Select-Object StreamType -Unique | Sort-Object StreamType | Select-Object -Expand StreamType
	#$GenreNames | out-host
	$comboboxStreamType.Items.AddRange($StreamTypeNames)			
	$comboboxStreamType.SelectedItem = ($NetworkStreamData.StreamType)
	
	$formDialog.ShowDialog() | out-null	
	
	Write-Output $NetworkStreamData
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Show-VLCRemoteNetworkStreamsManagerSimple {
[CmdletBinding()]
Param	(
		)
		

	# ---------------------------------------------------------------------------------------------------------------------
	$script:formMainNetworkStreamsManager		= New-Object System.Windows.Forms.Form
		$PanelMain = New-Object System.Windows.Forms.Panel
			$PanelLeft		= New-Object System.Windows.Forms.Panel
				$script:ListViewNetworkStreams	= New-Object System.Windows.Forms.ListView
			$PanelRight		= New-Object System.Windows.Forms.FlowLayoutPanel
				$buttonNew			= New-Object System.Windows.Forms.Button
				$buttonEdit			= New-Object System.Windows.Forms.Button
				$buttonDelete		= New-Object System.Windows.Forms.Button
				$buttonSetAsFavourite	= New-Object System.Windows.Forms.Button
				$buttonPlay			= New-Object System.Windows.Forms.Button
				$buttonImportXML	= New-Object System.Windows.Forms.Button
				$buttonReload		= New-Object System.Windows.Forms.Button
				$script:checkboxShowFavorite	= New-Object System.Windows.Forms.CheckBox
			$PanelBottom							= New-Object System.Windows.Forms.Panel
				$picBoxTraydown						= New-Object System.Windows.Forms.PictureBox				

	$borderDist  = 5
	$dist = 3
	
	$ButtonWidth = 130 
	$ButtonHeight = 21
	
	$formWidth = 630 + (4*$BorderDist) + $buttonWidth
	$formHeight = 420 
	$labelHeightSingle = 20

	
	$listViewHeight = $formHeight - (2*$BorderDist)
	$listViewWidth  = $formWidth - (4*$BorderDist) - $buttonWidth

	$picboxCOntrolWidth = 36
	$picboxCOntrolWidthSmall = 24
	
	$xPos = $borderDist
	$yPos = $borderDist
	$script:listViewNetworkStreams | % {
		$_.Name = "listView"	
		$_.CheckBoxes = $False
		$_.DataBindings.DefaultDataSourceUpdateMode = 0
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager

		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		#$_.Size = New-Object System.Drawing.Size(($listViewWidth),($listViewHeight))
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.HeaderStyle = "Clickable"
		$_.FullRowSelect = $True
		$_.GridLines = $False
		$_.HideSelection = $False
		$_.MultiSelect = $true		
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
	}	
	$script:ListViewNetworkStreams.Clear()
	$script:ListViewNetworkStreams.Columns.Add("Name",220) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Type",80) | out-null
	<#
	$script:ListViewNetworkStreams.Columns.Add("URL",180) | out-null
	$script:ListViewNetworkStreams.Columns.Add("WebSite",100) | out-null
	
	$script:ListViewNetworkStreams.Columns.Add("Region",60) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Country",70) | out-null
	$script:ListViewNetworkStreams.Columns.Add("State",60) | out-null
	$script:ListViewNetworkStreams.Columns.Add("City",60) | out-null
	#>
	$script:ListViewNetworkStreams.Columns.Add("Genre",90) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Bitrate",50) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Rate",50) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Tags",120) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Annotation",200) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Favorite",30) | out-null

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
		$_.Controls.Add($script:ListViewNetworkStreams)
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
	$buttonSetAsFavourite | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetAsDefault"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Toogle Favorite"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonPlay | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Play"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonImportXML | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Import XML"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonReload | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Reload"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$script:checkboxShowFavorite | % {
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Favorites only"
		$_.TabStop = $false
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager

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
		$_.Controls.Add($buttonSetAsFavourite)
		$_.Controls.Add($buttonPlay)
		$_.Controls.Add($buttonImportXML)
		$_.Controls.Add($buttonReload)
		$_.Controls.Add($script:checkboxShowFavorite)
	}
	$yPos = $borderDist
	$xPos = $FormWidth - $BorderDist - $picboxCOntrolWidthSmall
	$picBoxTraydown  | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Right)
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($picboxCOntrolWidthSmall, $picboxCOntrolWidthSmall)
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)	
		$_.Image = $script:ImageTrayDown
		$_.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
	}
	$PanelBottom | % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Size = New-Object System.Drawing.Size($formWidth, ($picboxCOntrolWidthSmall+(2*$borderDist)))
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManagerBottom
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManagerBottom
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelBottom"
		$_.TabStop = $false
		$_.Controls.Add($picBoxTraydown)
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
		$_.Controls.Add($panelBottom)
	}
	$script:formMainNetworkStreamsManager | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		
		$_.Controls.Add($panelMain)
		$_.Name = "formDialogController"
		$_.ControlBox = $false
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Network Streams Manager"
		
		$_.Font = $Script:FontBase
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsNetworkStreamManagerWindowID
		
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
	$script:formMainNetworkStreamsManager.Add_Activated({
		$script:formMainNetworkStreamsManager.Opacity = $script:Opacity_Activated_Networkstreams
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainNetworkStreamsManager.Add_DeActivate({
		$script:formMainNetworkStreamsManager.Opacity = $script:Opacity_Deactivate_Networkstreams
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$picBoxTraydown.Add_MouseClick({
		$script:formMainNetworkStreamsManager.Visible = $false
	})	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$script:formMainNetworkStreamsManager.Add_FormClosing({

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:ListViewNetworkStreams.Add_MouseDoubleClick({
		Param($Object,$Event)

		if ($Event.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
			$hit = $script:ListViewNetworkStreams.HitTest($Event.Location)

			if($hit.Item) {
				$Object = $hit.Item.Tag
				$script:tmrTick.Stop()
				Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Object.URL
				$script:tmrTick.Start()
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonNew.Add_Click({

		$NetworkStreamData = New-Object PSObject -Property @{
			ID				= $script:DummyID
			StreamType		= "WebRadio"
			Name			= ""
			URL				= ""
			WebSite			= ""
			Region			= ""
			Country			= ""
			State			= ""
			City			= ""
			Genre			= ""
			Bitrate			= ""
			Rate			= "0"
			Tags			= ""
			Annotation		= ""
			Favorite		= "0"
		}

		$NewObject = Edit-VLCRemoteVLCRemoteNetworkStreams $NetworkStreamData

		if ($NewObject) {
			Save-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename $script:DummyID $NewObject
			
			Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked		
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonEdit.Add_Click({
	
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
			$Object = $script:ListViewNetworkStreams.SelectedItems[0].Tag
			
			$NewObject = Edit-VLCRemoteVLCRemoteNetworkStreams $Object

			if ($NewObject) {
				Save-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename ($NewObject.ID) $NewObject
			
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[0].Text = $NewObject.Name
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[1].Text = $NewObject.StreamType
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[2].Text = $NewObject.Genre
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[3].Text = $NewObject.Bitrate
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[4].Text = $NewObject.Rate
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[5].Text = $NewObject.Tags				
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[6].Text = $NewObject.Annotation
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[7].Text = $NewObject.Favorite

			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonDelete.Add_Click({
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
		
			Foreach ($Item in $script:ListViewNetworkStreams.SelectedItems) {
				$Object = $Item.Tag
				$Item.Remove()
				
				Remove-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename ($Object.ID)

			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSetAsFavourite.Add_Click({
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
			Foreach ($Item in $script:ListViewNetworkStreams.SelectedItems) {
				$Object = $Item.Tag
				
				if ($Object.Favorite -eq "0") {
					$Object.Favorite = "1"
				} else {
					$Object.Favorite = "0"
				}
				Save-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename ($Object.ID) $Object
			
				$Item.SubItems[7].Text = $Object.Favorite				

			}
		
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonPlay.Add_Click({
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
			$Object = $script:ListViewNetworkStreams.SelectedItems[0].Tag
			
			Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Object.URL
			
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonImportXML.Add_Click({
	
	
		$Filename = Select-FileDialog "Select File" "" $script:WorkingDirectory "XML Files (*.xml|*.xml"
		if ($FileName) {
			Import-RaimasoftXML $Filename
			Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
		}
	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonReload.Add_Click({
		Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
	})
#region ComparerClass
  $comparerClassString = @"

  using System;
  using System.Windows.Forms;
  using System.Drawing;
  using System.Collections;

  public class ListViewItemComparerWSUSSearchDeclineDeleteUpdates : System.Collections.IComparer 
  { 
    public int col = 0;
    
    public System.Windows.Forms.SortOrder Order; // = SortOrder.Ascending;
  
    public ListViewItemComparerWSUSSearchDeclineDeleteUpdates()
    {
        col = 0;        
    }
    
    public ListViewItemComparerWSUSSearchDeclineDeleteUpdates(int column, bool asc)
    {
        col = column; 
        if (asc) 
        {Order = SortOrder.Ascending;}
        else
        {Order = SortOrder.Descending;}        
    }
    
    public int Compare(object x, object y) // IComparer Member     
    {   
        if (!(x is ListViewItem)) return (0);
        if (!(y is ListViewItem)) return (0);
            
        ListViewItem l1 = (ListViewItem)x;
        ListViewItem l2 = (ListViewItem)y;
            
        if (l1.ListView.Columns[col].Tag == null)
            {
                l1.ListView.Columns[col].Tag = "Text";
            }
        
        if (l1.ListView.Columns[col].Tag.ToString() == "Numeric") 
            {
                float fl1 = float.Parse(l1.SubItems[col].Text);
                float fl2 = float.Parse(l2.SubItems[col].Text);
                    
                if (Order == SortOrder.Ascending)
                    {
                        return fl1.CompareTo(fl2);
                    }
                else
                    {
                        return fl2.CompareTo(fl1);
                    }
             }
         else
             {
                string str1 = l1.SubItems[col].Text;
                string str2 = l2.SubItems[col].Text;
                    
                if (Order == SortOrder.Ascending)
                    {
                        return str1.CompareTo(str2);
                    }
                else
                    {
                        return str2.CompareTo(str1);
                    }
              }     
    }
} 
"@
	Add-Type -TypeDefinition $comparerClassString -ReferencedAssemblies ( 'System.Windows.Forms', 'System.Drawing')
	#endregion ComparerClass      
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	$script:boolSort = $true
	$columnClick = {  
	  $script:ListViewNetworkStreams.ListViewItemSorter = New-Object ListViewItemComparerWSUSSearchDeclineDeleteUpdates($_.Column, $script:boolSort)
	  
	  $script:boolSort = !$script:boolSort
	}
	$script:ListViewNetworkStreams.Add_ColumnClick($columnClick)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:checkboxShowFavorite.Checked = $false
	
	$script:xmlNetworkStreamDataSet = Load-NetworkStreamData $script:xmlNetworkStreamFilename $script:NetworkStreamDataSetName
	
	Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
	
	$script:formMainNetworkStreamsManager.Show() | out-null	
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
<# 
Function Show-VLCRemoteNetworkStreamsManagerExtended {
[CmdletBinding()]
Param	(
		)
		

	# ---------------------------------------------------------------------------------------------------------------------
	
	$script:formMainNetworkStreamsManager			= New-Object System.Windows.Forms.Form
		$PanelMain									= New-Object System.Windows.Forms.Panel
			
			$SplitContainerNetworkStreamsManager	= New-Object System.Windows.Forms.SplitContainer
			
				$PanelTreeNetworkStreamsManager		= New-Object System.Windows.Forms.Panel
					$script:TreeViewNetworkStreamsManager = New-Object System.Windows.Forms.TreeView
				$PanelStreamsNetworkStreamsManager	= New-Object System.Windows.Forms.Panel
					$script:ListViewNetworkStreams	= New-Object System.Windows.Forms.ListView
						
			$PanelBottom							= New-Object System.Windows.Forms.Panel
				$picBoxTraydown						= New-Object System.Windows.Forms.PictureBox
	
	# ---------------------------------------------------------------------------------------------------------------------
	# ---------------------------------------------------------------------------------------------------------------------
	# ---------------------------------------------------------------------------------------------------------------------
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
}
#>
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Select-NetworkStreamFavorite {
[CmdletBinding()]
Param	(
		)
	# ---------------------------------------------------------------------------------------------------------------------
	$formSelectNetworkStreamFavorite		= New-Object System.Windows.Forms.Form
		$ListViewNetworkStreamFavorite		= New-Object System.Windows.Forms.ListView

	$formWidth = 400 
	$formHeight = 260

	$ListViewNetworkStreamFavorite | % {
		$_.Name = "ListViewNNetworkStreamFavorite"	
		$_.CheckBoxes = $False
		$_.DataBindings.DefaultDataSourceUpdateMode = 0
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager

		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0)
		$_.HeaderStyle = "None"
		$_.FullRowSelect = $True
		$_.GridLines = $False
		$_.HideSelection = $False
		$_.MultiSelect = $False		
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
	}	
	$ListViewNetworkStreamFavorite.Columns.Add("Name",220) | out-null
	$ListViewNetworkStreamFavorite.Columns.Add("Type",80) | out-null
	$ListViewNetworkStreamFavorite.Columns.Add("Genre",90) | out-null
	
	$formSelectNetworkStreamFavorite | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
		
		$_.Controls.Add($ListViewNetworkStreamFavorite)
		$_.Name = "formSelectNetworkStreamFavorite"
		$_.ControlBox = $false
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$_.Text = "$script:ScriptName : Select Network Stream Favorite"
		
		$_.Font = $Script:FontBase
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsNetworkStreamFavoriteWindowID
		
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
	
	$formSelectNetworkStreamFavorite.Add_FormClosing({
		Set-SettingsWindowBounds -ID $script:BoundsNetworkStreamFavoriteWindowID -FormsBound $formSelectNetworkStreamFavorite.Bounds

	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	$ListViewNetworkStreamFavorite.Add_MouseDoubleClick({
		Param($Object,$Event)

		if ($Event.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
			$hit = $Object.HitTest($Event.Location)

			if($hit.Item) {
				$script:SelectNetworkStreamFavoriteTag = $hit.Item.Tag

				$formSelectNetworkStreamFavorite.Close()
			}
		}		
		
	})
	$ListViewNetworkStreamFavorite.Add_KeyDown({
		if ($_.KeyData -ieq "Escape") {
	
			$script:SelectNetworkStreamFavoriteTag = $null
			$formSelectNetworkStreamFavorite.Close()
		}
	})
	$formSelectNetworkStreamFavorite.Add_KeyDown({
		if ($_.KeyData -ieq "Escape") {
	
			$script:SelectNetworkStreamFavoriteTag = $null
			$formSelectNetworkStreamFavorite.Close()
		}
	
	})		
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	if ($script:xmlNetworkStreamDataSet -eq $null) {
		$script:xmlNetworkStreamDataSet = Load-NetworkStreamData $script:xmlNetworkStreamFilename $script:NetworkStreamDataSetName
	}
	$StreamingStations = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Favorite = '1'")
	
	$ListViewNetworkStreamFavorite.BeginUpdate()
	$ListViewNetworkStreamFavorite.Items.Clear()
	
	foreach ($Station in $StreamingStations) {
		$item = new-object System.Windows.Forms.ListViewItem($Station.Name)
		$item.SubItems.Add($Station.StreamType) | out-null
		$item.SubItems.Add($Station.Genre) | out-null
		
		$item.tag = $Station
		$ListViewNetworkStreamFavorite.Items.Add($item)	| out-null
		
	}
	$ListViewNetworkStreamFavorite.EndUpdate()
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	$formSelectNetworkStreamFavorite.ShowDialog() | out-null	
	
	Write-Output $script:SelectNetworkStreamFavoriteTag
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
