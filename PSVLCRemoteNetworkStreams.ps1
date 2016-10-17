#################################################################################################
# Name			: 	PSVLCRemoteNetworkStreams.ps1
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
$script:xmlNetworkStreamFilenameExtension = ".NetworkStream.xml"
$script:xmlNetworkStreamDefaultFilename = "PSVLCRemote"+$script:xmlNetworkStreamFilenameExtension

$script:NetworkStreamDataSetName = "StreamingStations"
$script:NetworkStreamDataVersion = "1"

$script:xmlNetworkStreamDataSet = $null

$script:NetworkStreamDataSetNameAndComment = ""

$script:formMainNetworkStreamsManager = $null
$script:TreeViewNetworkStreamsManager = $null
$script:ListViewNetworkStreams = $null
$script:checkboxShowFavorite = $null

$script:labelFilename = $null
$script:labelNameAndComment = $null

$script:comboboxStreamType	 	 = $null
$script:comboboxStreamCountry	 = $null
$script:comboboxStreamGenre		 = $null
$script:textboxSearch	         = $null


$script:SelectNetworkStreamFavoriteTag = $null

$script:ExtendedNetworkStreamsManager = $False

$script:Filter_All_Type		= "<All Type>"
$script:Filter_No_Type		= "<No  Type>"
$script:FilterList_Type		= @($script:Filter_All_Type,$script:Filter_No_Type)

$script:Filter_All_Genre	= "<All Genre>"
$script:Filter_No_Genre		= "<No  Genre>"
$script:FilterList_Genre	= @($script:Filter_All_Genre,$script:Filter_No_Genre)

$script:Filter_All_Country	= "<All Country>"
$script:Filter_No_Country	= "<No  Country>"
$script:FilterList_Country	= @($script:Filter_All_Country,$script:Filter_No_Country)


<#
$contextMenuNetworkStreamsManager = New-Object System.Windows.Forms.ContextMenu
	$menuItemNSM_New			= $contextMenuNetworkStreamsManager.MenuItems.Add("New")
	$menuItemNSM_Edit			= $contextMenuNetworkStreamsManager.MenuItems.Add("Edit")	
	$menuItemNSM_Delete			= $contextMenuNetworkStreamsManager.MenuItems.Add("Delete")	
	$menuItemNSM_ToggleFavorite	= $contextMenuNetworkStreamsManager.MenuItems.Add("Toggle Favorite")	
	$menuItemNSM_Play			= $contextMenuNetworkStreamsManager.MenuItems.Add("Play")	
	$menuItemNSM_Reload			= $contextMenuNetworkStreamsManager.MenuItems.Add("Reload")	
	$menuItemNSM_FavoritesOnly	= $contextMenuNetworkStreamsManager.MenuItems.Add("Favorites only")	
#>
	
