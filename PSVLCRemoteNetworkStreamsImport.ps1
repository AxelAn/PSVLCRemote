#################################################################################################
# Name			: 	PSVLCRemoteNetworkStreamsImport.ps1
# Description	: 	
# Author		: 	Axel Anderson (-XP)
# License		:	
# Date			: 	21.09.2016 created
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
$script:frmProgress 		= $null
$script:panelMainProgress 	= $null
$script:progressProgress 	= $null
$script:labelProgressDetail = $null
$script:labelProgressHead 	= $null

$script:ListenLiveCountry_Albania					=	"Albania"
$script:ListenLiveCountry_Andorra               	=	"Andorra"
$script:ListenLiveCountry_Armenia               	=	"Armenia"
$script:ListenLiveCountry_Austria               	=	"Austria"
$script:ListenLiveCountry_Azerbaijan            	=	"Azerbaijan"
$script:ListenLiveCountry_Belarus               	=	"Belarus"
$script:ListenLiveCountry_Belgium               	=	"Belgium"
$script:ListenLiveCountry_BosniaHerzegovina     	=	"Bosnia-Herzegovina"
$script:ListenLiveCountry_Bulgaria              	=	"Bulgaria"
$script:ListenLiveCountry_Croatia               	=	"Croatia"
$script:ListenLiveCountry_Cyprus                	=	"Cyprus"
$script:ListenLiveCountry_CzechRepublic         	=	"Czech Republic"
$script:ListenLiveCountry_Denmark               	=	"Denmark"
$script:ListenLiveCountry_Estonia               	=	"Estonia"
$script:ListenLiveCountry_FaroeIslands          	=	"Faroe Islands"
$script:ListenLiveCountry_Finland               	=	"Finland"
$script:ListenLiveCountry_France                	=	"France"
$script:ListenLiveCountry_Georgia               	=	"Georgia"
$script:ListenLiveCountry_Germany               	=	"Germany"
$script:ListenLiveCountry_Gibraltar             	=	"Gibraltar"
$script:ListenLiveCountry_Greece                	=	"Greece"
$script:ListenLiveCountry_Hungary               	=	"Hungary"
$script:ListenLiveCountry_Iceland               	=	"Iceland"
$script:ListenLiveCountry_Ireland               	=	"Ireland"
$script:ListenLiveCountry_Italy                 	=	"Italy"
$script:ListenLiveCountry_Kosovo                	=	"Kosovo"
$script:ListenLiveCountry_Latvia                	=	"Latvia"
$script:ListenLiveCountry_Liechtenstein         	=	"Liechtenstein"
$script:ListenLiveCountry_Lithuania             	=	"Lithuania"
$script:ListenLiveCountry_Luxembourg            	=	"Luxembourg"
$script:ListenLiveCountry_Macedonia             	=	"Macedonia"
$script:ListenLiveCountry_Malta                 	=	"Malta"
$script:ListenLiveCountry_Moldova               	=	"Moldova"
$script:ListenLiveCountry_Monaco                	=	"Monaco"
$script:ListenLiveCountry_Montenegro            	=	"Montenegro"
$script:ListenLiveCountry_Netherlands           	=	"Netherlands"
$script:ListenLiveCountry_Norway                	=	"Norway"
$script:ListenLiveCountry_Poland                	=	"Poland"
$script:ListenLiveCountry_Portugal              	=	"Portugal"
$script:ListenLiveCountry_Romania               	=	"Romania"
$script:ListenLiveCountry_Russia                	=	"Russia"
$script:ListenLiveCountry_SanMarino             	=	"San Marino"
$script:ListenLiveCountry_Serbia                	=	"Serbia"
$script:ListenLiveCountry_Slovakia              	=	"Slovakia"
$script:ListenLiveCountry_Slovenia              	=	"Slovenia"
$script:ListenLiveCountry_Spain                 	=	"Spain"
$script:ListenLiveCountry_Sweden                	=	"Sweden"
$script:ListenLiveCountry_Switzerland           	=	"Switzerland"
$script:ListenLiveCountry_Turkey                	=	"Turkey"
$script:ListenLiveCountry_Ukraine               	=	"Ukraine"
$script:ListenLiveCountry_UnitedKingdom         	=	"United Kingdom"
$script:ListenLiveCountry_VaticanState          	=	"Vatican State"