#endregion ScriptVariable
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
Function Test-StreamURLAvailaible {
[CmdletBinding()]
Param	(
			[string]$NetworkStreamName
		)
	$Available = $False

	if ($NetworkStreamName -and ($NetworkStreamName -ne "")) {
        $HTTP_Response = $Null
        
		# First we create the request.
		try {
			$HTTP_Request = [System.Net.WebRequest]::Create($NetworkStreamName)
			$HTTP_Request.Method="GET"
		} catch {
			$HTTP_Request = $NULL
		}
		# We then get a response from the site.
		if ($HTTP_Request -ne $null) {
			try {
				$HTTP_Response = $HTTP_Request.GetResponse()

				# We then get the HTTP code as an integer.
				$HTTP_Status = [int]$HTTP_Response.StatusCode

				If ($HTTP_Status -eq 200) { 
					$Available = $True
				}

				# Finally, we clean up the http request by closing it.
				$HTTP_Response.Close()
			} catch {
				#$_ | select -expand Exception | select -expand InnerException | select * | Out-Host
				$HTTP_Response = $Null
			}
        }
		if (!$Available) {
            try {
                $Response = Invoke-WebRequest -Uri $NetworkStreamName  -TimeoutSec 5 -UseBasicParsing  -DisableKeepAlive
                if ($Response.StatusCode -eq 200) {
                    $Available = $true
                }
            } catch {}
        } 
	} 
	
	Write-Output $Available
}
#
# -----------------------------------------------------------------------------
#
Function Test-NetworkStreamDataSetConfigTable {
[CmdletBinding()]
Param( 
		[Parameter(Mandatory=$true)][System.Data.DataSet]$xmlNetworkStreamDataSet,
		[string]$Name = "Default",
		[string]$Comment = "Default Networkstream Data File"
	)

	#
	# TODO
	#
	$bExist = $True
	
	if (!$xmlNetworkStreamDataSet.Tables -or ($xmlNetworkStreamDataSet.Tables -and !$xmlNetworkStreamDataSet.Tables['Configuration'])) {

		$bExist = $False
		$htTableStructure_Config = @{
			DataSet=$xmlNetworkStreamDataSet
			TableName="Configuration"
			Columns=@("Name", "Comment", "Version")
		}
		Add-Table @htTableStructure_Config

		$htDataConfig = @{
			DataSet=$xmlNetworkStreamDataSet
			TableName="Configuration"
			RowData = @{
				Name		= $Name
				Comment		= $Comment
				Version		= $script:NetworkStreamDataVersion
			}
		}
		Add-Row @htDataConfig		
	}
	
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
		<#
		$xmlNetworkStreamDataSet = New-NetworkStreamDataSet -NetworkStreamDataSetName $NetworkStreamDataSetName
		
		$bRetVal = Save-NetworkStreamDataSet -XmlNetworkStreamDataSet $xmlNetworkStreamDataSet -XmlNetworkStreamFilename $XMLNetworkStreamFilename
		#>
	} else {
	
		if (!(Test-NetworkStreamDataSetConfigTable $xmlNetworkStreamDataSet)) {
			$bRetVal = Save-NetworkStreamDataSet -XmlNetworkStreamDataSet $xmlNetworkStreamDataSet -XmlNetworkStreamFilename $XMLNetworkStreamFilename	
		}
		if ($xmlNetworkStreamDataSet.Tables["Configuration"]) {
			$Config = $xmlNetworkStreamDataSet.Tables["Configuration"].Select() | Select-Object -First 1 
		} else {
			$Config = $null
		}	

		if ($Config) {
			$Name    = $Config.Name
			$Comment = $Config.Comment
			
			$script:NetworkStreamDataSetNameAndComment = "$($Name) - $($Comment)"
		}
	}
	
	Write-Output $xmlNetworkStreamDataSet 	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Add-TableStreamingStations {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][System.Data.DataSet]$DataSet
		)
    $htTableStructure_NetworkStream = @{
        DataSet=$DataSet
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
	Add-TableStreamingStations $NetworkStreamDataSet
	# -------------------------------------------------------------------------------------------------------------------------
	$htTableStructure_Config = @{
		DataSet=$NetworkStreamDataSet
		TableName="Configuration"
		Columns=@("Name", "Comment", "Version")
	}
	Add-Table @htTableStructure_Config

	$htDataConfig = @{
		DataSet=$NetworkStreamDataSet
		TableName="Configuration"
		RowData = @{
			Name		= "Default"
			Comment		= "Default Networkstream Data File"
			Version		= $script:NetworkStreamDataVersion
		}
	}
	Add-Row @htDataConfig   
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
	<#
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
	#>
 
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
	if ($Data.Name -eq "") {
		$Data.Name = "<Unknown Station>"
	}
		
	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$NetworkStream = $xmlNetworkStreamDataSet.Tables["StreamingStations"].Select(("ID = '"+$ID+"'"))
	} else {
		$NetworkStream = $null
	}
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
	
		if (!$script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
			Add-TableStreamingStations $xmlNetworkStreamDataSet
		}
		
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

	$StreamingStations = $null
	
	if ($script:xmlNetworkStreamDataSet) {
		if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
			$FilterString = ""
			if ($OnlyFavorites) {
				$FilterString += "Favorite = '1'"
			}
			$Text = $script:comboboxStreamType.Text
			if ($Text -ne $script:Filter_All_Type) {
				if ($FilterString -ne "") {$FilterString += " and "}
				
				if ($Text -eq $script:Filter_No_Type) {
					$FilterString += "StreamType = ''"
				} else {
					$FilterString += ("StreamType = '"+$Text+"'")
				}
			}
			$Text = $script:comboboxStreamCountry.Text
			if ($Text -ne $script:Filter_All_Country) {
				if ($FilterString -ne "") {$FilterString += " and "}
				
				if ($Text -eq $script:Filter_No_Country) {
					$FilterString += "Country = ''"
				} else {
					$FilterString += ("Country = '"+$Text+"'")
				}
			}
			$Text = $script:comboboxStreamGenre.Text
			if ($Text -ne $script:Filter_All_Genre) {
				if ($FilterString -ne "") {$FilterString += " and "}
				
				if ($Text -eq $script:Filter_No_Genre) {
					$FilterString += "Genre = ''"
				} else {
					$FilterString += ("Genre = '"+$Text+"'")
				}
			}
			$Text = $script:textboxSearch.Text
			if ($Text -ne "") {
				$Text = $Text -replace "[*%?]",""
				
				if ($FilterString -ne "") {$FilterString += " and "}
				# Name, URL, WebSite, Region,Country,State,,Genre,Tags,Annotation
				$FilterString += ("(")
				$FilterString += ("(Name like '*"+$Text+"*')")
				$FilterString += (" or (URL like '*"+$Text+"*')")
				$FilterString += (" or (WebSite like '*"+$Text+"*')")
				$FilterString += (" or (Region like '*"+$Text+"*')")
				$FilterString += (" or (Country like '*"+$Text+"*')")
				$FilterString += (" or (State like '*"+$Text+"*')")
				$FilterString += (" or (City like '*"+$Text+"*')")
				$FilterString += (" or (Genre like '*"+$Text+"*')")
				$FilterString += (" or (Tags like '*"+$Text+"*')")
				$FilterString += (" or (Annotation like '*"+$Text+"*')")
				$FilterString += (")")

			}				
			#$FilterString | out-Host
			$StreamingStations = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select($FilterString) | Sort-Object StreamType, Name, Bitrate
		} else {
			#"Table StreamingStations NOT EXIST" | out-Host
		}
	} else {
			#"DATASET NOT EXIST" | out-Host
	}
	
	$script:ListViewNetworkStreams.BeginUpdate()
	$script:ListViewNetworkStreams.Items.Clear()
	
	foreach ($Station in $StreamingStations) {
		$item = new-object System.Windows.Forms.ListViewItem($Station.Name)
		$item.SubItems.Add($Station.StreamType) | out-null
		
		if ($script:ExtendedNetworkStreamsManager) {
			$item.SubItems.Add($Station.URL) | out-null
			$item.SubItems.Add("") | out-null
		}
		$item.SubItems.Add($Station.WebSite) | out-null
		
		$item.SubItems.Add($Station.Region) | out-null
		$item.SubItems.Add($Station.Country) | out-null
		$item.SubItems.Add($Station.State) | out-null
		$item.SubItems.Add($Station.City) | out-null
		
		$item.SubItems.Add($Station.Genre) | out-null
		$item.SubItems.Add($Station.Bitrate) | out-null
		if ($script:ExtendedNetworkStreamsManager) {
			$item.SubItems.Add($Station.Rate) | out-null
			$item.SubItems.Add($Station.Tags) | out-null
			$item.SubItems.Add($Station.Annotation) | out-null
		}
		if ($Station.Favorite -eq "1") {
			$item.SubItems.Add("Favorite") | out-null
		} else {
			$item.SubItems.Add("") | out-null
		}
		$item.tag = $Station
		$script:ListViewNetworkStreams.Items.Add($item)	| out-null

	}
	$script:ListViewNetworkStreams.EndUpdate()

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Load-SearchSettings {
	[CmdletBinding()]
	Param	()

	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$GenreNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Genre <> ''") | Select-Object Genre -Unique | Sort-Object Genre | Select-Object -Expand Genre
		$script:comboboxStreamGenre.Items.Clear()
		$script:comboboxStreamGenre.Items.AddRange($script:FilterList_Genre+$GenreNames)			
		$script:comboboxStreamGenre.SelectedItem = $script:Filter_All_Genre
	}
	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$StreamTypeNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("StreamType <> ''") | Select-Object StreamType -Unique | Sort-Object StreamType | Select-Object -Expand StreamType
		$script:comboboxStreamType.Items.Clear()
		$script:comboboxStreamType.Items.AddRange($script:FilterList_Type+$StreamTypeNames)			
		$script:comboboxStreamType.SelectedItem = $script:Filter_All_Type
	}		
	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$CountryNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Country <> ''") | Select-Object Country -Unique | Sort-Object Country | Select-Object -Expand Country
		$script:comboboxStreamCountry.Items.Clear()
		$script:comboboxStreamCountry.Items.AddRange($script:FilterList_Country+$CountryNames)			
		$script:comboboxStreamCountry.SelectedItem = $script:Filter_All_Country
	}		
	$script:textboxSearch.Text = ""	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#	
Function Edit-VLCRemoteVLCRemoteNetworkStreams {
[CmdletBinding()]
Param	(
		[Parameter(Mandatory=$true)][PSObject]$VLCRemoteNetworkStreamData
		)
	$script:EditNetworkStreamData = New-Object PSObject -Property @{
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
	
	$textboxName.Text		= $script:EditNetworkStreamData.Name
	$textboxURL.Text  		= $script:EditNetworkStreamData.URL
	$textboxWebSite.Text	= $script:EditNetworkStreamData.WebSite
	
	$textboxBitrate.Text 		= $script:EditNetworkStreamData.Bitrate
	$textboxTags.Text			= $script:EditNetworkStreamData.Tags
	$textboxAnnotation.Text		= $script:EditNetworkStreamData.Annotation
	
	$checkboxFavorite.Checked = If ($script:EditNetworkStreamData.Favorite -eq "1") {$True} else {$False}
	
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

		$script:EditNetworkStreamData.Name 		= $textboxName.Text
		$script:EditNetworkStreamData.StreamType 	= $comboboxStreamType.Text
		$script:EditNetworkStreamData.Url 			= $textboxUrl.Text
		$script:EditNetworkStreamData.WebSite 		= $textboxWebSite.Text
		
		$script:EditNetworkStreamData.Bitrate 		= $textboxBitrate.Text
		$script:EditNetworkStreamData.Tags 		= $textboxTags.Text
		$script:EditNetworkStreamData.Annotation 	= $textboxAnnotation.Text
		
		$script:EditNetworkStreamData.Genre 		= $comboboxGenre.Text
		
		$script:EditNetworkStreamData.Rate 		= $comboboxRate.Text
		$script:EditNetworkStreamData.Favorite = If ($checkboxFavorite.Checked) {"1"} else {"0"}	
		
		$formDialog.Close()
		
	})
	$buttonCancel.Add_Click({
		
		$script:EditNetworkStreamData = $null
		$formDialog.Close()
		
	})	
	
	$comboboxRegion.Enabled = $False
	$comboboxCountry.Enabled = $False
	$comboboxState.Enabled = $False
	$comboboxCity.Enabled = $False
	
	$Rates = @("0","1","2","3","4","5","6","7","8","9")
	$comboboxRate.Items.AddRange($Rates)			
	$comboboxRate.SelectedItem = ($script:EditNetworkStreamData.Rate)

	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$GenreNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("Genre <> ''") | Select-Object Genre -Unique | Sort-Object Genre | Select-Object -Expand Genre
		#$GenreNames | out-host
		$comboboxGenre.Items.AddRange($GenreNames)			
		$comboboxGenre.SelectedItem = ($script:EditNetworkStreamData.Genre)
	}
	if ($script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
		$StreamTypeNames = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select("StreamType <> ''") | Select-Object StreamType -Unique | Sort-Object StreamType | Select-Object -Expand StreamType
		#$GenreNames | out-host
		$comboboxStreamType.Items.AddRange($StreamTypeNames)			
		$comboboxStreamType.SelectedItem = ($script:EditNetworkStreamData.StreamType)
	}
	$formDialog.ShowDialog() | out-null	
	
	Write-Output $script:EditNetworkStreamData
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
			$PanelMainRight		= New-Object System.Windows.Forms.Panel
				$PanelRight		= New-Object System.Windows.Forms.FlowLayoutPanel
					$buttonNew			= New-Object System.Windows.Forms.Button
					$buttonEdit			= New-Object System.Windows.Forms.Button
					$buttonDelete		= New-Object System.Windows.Forms.Button
					$buttonSetAsFavourite	= New-Object System.Windows.Forms.Button
					$buttonPlay			= New-Object System.Windows.Forms.Button
					$buttonImportRaimasoftXML	= New-Object System.Windows.Forms.Button
					$buttonImportListenLive		= New-Object System.Windows.Forms.Button
					$buttonImportRadioBrowser	= New-Object System.Windows.Forms.Button
					$buttonReload		= New-Object System.Windows.Forms.Button
					$buttonCheckAvailable		= New-Object System.Windows.Forms.Button

					$labelDummy	 			= New-Object System.Windows.Forms.Label
					$script:comboboxStreamType	 	 = New-Object System.Windows.Forms.ComboBox	
					$script:comboboxStreamCountry	 = New-Object System.Windows.Forms.ComboBox	
					$script:comboboxStreamGenre	 = New-Object System.Windows.Forms.ComboBox	
					
					$script:textboxSearch	         = New-Object System.Windows.Forms.Textbox
					
					$script:checkboxShowFavorite	= New-Object System.Windows.Forms.CheckBox
					
				$PanelRightBottom			= New-Object System.Windows.Forms.Panel
					$buttonManager			= New-Object System.Windows.Forms.Button
			$PanelBottom							= New-Object System.Windows.Forms.Panel
				$script:labelFilename						= New-Object System.Windows.Forms.Label
				$script:labelNameAndComment				= New-Object System.Windows.Forms.Label
				
				$picBoxTraydown						= New-Object System.Windows.Forms.PictureBox				

	$FontLabel = New-Object System.Drawing.Font("Segoe UI",8, [System.Drawing.FontStyle]::Bold)			
				
	$borderDist  = 5
	$dist = 3
	
	$ButtonWidth = 160 
	$ButtonHeight = 21
	
	$comboboxWidth = $buttonWidth
	
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
		
		if ($script:ExtendedNetworkStreamsManager) {
			$_.MultiSelect = $true
		} else {
			$_.MultiSelect = $false		
		}
		$_.UseCompatibleStateImageBehavior = $False
		$_.View = [System.Windows.Forms.View]::Details
		$_.TabStop = $false
		$_.TabIndex = 0	
		$_.Sorting = [System.Windows.Forms.SortOrder]::None
	}	
	$script:ListViewNetworkStreams.Clear()
	$script:ListViewNetworkStreams.Columns.Add("Name",260) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Type",100) | out-null
	if ($script:ExtendedNetworkStreamsManager) {
		$script:ListViewNetworkStreams.Columns.Add("URL",660) | out-null
		$script:ListViewNetworkStreams.Columns.Add("Check",80) | out-null
	}
	$script:ListViewNetworkStreams.Columns.Add("WebSite",100) | out-null
	
	$script:ListViewNetworkStreams.Columns.Add("Region",60) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Country",70) | out-null
	$script:ListViewNetworkStreams.Columns.Add("State",60) | out-null
	$script:ListViewNetworkStreams.Columns.Add("City",60) | out-null
	
	$script:ListViewNetworkStreams.Columns.Add("Genre",130) | out-null
	$script:ListViewNetworkStreams.Columns.Add("Bitrate",60) | out-null
	if ($script:ExtendedNetworkStreamsManager) {
		$script:ListViewNetworkStreams.Columns.Add("Rate",50) | out-null
		$script:ListViewNetworkStreams.Columns.Add("Tags",120) | out-null
		$script:ListViewNetworkStreams.Columns.Add("Annotation",200) | out-null
	}
	$script:ListViewNetworkStreams.Columns.Add("Favorite",70) | out-null

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
	$buttonDelete | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonDelete"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Delete"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonSetAsFavourite | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonSetAsDefault"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Toogle Favorite"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonPlay | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Play"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonImportRaimasoftXML | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Import Raimasoft"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonImportListenLive | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Import Listenlive.eu"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonImportRadioBrowser | % {
	
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Import Radio-Browser.info"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonReload | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Reload"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$buttonCheckAvailable | % {
	
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		#$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonConnect"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Check Available"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$labelDummy   | % {
		$_.Size = New-Object System.Drawing.Size($comboboxWidth, (1.2*$LabelHeight))
		$_.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
		$_.TabStop = $false
		$_.Text = "Search / Filter"
	}
	$script:comboboxStreamType | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True
		$_.Size = New-Object System.Drawing.Size($comboboxWidth,$labelHeight)
		$_.TabStop = $false
	}
	$script:comboboxStreamCountry | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True
		$_.Size = New-Object System.Drawing.Size($comboboxWidth,$labelHeight)
		$_.TabStop = $false
	}
	$script:comboboxStreamGenre | % {
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True
		$_.Size = New-Object System.Drawing.Size($comboboxWidth,$labelHeight)
		$_.TabStop = $false
	}	
	$script:textboxSearch | % {
		$_.Size = New-Object System.Drawing.Size($comboboxWidth, $labelHeight)
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
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
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
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

		if ($script:ExtendedNetworkStreamsManager) {
			$_.Controls.Add($buttonImportRaimasoftXML)
			$_.Controls.Add($buttonImportListenLive)
			$_.Controls.Add($buttonImportRadioBrowser)
		}

		if ($script:ExtendedNetworkStreamsManager) {
			$_.Controls.Add($buttonCheckAvailable)
		}
		$_.Controls.Add($labelDummy)
		$_.Controls.Add($script:comboboxStreamType)
		$_.Controls.Add($script:comboboxStreamCountry)
		$_.Controls.Add($script:comboboxStreamGenre)
		$_.Controls.Add($script:textboxSearch)
		$_.Controls.Add($script:checkboxShowFavorite)
		
		$_.Controls.Add($buttonReload)
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
	$xPos = $BorderDist
	$yPos = $BorderDist
	$script:labelFilename  | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Font = $FontLabel
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(($formWidth - (2*$BorderDist) - $picboxCOntrolWidthSmall), 12)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.TabStop = $false
		$_.Text = $script:xmlNetworkStreamFilename
	}
	$yPos += 12
	$script:labelNameAndComment  | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Font = $FontLabel
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(($formWidth - (2*$BorderDist) - $picboxCOntrolWidthSmall), 12)
		$_.TextAlign = [System.Drawing.ContentAlignment]::Middleleft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.TabStop = $false
		$_.Text = "Name and Comment"
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
		$_.Controls.Add($script:labelFilename)
		$_.Controls.Add($script:labelNameAndComment)
		$_.Controls.Add($picBoxTraydown)
	}
	$buttonManager | % {
	
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($borderDist,$borderDist)
		$_.Name = "ButtonManager"
		$_.Size = New-Object System.Drawing.Size($ButtonWidth, $ButtonHeight)
		$_.Text = "Manager"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$PanelRightBottom | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Size = New-Object System.Drawing.Size(0, ($ButtonHeight+(2*$borderDist)))
		$_.Dock = [System.Windows.Forms.DockStyle]::Bottom
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelBottom"
		$_.TabStop = $false
		$_.Controls.Add($buttonManager)	
	}
	$PanelMainRight	| % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom)
		$_.Size = New-Object System.Drawing.Size(($ButtonWidth+(2*$borderDist)), 0)
		$_.Dock = [System.Windows.Forms.DockStyle]::Right
		#$_.BackColor = [System.Drawing.Color]::Wheat
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_NetworkStreamsManager
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelBottom"
		$_.TabStop = $false
		$_.Controls.Add($PanelRight)	
		$_.Controls.Add($PanelRightBottom)	
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
		$_.Controls.Add($PanelMainRight)
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
		$Text = "$script:ScriptName : Network Streams Manager"
		if ($script:ExtendedNetworkStreamsManager) {
			$Text += " : EXTENDED"
		}
		$_.Text = $Text
		
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
			
			Load-SearchSettings
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
				$index = 0
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Name;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.StreamType;$index++
				if ($script:ExtendedNetworkStreamsManager) {
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.URL;$index++
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = "";$index++
				}	
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.WebSite;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Region;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Country;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.State;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.City;$index++

				
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Genre;$index++
				$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Bitrate;$index++
				
				if ($script:ExtendedNetworkStreamsManager) {
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Rate;$index++
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Tags;$index++		
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = $NewObject.Annotation;$index++
				}
				if ($NewObject.Favorite -eq "1") {
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = "Favorite";$index++
				} else {
					$script:ListViewNetworkStreams.SelectedItems[0].SubItems[$index].Text = "";$index++				
				}
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonDelete.Add_Click({
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
		
			Foreach ($Item in $script:ListViewNetworkStreams.SelectedItems) {
				$Object = $Item.Tag
				
				if ($script:ExtendedNetworkStreamsManager) {
					$Answer = "Yes"
				} else {
					$Answer = Show-MessageYesNoAnswer "Soll der Eintrag $($Object.Name) gelöscht werden ?"
				}
				if ($Answer -eq  "Yes") {			

					$Item.Remove()
					
					Remove-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename ($Object.ID)

				}
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
			
				if ($script:ExtendedNetworkStreamsManager) {
					$Index = 14
				} else {
					$index = 9
				}
			
				if ($Object.Favorite -eq "1") {
					$Item.SubItems[$index].Text = "Favorite"
				} else {
					$Item.SubItems[$index].Text = ""
				}

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
	$buttonImportRaimasoftXML.Add_Click({
	
		<#
		$Filename = Select-FileDialog "Select File" "" $script:WorkingDirectory "XML Files (*.xml|*.xml"
		if ($FileName) {
			Import-RaimasoftXML $Filename
			Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
		}
		#>
		
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonImportListenLive.Add_Click({
	
		Import-ListenLiveStations
	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonImportRadioBrowser.Add_Click({

	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonReload.Add_Click({
		Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonCheckAvailable.Add_Click({
		
		if ($script:ListViewNetworkStreams.SelectedItems -and (($script:ListViewNetworkStreams.SelectedItems).Count -gt 0) ) {
			Foreach ($Item in $script:ListViewNetworkStreams.SelectedItems) {
				$Object = $Item.Tag
				
				$Avail = Test-StreamURLAvailaible $Object.URL
				
				if ($Avail) {
					$Item.SubItems[3].Text = "Ok";
				} else {
					$Item.SubItems[3].Text = "Failed";
				}
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonManager.Add_Click({
		
		$OldFilename = $script:xmlNetworkStreamFilename
	
		Manage-VLCRemoteNetworkStreamFiles
		
		if ($oldFilename -ne $script:xmlNetworkStreamFilename) {
		
			$script:xmlNetworkStreamDataSet = Load-NetworkStreamData $script:xmlNetworkStreamFilename $script:NetworkStreamDataSetName
			
			Load-SearchSettings
			Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked	

			$script:labelFilename.Text 			= $script:xmlNetworkStreamFilename
			$script:labelNameAndComment.Text 	= $script:NetworkStreamDataSetNameAndComment
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:textboxSearch.Add_KeyDown({
		if ($_.KeyData -ieq "Return") {
			Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
		} 
		#>
	})	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
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
<#
	$script:boolSort = $true
	$columnClick = {  
	  $script:ListViewNetworkStreams.ListViewItemSorter = New-Object ListViewItemComparerWSUSSearchDeclineDeleteUpdates($_.Column, $script:boolSort)
	  
	  $script:boolSort = !$script:boolSort
	}
	$script:ListViewNetworkStreams.Add_ColumnClick($columnClick)
#>
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:checkboxShowFavorite.Checked = $false
	
	$script:xmlNetworkStreamDataSet = Load-NetworkStreamData $script:xmlNetworkStreamFilename $script:NetworkStreamDataSetName
	
	Load-SearchSettings
	Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
	$script:labelFilename.Text 			= $script:xmlNetworkStreamFilename
	$script:labelNameAndComment.Text 	= $script:NetworkStreamDataSetNameAndComment
	
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
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