$script:ListenLiveCountryList = @(
									$script:ListenLiveCountry_Albania,
									$script:ListenLiveCountry_Andorra,
									$script:ListenLiveCountry_Armenia,
									$script:ListenLiveCountry_Austria,
									$script:ListenLiveCountry_Azerbaijan,
									$script:ListenLiveCountry_Belarus,
									$script:ListenLiveCountry_Belgium,
									$script:ListenLiveCountry_BosniaHerzegovina,
									$script:ListenLiveCountry_Bulgaria,
									$script:ListenLiveCountry_Croatia,
									$script:ListenLiveCountry_Cyprus,
									$script:ListenLiveCountry_CzechRepublic,
									$script:ListenLiveCountry_Denmark,
									$script:ListenLiveCountry_Estonia,
									$script:ListenLiveCountry_FaroeIslands,
									$script:ListenLiveCountry_Finland,
									$script:ListenLiveCountry_France,
									$script:ListenLiveCountry_Georgia,
									$script:ListenLiveCountry_Germany,
									$script:ListenLiveCountry_Gibraltar,
									$script:ListenLiveCountry_Greece,
									$script:ListenLiveCountry_Hungary,
									$script:ListenLiveCountry_Iceland,
									$script:ListenLiveCountry_Ireland,
									$script:ListenLiveCountry_Italy,
									$script:ListenLiveCountry_Kosovo,
									$script:ListenLiveCountry_Latvia,
									$script:ListenLiveCountry_Liechtenstein,
									$script:ListenLiveCountry_Lithuania,
									$script:ListenLiveCountry_Luxembourg,
									$script:ListenLiveCountry_Macedonia,
									$script:ListenLiveCountry_Malta,
									$script:ListenLiveCountry_Moldova,
									$script:ListenLiveCountry_Monaco,
									$script:ListenLiveCountry_Montenegro,
									$script:ListenLiveCountry_Netherlands,
									$script:ListenLiveCountry_Norway,
									$script:ListenLiveCountry_Poland,
									$script:ListenLiveCountry_Portugal,
									$script:ListenLiveCountry_Romania,
									$script:ListenLiveCountry_Russia,
									$script:ListenLiveCountry_SanMarino,
									$script:ListenLiveCountry_Serbia,
									$script:ListenLiveCountry_Slovakia,
									$script:ListenLiveCountry_Slovenia,
									$script:ListenLiveCountry_Spain,
									$script:ListenLiveCountry_Sweden,
									$script:ListenLiveCountry_Switzerland,
									$script:ListenLiveCountry_Turkey,
									$script:ListenLiveCountry_Ukraine,
									$script:ListenLiveCountry_UnitedKingdom,
									$script:ListenLiveCountry_VaticanState
								)

$script:ListenLiveParameter = @{}
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Albania,		(@{URL = "http://www.listenlive.eu/albania.html";Region = "Europe";Country = "Albania";State = "";Browse="Country";}))	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Andorra,		(@{URL = "http://www.listenlive.eu/andorra.html";Region = "Europe";Country = "Andorra";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Armenia,		(@{URL = "http://www.listenlive.eu/armenia.html";Region = "Europe";Country = "Armenia";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Austria,		(@{URL = "http://www.listenlive.eu/austria.html";Region = "Europe";Country = "Austria";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Azerbaijan,	(@{URL = "http://www.listenlive.eu/azerbaijan.html";Region = "Europe";Country = "Azerbaijan";State = "";Browse="Country";}))
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Belarus,		(@{URL = "http://www.listenlive.eu/belarus.html";Region = "Europe";Country = "Belarus";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Belgium,		(@{URL = "http://www.listenlive.eu/belgium.html";Region = "Europe";Country = "Belgium";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_BosniaHerzegovina,(@{URL = "http://www.listenlive.eu/bosnia.html";Region = "Europe";Country = "Bosnia-Herzegovina";State = "";Browse="Country";}))
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Bulgaria,		(@{URL = "http://www.listenlive.eu/bulgaria.html";Region = "Europe";Country = "Bulgaria";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Croatia,		(@{URL = "http://www.listenlive.eu/croatia.html";Region = "Europe";Country = "Croatia";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Cyprus,		(@{URL = "http://www.listenlive.eu/cyprus.html";Region = "Europe";Country = "Cyprus";State = "";Browse="Country";}))      
$script:ListenLiveParameter.Add($script:ListenLiveCountry_CzechRepublic,(@{URL = "http://www.listenlive.eu/czech-republic.html";Region = "Europe";Country = "Czech Republic";State = "";Browse="Country";}))    
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Denmark,		(@{URL = "http://www.listenlive.eu/denmark.html";Region = "Europe";Country = "Denmark";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Estonia,		(@{URL = "http://www.listenlive.eu/estonia.html";Region = "Europe";Country = "Estonia";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_FaroeIslands,	(@{URL = "http://www.listenlive.eu/faroe.html";Region = "Europe";Country = "Faroe Islands";State = "";Browse="Country";}))     
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Finland,		(@{URL = "http://www.listenlive.eu/finland.html";Region = "Europe";Country = "Finland";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_France,		(@{URL = "http://www.listenlive.eu/france.html";Region = "Europe";Country = "France";State = "";Browse="Country";}))       			
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Georgia,		(@{URL = "http://www.listenlive.eu/georgia.html";Region = "Europe";Country = "Georgia";State = "";Browse="Country";}))       		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Germany,		(@{URL = "http://www.listenlive.eu/germany.html";Region = "Europe";Country = "Germany";State = "";Browse="Country";}))       		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Gibraltar,	(@{URL = "http://www.listenlive.eu/gibraltar.html";Region = "Europe";Country = "Gibraltar";State = "";Browse="Country";}))     		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Greece,		(@{URL = "http://www.listenlive.eu/greece.html";Region = "Europe";Country = "Greece";State = "";Browse="Country";}))       			
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Hungary,		(@{URL = "http://www.listenlive.eu/hungary.html";Region = "Europe";Country = "Hungary";State = "";Browse="Country";}))       		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Iceland,		(@{URL = "http://www.listenlive.eu/iceland.html";Region = "Europe";Country = "Iceland";State = "";Browse="Country";}))       		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Ireland,		(@{URL = "http://www.listenlive.eu/ireland.html";Region = "Europe";Country = "Ireland";State = "";Browse="Country";}))       		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Italy,		(@{URL = "http://www.listenlive.eu/italy.html";Region = "Europe";Country = "Italy";State = "";Browse="Country";}))       			
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Kosovo,		(@{URL = "http://www.listenlive.eu/kosovo.html";Region = "Europe";Country = "Kosovo";State = "";Browse="Country";}))       			
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Latvia,		(@{URL = "http://www.listenlive.eu/latvia.html";Region = "Europe";Country = "Latvia";State = "";Browse="Country";}))       			
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Liechtenstein,(@{URL = "http://www.listenlive.eu/liechtenstein.html";Region = "Europe";Country = "Liechtenstein";State = "";Browse="Country";})) 		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Lithuania,	(@{URL = "http://www.listenlive.eu/lithuania.html";Region = "Europe";Country = "Lithuania";State = "";Browse="Country";}))     		
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Luxembourg,	(@{URL = "http://www.listenlive.eu/luxembourg.html";Region = "Europe";Country = "Luxembourg";State = "";Browse="Country";}))    
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Macedonia,	(@{URL = "http://www.listenlive.eu/macedonia.html";Region = "Europe";Country = "Macedonia";State = "";Browse="Country";}))     
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Malta,		(@{URL = "http://www.listenlive.eu/malta.html";Region = "Europe";Country = "Malta";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Moldova,		(@{URL = "http://www.listenlive.eu/moldova.html";Region = "Europe";Country = "Moldova";State = "";Browse="Country";}))       
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Monaco,		(@{URL = "http://www.listenlive.eu/monaco.html";Region = "Europe";Country = "Monaco";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Montenegro,	(@{URL = "http://www.listenlive.eu/montenegro.html";Region = "Europe";Country = "Montenegro";State = "";Browse="Country";}))    
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Netherlands,	(@{URL = "http://www.listenlive.eu/netherlands.html";Region = "Europe";Country = "Netherlands";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Norway,		(@{URL = "http://www.listenlive.eu/norway.html";Region = "Europe";Country = "Norway";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Poland,		(@{URL = "http://www.listenlive.eu/poland.html";Region = "Europe";Country = "Poland";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Portugal,		(@{URL = "http://www.listenlive.eu/portugal.html";Region = "Europe";Country = "Portugal";State = "";Browse="Country";}))      
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Romania,		(@{URL = "http://www.listenlive.eu/romania.html";Region = "Europe";Country = "Romania";State = "";Browse="Country";}))       
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Russia,		(@{URL = "http://www.listenlive.eu/russia.html";Region = "Europe";Country = "Russia";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_SanMarino,	(@{URL = "http://www.listenlive.eu/san-marino.html";Region = "Europe";Country = "San Marino";State = "";Browse="Country";}))    
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Serbia,		(@{URL = "http://www.listenlive.eu/serbia.html";Region = "Europe";Country = "Serbia";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Slovakia,		(@{URL = "http://www.listenlive.eu/slovakia.html";Region = "Europe";Country = "Slovakia";State = "";Browse="Country";}))      
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Slovenia,		(@{URL = "http://www.listenlive.eu/slovenia.html";Region = "Europe";Country = "Slovenia";State = "";Browse="Country";}))      
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Spain,		(@{URL = "http://www.listenlive.eu/spain.html";Region = "Europe";Country = "Spain";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Sweden,		(@{URL = "http://www.listenlive.eu/sweden.html";Region = "Europe";Country = "Sweden";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Switzerland,	(@{URL = "http://www.listenlive.eu/switzerland.html";Region = "Europe";Country = "Switzerland";State = "";Browse="Country";}))   
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Turkey,		(@{URL = "http://www.listenlive.eu/turkey.html";Region = "Europe";Country = "Turkey";State = "";Browse="Country";}))       	
$script:ListenLiveParameter.Add($script:ListenLiveCountry_Ukraine,		(@{URL = "http://www.listenlive.eu/ukraine.html";Region = "Europe";Country = "Ukraine";State = "";Browse="Country";}))       
$script:ListenLiveParameter.Add($script:ListenLiveCountry_UnitedKingdom,(@{URL = "http://www.listenlive.eu/uk.html";Region = "Europe";Country = "United Kingdom";State = "";Browse="Country";}))
$script:ListenLiveParameter.Add($script:ListenLiveCountry_VaticanState,	(@{URL = "http://www.listenlive.eu/vatican.html";Region = "Europe";Country = "Vatican State";State = "";Browse="Country";})) 

#endregion ScriptVariable
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
# DAS (Die ProgressForm) gehört hier nicht her, packe ich später in ein extra File
#region FORMPROGRESS
#
function Generate-FormProgress {

	if ($script:frmProgress -eq $null) {
		$script:frmProgress 		= New-Object System.Windows.Forms.Form
		$script:panelMainProgress 	= New-Object System.Windows.Forms.Panel
		$script:progressProgress 	= New-Object System.Windows.Forms.ProgressBar
		$script:labelProgressDetail = New-Object System.Windows.Forms.Label
		$script:labelProgressHead 	= New-Object System.Windows.Forms.Label

		$script:frmProgress | % {
			$_.ClientSize = New-Object System.Drawing.Size(478, 130)
			$_.ControlBox = $False
			$_.DataBindings.DefaultDataSourceUpdateMode = 0
			$_.FormBorderStyle = 3
			$_.Name = "frmProgress"
			$_.StartPosition = "CenterScreen"
			$_.Text = "Progress"
			$_.TopMost = $true
		}
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$script:panelMainProgress | % {
			$_.DataBindings.DefaultDataSourceUpdateMode = 0
			$_.Dock = 5
			$_.Location = New-Object System.Drawing.Point(0,0)
			$_.Name = "panelMainProgress"
			$_.Size = New-Object System.Drawing.Size(478, 130)
			$_.TabIndex = 0
		}
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$script:progressProgress | % {
			$_.DataBindings.DefaultDataSourceUpdateMode = 0
			$_.Location = New-Object System.Drawing.Point(12,91)
			$_.Maximum = 10
			$_.Minimum = 1
			$_.Name = "progressProgress"
			$_.Size = New-Object System.Drawing.Size(454, 21)
			$_.Step = 1
			$_.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$_.TabIndex = 2
			$_.Value = 1
		}
		$script:panelMainProgress.Controls.Add($script:progressProgress)
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$script:labelProgressDetail | % {
			$_.DataBindings.DefaultDataSourceUpdateMode = 0
			$_.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,0)
			$_.Location = New-Object System.Drawing.Point(12, 50)
			$_.Name = "labelProgressDetail"
			$_.Size = New-Object System.Drawing.Size(454, 23)
			$_.TabIndex = 1
			$_.Text = "."
			$_.TextAlign = 16
		}
		$script:panelMainProgress.Controls.Add($script:labelProgressDetail)
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$script:labelProgressHead | % {
			$_.DataBindings.DefaultDataSourceUpdateMode = 0
			$_.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,0)
			$_.ImageAlign = 16
			$_.Location = New-Object System.Drawing.Point(12,9)
			$_.Name = "labelProgressHead"
			$_.Size = New-Object System.Drawing.Size(454, 36)
			$_.TabIndex = 0
			$_.Text = "."
			$_.TextAlign = 16
		}
		$script:panelMainProgress.Controls.Add($script:labelProgressHead)
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$script:frmProgress.Controls.Add($script:panelMainProgress)
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Set-Progress-Title {
	Param($titleText) 
		
	$script:frmProgress.Text = $titleText;
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Set-Progress-Headtext {
	Param($headText) 
	
	$script:labelProgressHead.Text = $headText	
	$script:frmProgress.Refresh()	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Set-Progress-DetailText {
	Param($detailText) 

	$script:labelProgressDetail.Text = $detailText
	$script:frmProgress.Refresh()
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Set-Progress-Values {
	Param(
		[Parameter( Mandatory=$true)][ValidateNotNullOrEmpty()]$minValue,
		[Parameter( Mandatory=$true)][ValidateNotNullOrEmpty()]$maxValue,
		[Parameter( Mandatory=$true)][ValidateNotNullOrEmpty()]$stepValue
		) 

	$script:progressProgress.Maximum = $maxValue
	$script:progressProgress.Minimum = $minValue	
	$script:progressProgress.Step = $stepValue	
	$script:progressProgress.Value = $minValue	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Perform-Progress-Step {
	$script:progressProgress.PerformStep() | out-null
	$script:frmProgress.Refresh()
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Show-Progress {
	$script:frmProgress.Show()| Out-Null
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
function Hide-Progress {
	$script:frmProgress.Hide()| Out-Null
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
#endregion FORMPROGRESS 
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Import-RadioStationsFromListenLive {
[CmdletBinding()]
Param	(
			[string]$URL,
			[string]$Region		= "",
			[string]$Country	= "",
			[string]$State		= ""
		 )
	# Parsing HTML with IE.

	try {
		$oIE = New-Object -ComObject InternetExplorer.Application
	} catch {
		return $null
	}
	$oIE.Silent = $True
	$oIE.Visible = $False
	$oIE.Navigate($URL)

	<#
	while ($oIE.Busy) {
		[System.Threading.Thread]::Sleep(10)
	} 
	#>
	do {
		Start-Sleep -MilliSeconds  250
	} until ($oIE.ReadyState -eq 4)

	
	$oHtmlDoc = $oIE.Document

	# Getting table by ID.
	# $oHtmlDoc.IHTMLDocument3_getElementsByID("thetable3")
	try {
		$oTable = $oHtmlDoc.getElementByID("thetable3")
		#$oTable = $oHtmlDoc.IHTMLDocument3_getElementsByID("thetable3")
	} catch {
		"ERROR Get oTable $($_)" | out-host
		$oTable = $null
	}
	if (($oTable -eq $null) -or ($oTable.Gettype() -eq [System.DBNull] )) {
		"oTable is NULL" | out-host
		$oIE.Quit()
		return $null
	}
	# Extracting table rows as a collection.
	#
	# NOTE : MUST look at nodeType : see http://www.w3schools.com/jsref/prop_node_nodetype.asp
	#		 cause not all Nodes have the property tagName
	#

	try {
		$oTbody = $oTable.childNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "tbody") }
		$cTrs 	= $oTbody.childNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "tr") }
	} catch {
		"ERROR Get oTBody $($_)" | out-host
		$oIE.Quit()
		return $null
	}
	<#
	Jede TR splittet sich in 5 TD'
	TD[0] : Name und WebSite
	TD[1] : Ort
	TD[2] : Images .... brauchen wir nicht
	TD[3] : 1..2 URL mit Bitrate
	TD[4] : Genre
	#>
	Set-Progress-Values -MinValue 0 -MaxValue $cTrs.Count -StepValue 1
	$cTrs | Select-Object -Skip 1 | ForEach-Object {
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$oTr = $_
		$cTds = $oTr.childNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "td") }

		$StationName	= $cTds[0].ChildNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "a")} | foreach-object {$_.ChildNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "b")}} | foreach-object {$_.innerHtml}
		Set-Progress-DetailText $StationName
		
		$StationWebSite	= $cTds[0].ChildNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "a")} | foreach-object {$_.href}
		$StationCity    = $cTds[1].innerHtml
		
		$cAs			= $cTds[3].ChildNodes | where-object { ($_.nodeType -eq 1) -and ($_.tagName -eq "a")}
		$BitRates		= @()
		$BitRates 		= (($cAs | foreach-object {$_.innerHtml}) -replace "Kbps","").Trim()
		$HRefs			= @()
		$HRefs			= $cAs | foreach-object {$_.href}
		
		$StationGenre   = $cTds[4].innerHtml
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ($StationName -and ($StationName -ne "")) {
			if ($BitRates -is [array]) {
				$NetworkStreamData = New-Object PSObject -Property @{
					ID				= $script:DummyID
					StreamType		= "WebRadio"
					Name			= $StationName
					URL				= $HRefs[0]
					WebSite			= $StationWebSite
					Region			= $Region
					Country			= $Country
					State			= $State
					City			= $StationCity
					Genre			= $StationGenre
					Bitrate			= $BitRates[0]
					Rate			= "0"
					Tags			= $StationGenre
					Annotation		= "Imported from $($URL) $((Get-Date).ToShortDateString())"
					Favorite		=  "0"
				}	
				Write-Output $NetworkStreamData
				$NetworkStreamData = New-Object PSObject -Property @{
					ID				= $script:DummyID
					StreamType		= "WebRadio"
					Name			= $StationName
					URL				= $HRefs[1]
					WebSite			= $StationWebSite
					Region			= $Region
					Country			= $Country
					State			= $State
					City			= $StationCity
					Genre			= $StationGenre
					Bitrate			= $BitRates[1]
					Rate			= "0"
					Tags			= $StationGenre
					Annotation		= "Imported from $($URL) $((Get-Date).ToShortDateString())"
					Favorite		=  "0"
				}	
				Write-Output $NetworkStreamData
			} else {
				$NetworkStreamData = New-Object PSObject -Property @{
					ID				= $script:DummyID
					StreamType		= "WebRadio"
					Name			= $StationName
					URL				= $HRefs
					WebSite			= $StationWebSite
					Region			= $Region
					Country			= $Country
					State			= $State
					City			= $StationCity
					Genre			= $StationGenre
					Bitrate			= $BitRates
					Rate			= "0"
					Tags			= $StationGenre
					Annotation		= "Imported from $($URL) $((Get-Date).ToShortDateString())"
					Favorite		=  "0"
				}	
				Write-Output $NetworkStreamData
			}
		}
		Perform-Progress-Step
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Select-ImportParameterListenLive {
[CmdletBinding()]
Param	()


		# ---------------------------------------------------------------------------------------------------------------------
	$script:formMainImportParameter		= New-Object System.Windows.Forms.Form
		$labelCountry	 	= New-Object System.Windows.Forms.Label
		$comboboxCountry	 = New-Object System.Windows.Forms.ComboBox	
		
		$buttonOk		= New-Object System.Windows.Forms.Button
		
	$BorderDist = 5
	$Dist = 3
	
	$formHeight = 420 
	$labelHeight= 24
	$Labelwidth  = 120
	$comboboxWidth = 160

	$formWidth = (2*$BorderDist) + $Labelwidth + $comboboxWidth
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$xPos = $BorderDist
	$yPos = $BorderDist
	$labelCountry  | % {
		$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left )
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($Labelwidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.ForeColor = [System.Drawing.Color]::White
		$_.TabStop = $false
		$_.Text = "Country"
	}
	$xPos += $Labelwidth + $Dist
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$comboboxCountry | % {
		$_.AutoSize = $False
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboboxWidth,$labelHeight)
		$_.TabStop = $false
	}	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$yPos += ($labelHeight + $Dist)
	$xPos = $formWidth - $BorderDist - 100
	$buttonOk | % {
		$_.AutoSize = $False
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.ForeColor = [System.Drawing.Color]::Black
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "ButtonOk"
		$_.Size = New-Object System.Drawing.Size(100, $labelHeight)
		$_.Text = "Ok"
		$_.UseVisualStyleBackColor = $True	
		$_.TabStop = $false
	}
	$yPos += $labelHeight + $BorderDist
	$formHeight = $yPos
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$script:formMainImportParameter | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_NetworkStreamsManager
		
		$_.Controls.Add($labelCountry)
		$_.Controls.Add($comboboxCountry)
		$_.Controls.Add($buttonOk)
		
		$_.Name = "formMainImportParameter"
		$_.ControlBox = $True
		$_.MaximizeBox = $False
		$_.MinimizeBox = $False
		$_.ShowInTaskbar = $False
		$_.Icon = $script:ScriptIcon
		$Text = "Import Parameter"
		$_.Text = $Text
		
		$_.Font = $Script:FontBase
		
		$_.StartPosition = "CenterParent"
		$_.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
			
		$_.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$buttonOk.Add_Click({
		$formMainImportParameter.DialogResult = [System.Windows.Forms.DialogResult]::Ok
		$formMainImportParameter.Close()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$comboboxCountry.Items.Clear()
	$comboboxCountry.Items.AddRange($script:ListenLiveCountryList)			
	$comboboxCountry.SelectedItem = $script:ListenLiveCountry_Germany
		
	if ($script:formMainImportParameter.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok) {
		$SelItemText = $comboboxCountry.SelectedItem
		
		$ParameterListenLive = New-Object PSObject -Property @{
							URL		= $script:ListenLiveParameter[$SelItemText].URL
							Region 	= $script:ListenLiveParameter[$SelItemText].Region
							Country = $script:ListenLiveParameter[$SelItemText].Country
							State   = $script:ListenLiveParameter[$SelItemText].State
							}
	} else {
		$ParameterListenLive = $null
	}
	
	Write-Output $ParameterListenLive
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Import-ListenLiveStations {
[CmdletBinding()]
Param	()

	$Parameter = Select-ImportParameterListenLive
	
	if ($Parameter -ne $null) {
		$StationsCounter = 0
		$ExistCounter = 0
		$NotResponseCounter = 0
		$AddedCounter = 0
			
		Generate-FormProgress
		Set-Progress-Title "Import Stream Station $($Parameter.URL)"
		Show-Progress
		
		Set-Progress-Headtext "Import from Website...."
		$Stations = Import-RadioStationsFromListenLive -URL $Parameter.URL -Region $Parameter.Region -Country $Parameter.Country -State $Parameter.State -Verbose
		
		if ($Stations -ne $null) {
			if (!$script:xmlNetworkStreamDataSet.Tables["StreamingStations"]) {
				Add-TableStreamingStations $xmlNetworkStreamDataSet
			}
		
			$StationsCounter = $Stations.count
			$ExistCounter = 0
			$NotResponseCounter = 0
			$AddedCounter = 0
			
			Set-Progress-Headtext "Check Stations...."
			Set-Progress-DetailText ""
			Set-Progress-Values -MinValue 0 -MaxValue $StationsCounter -StepValue 1
			
			$NewStations = $Stations | ForEach-Object {
				$Station = $_
				Set-Progress-DetailText "Test exist in DB : $($Station.Name)"
				
				$Filter = "URL = '"+$Station.URL+"'"
				$ExistingStations = $script:xmlNetworkStreamDataSet.Tables["StreamingStations"].Select($Filter)
				if ($ExistingStations) {
					#"EXIST ------------------------------------------------------" | out-host
					#$ExistingStations | out-host
					#"------------------------------------------------------------" | out-host
					$ExistCounter++
				} else {
					Set-Progress-DetailText "Test URL Response : $($Station.Name)"
					$Avail = Test-StreamURLAvailaible $Station.URL
					
					if ($Avail) {
						Set-Progress-DetailText "Add to DB : $($Station.Name)"
						#
						Save-NetworkStreamData $script:xmlNetworkStreamDataSet $script:xmlNetworkStreamFilename $script:DummyID $Station
						$AddedCounter++
						#
					} else {
						$NotResponseCounter++
					}
				}
				Perform-Progress-Step
			}
			Hide-Progress
		} else {
			Hide-Progress
			Show-MessageBox -Title "$script:ScriptName" -Text "Die WebSite $($Parameter.URL) lies sich nicht einlesen.`nBitte diese Anwendung neu starten und noch einmal probieren." -buttons "Ok" -Icon "Information"
		}
		
		"Stations to Import    : $StationsCounter" | out-host
		"Stations Exist in DB  : $ExistCounter" | out-host
		"Stations not Response : $NotResponseCounter" | out-host
		"Stations Added		   : $AddedCounter" | out-host
		$script:checkboxShowFavorite.Checked = $false
		Load-SearchSettings
		Load-StationList -OnlyFavorites:$script:checkboxShowFavorite.Checked
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Import-RadioBrowserStations {
[CmdletBinding()]
Param	()
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Select-ImportedStationsGUI {
[CmdletBinding()]
Param	()
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#

