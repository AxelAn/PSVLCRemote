#################################################################################################
# Name			: 	PSVLCRemoteGUIFileExplorer.ps1
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
#region ImageList
[string]$FolderIconString=@"	
AAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAACAAACAAAAAgIAAgAAAAIAAgACAgAAAwMDAAMDcwADwyqYABAQEAAgICAAMDAwAERERABYW
FgAcHBwAIiIiACkpKQBVVVUATU1NAEJCQgA5OTkAgHz/AFBQ/wCTANYA/+zMAMbW7wDW5+cAkKmtAAAA
MwAAAGYAAACZAAAAzAAAMwAAADMzAAAzZgAAM5kAADPMAAAz/wAAZgAAAGYzAABmZgAAZpkAAGbMAABm
/wAAmQAAAJkzAACZZgAAmZkAAJnMAACZ/wAAzAAAAMwzAADMZgAAzJkAAMzMAADM/wAA/2YAAP+ZAAD/
zAAzAAAAMwAzADMAZgAzAJkAMwDMADMA/wAzMwAAMzMzADMzZgAzM5kAMzPMADMz/wAzZgAAM2YzADNm
ZgAzZpkAM2bMADNm/wAzmQAAM5kzADOZZgAzmZkAM5nMADOZ/wAzzAAAM8wzADPMZgAzzJkAM8zMADPM
/wAz/zMAM/9mADP/mQAz/8wAM///AGYAAABmADMAZgBmAGYAmQBmAMwAZgD/AGYzAABmMzMAZjNmAGYz
mQBmM8wAZjP/AGZmAABmZjMAZmZmAGZmmQBmZswAZpkAAGaZMwBmmWYAZpmZAGaZzABmmf8AZswAAGbM
MwBmzJkAZszMAGbM/wBm/wAAZv8zAGb/mQBm/8wAzAD/AP8AzACZmQAAmTOZAJkAmQCZAMwAmQAAAJkz
MwCZAGYAmTPMAJkA/wCZZgAAmWYzAJkzZgCZZpkAmWbMAJkz/wCZmTMAmZlmAJmZmQCZmcwAmZn/AJnM
AACZzDMAZsxmAJnMmQCZzMwAmcz/AJn/AACZ/zMAmcxmAJn/mQCZ/8wAmf//AMwAAACZADMAzABmAMwA
mQDMAMwAmTMAAMwzMwDMM2YAzDOZAMwzzADMM/8AzGYAAMxmMwCZZmYAzGaZAMxmzACZZv8AzJkAAMyZ
MwDMmWYAzJmZAMyZzADMmf8AzMwAAMzMMwDMzGYAzMyZAMzMzADMzP8AzP8AAMz/MwCZ/2YAzP+ZAMz/
zADM//8AzAAzAP8AZgD/AJkAzDMAAP8zMwD/M2YA/zOZAP8zzAD/M/8A/2YAAP9mMwDMZmYA/2aZAP9m
zADMZv8A/5kAAP+ZMwD/mWYA/5mZAP+ZzAD/mf8A/8wAAP/MMwD/zGYA/8yZAP/MzAD/zP8A//8zAMz/
ZgD//5kA///MAGZm/wBm/2YAZv//AP9mZgD/Zv8A//9mACEApQBfX18Ad3d3AIaGhgCWlpYAy8vLALKy
sgDX19cA3d3dAOPj4wDq6uoA8fHxAPj4+ADw+/8ApKCgAICAgAAAAP8AAP8AAAD//wD/AAAA/wD/AP//
AAD///8ACgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCjAweXl5
eXl5eXl5eXl5Cgoww5qaoJqgmpqampqaeQoKMMOgoJqgmqCamqCgmnkKCjDDoKCgoKCgmqCamqB5Cgow
w6CgoKCgmqCaoKCaeQoKMMOgoKCgoKCaoJqaoHkKCjDDoKCgoKCgoJqgoJp5Cgoww8PDw8PDw8PDw8PD
eQoKMHl5eXl5eXkwMDAwMDAKCgow/6CgoKAwCgoKCgoKCgoKCjAwMDAwCgoKCgoKCgoKCgoKCgoKCgoK
CgoKCgoKCgoKCgoKCgoKCgoKCgoKCv//AAD//wAAwAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAA
AACAAAAAgAEAAMA/AADgfwAA//8AAP//AAA=	
"@	
$iconStream=[System.IO.MemoryStream][System.Convert]::FromBase64String($FolderIconString)
$iconBmp=[System.Drawing.Bitmap][System.Drawing.Image]::FromStream($iconStream)
$iconHandle=$iconBmp.GetHicon()
$FolderIcon=[System.Drawing.Icon]::FromHandle($iconHandle)

[string]$FileIconString=@"
AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAC3opP/Y0k1/2NJNf9jSTX/Y0k1/2NJNf9jSTX/Y0k1/2NJNf9jSTX/Y0k1/2NJ
Nf8AAAAAAAAAAAAAAAAAAAAAt6KT//fl3P+3opP/t6KT/7eik/+3opP/t6KT/7eik/+3opP/t6KT/7ei
k/9jSTX/AAAAAAAAAAAAAAAAAAAAALeik//56eL/+Obd//fi2P/13tP/9NvO//PXyv/y1MX/8dDB//DN
vP+3opP/Y0k1/wAAAAAAAAAAAAAAAAAAAAC3opP/+e7o//jq4//45t7/9+PZ//Xf1f/129D/89jL//LV
xv/x0cL/t6KT/2NJNf8AAAAAAAAAAAAAAAAAAAAAt6KT//vy7f/meED/3m42//jn4P/ErqL/wKmc/7ui
lf+1nI3/89XH/7eik/9jSTX/AAAAAAAAAAAAAAAAAAAAALeik//89vP/+/Lu//vv6v/56+b/+ejh//fl
2//24df/9N7T//Pazf+3opP/Y0k1/wAAAAAAAAAAAAAAAAAAAAC6pZb//fn2/+Z4QP/ebjb/+vDr/8Su
ov/AqJz/u6KU/7Wbjf/139P/t6KT/2NJNf8AAAAAAAAAAAAAAAAAAAAAvqma//78+//9+fj//ff0//z0
8P/78e3/+u7o//jq5P/359//9uLa/7eik/9jSTX/AAAAAAAAAAAAAAAAAAAAAMOunv/+/v7/5nhA/95u
Nv/9+PX/xK6i/8Com/+7opT/tpyN//jo3/+3opP/Y0k1/wAAAAAAAAAAAAAAAAAAAADIsqP/////////
/////fz//fv5//359v/89fL/+/Lu//vv6v/57Ob/t6KT/2NJNf8AAAAAAAAAAAAAAAAAAAAAzLan////
///meED/3m42///9/f/FrqL/wKmb//z28//79O//t6KT/7eik/9kSjb/AAAAAAAAAAAAAAAAAAAAANG7
q/////////////////////////79//77+//9+fj/t6KT/2RKNv9kSjb/ZEo2/wAAAAAAAAAAAAAAAAAA
AADVv6///////////////////////////////v7//vz7/7mklf/Uxbr/Y0k1/6KLeqkAAAAAAAAAAAAA
AAAAAAAA2MKy/////////////////////////////////////v/Aq5z/Y0k1/6KLeqgAAAAAAAAAAAAA
AAAAAAAAAAAAANjCsv/YwrL/2MKy/9jCsv/YwrL/2MKy/9S+rv/Puan/ybOk/8mzpIsAAAAAAAAAAAAA
AAAAAAAA//8AAMADAADAAwAAwAMAAMADaf/AA97/wAP2/8AD8//AA/H/wAPu/8AD6//AA+j/wAPk/8AD
4v/AB97/wA/b/w==
"@
$iconStream=[System.IO.MemoryStream][System.Convert]::FromBase64String($FileIconString)
$iconBmp=[System.Drawing.Bitmap][System.Drawing.Image]::FromStream($iconStream)
$iconHandle=$iconBmp.GetHicon()
$FileIcon=[System.Drawing.Icon]::FromHandle($iconHandle)

$imageList = new-Object System.Windows.Forms.ImageList 
$imageList.ImageSize = New-Object System.Drawing.Size (16,16)
$imageList.Images.Add("folder",$FolderIcon) 
$imageList.Images.Add("file",$FileIcon) 
#endregion ImageList
#
#
$script:formMainFileExplorer = $null
$script:TreeViewFolder = $null
$script:listViewFiles = $null
	
$script:SelectedNode = $null	
	
$contextMenuLV = New-Object System.Windows.Forms.ContextMenu
	$menuItem_Play					= $contextMenuLV.MenuItems.Add("Abspielen")
	$menuItem_PlayAsDVD				= $contextMenuLV.MenuItems.Add("Als DVD abspielen")
	$menuItem_PlayAndAddToPlaylist	= $contextMenuLV.MenuItems.Add("Abspielen und zur Playlist zufügen")
	$menuItem_AddToPlaylist			= $contextMenuLV.MenuItems.Add("Zur Playlist zufügen")

$contextMenuTV = New-Object System.Windows.Forms.ContextMenu
	$menuItemTV_PlayAndAddToPlaylist	= $contextMenuTV.MenuItems.Add("Abspielen und zur Playlist zufügen")
	#$menuItemTV_PlayAsDVD				= $contextMenuLV.MenuItems.Add("Als DVD abspielen")
	$menuItemTV_AddToPlaylist			= $contextMenuTV.MenuItems.Add("Zur Playlist zufügen")	
	$menuItemTV_Delimiter1				= $contextMenuTV.MenuItems.Add("-")	
	$menuItemTV_Refresh					= $contextMenuTV.MenuItems.Add("Aktualisieren (F5)")	
	
$nulNode = "<NULL>"

#################################################################################################
#
	# ---------------------------------------------------------------------------------------------------------------------
	function TV-Add-RootsTree {
			
		$script:TreeViewFolder.BeginUpdate()
		$script:TreeViewFolder.Nodes.Clear()
		
		$RootFolder = Get-VLCRemote-Volumes $script:CommonVLCRemoteController
		#$Rootfolder | out-host
		
		if ($RootFolder) {
			$RootFolder | % {
				$nod = $script:TreeViewFolder.Nodes.Add($_.Path)
				$nod.ImageIndex = 0
				$nod.Tag = $_
				
				# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				$nod.ToolTipText = ""
				[void]$nod.Nodes.Add($nulNode)
			}		
		}
		$script:TreeViewFolder.EndUpdate()
	}
	# ---------------------------------------------------------------------------------------------------------------------
	function TV-Add-Folder {
		Param (
			[Parameter(Mandatory=$true)][System.Windows.Forms.TreeNode]$SelectedNode,
			[switch]$Forced = $False
		)
		
		if (($SelectedNode.FirstNode.Text -ieq $nulNode) -or $Forced) {
			$SelectedNode.Nodes.Clear()

			#try {
				$Tag = $SelectedNode.Tag 
				#$Tag | out-host
				
				$SearchUri = $Tag.Uri
				$Files = Get-VLCRemote-Files $script:CommonVLCRemoteController $SearchUri
				#$Files | out-host
				
				if ($Files) {
					$Files | where {($_.Type -ieq "dir") -and ($_.name -ne "..")} | % {
						#$name = Split-Path ((([System.Uri]::UnescapeDataString($_.Uri)) -replace "file:///","") -replace "//","/") -leaf
						$name = $_.name
						

						$tn = new-object System.Windows.Forms.TreeNode
						$tn.Text = $name
						$tn.Tag  = $_
						$tn.ImageIndex = $tn.SelectedImageIndex = 0
						$tn.Nodes.Add($nulNode)

						[Void]$SelectedNode.Nodes.add( $tn )
					}
				}
			#} catch {
				#$_.Exception.Message | out-host
			#
		}
	}
	# ---------------------------------------------------------------------------------------------------------------------
	Function Add-TagToPlaylist {
		Param (
				[PSObject]$Tag,
				[switch]$PlayFirstItem
			  )
				
		$bIsPlayed = $False		
		$IsFirstItem = $True
		
		if ($Tag.Type -eq "dir") {
			$Files = Get-VLCRemote-FilesRecursive $script:CommonVLCRemoteController $Tag.Uri
			$Script:ProgressBar.Maximum = $Files.Count
			$Script:ProgressBar.Minimum = 0
			$Script:ProgressBar.Value = 0	
			
			Foreach ($F in $Files) {
				$Script:ProgressBar.Value++
				
				if ($PlayFirstItem -and $IsFirstItem) {
					Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $F.Uri
					$IsFirstItem = $false
				} else {
					Send-VLCRemote-AddFileToPlaylist  $script:CommonVLCRemoteController $F.Uri
				}				
			}
			$Script:ProgressBar.Maximum = 0
			$Script:ProgressBar.Minimum = 0
			$Script:ProgressBar.Value = 0	
		} elseif ($Tag.Type -eq "file") {
			if (Test-ValidFilename $tag.uri) {
				if ($PlayFirstItem -and $IsFirstItem) {
					Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Tag.Uri
					$IsFirstItem = $false
				} else {
					Send-VLCRemote-AddFileToPlaylist  $script:CommonVLCRemoteController $Tag.Uri
				}
			}
		}
		Write-Output $bIsPlayed
		
	}
	
	function PopulateListViewExplorerFiles {
		Param($Tag)
		# ---------------------------------------------------------------------------------------------------------------------
		Function Format-DiskSize() {
			Param ([int64]$dSize)
			If ($dSize -ge 1TB) {[string]::Format("{0:0.00} TB", $dSize / 1TB)}
			ElseIf ($dSize -ge 1GB) {[string]::Format("{0:0.00} GB", $dSize / 1GB)}
			ElseIf ($dSize -ge 1MB) {[string]::Format("{0:0.00} MB", $dSize / 1MB)}
			ElseIf ($dSize -ge 1KB) {[string]::Format("{0:0.00} KB", $dSize / 1KB)}
			ElseIf ($dSize -gt 0) {[string]::Format("{0:0} Bytes", $dSize)}
			Else {""}
		}
		# ---------------------------------------------------------------------------------------------------------------------
		
		$SearchUri = $Tag.Uri
		$Files = Get-VLCRemote-Files $script:CommonVLCRemoteController $SearchUri
		#$Files | out-host
		
		if ($Files) {
			$Files | where {($_.Type -ieq "dir") -and ($_.name -ne "..")} | % {
				$item = new-object System.Windows.Forms.ListViewItem($_.Name)
				$item.ImageIndex = 0
				$item.SubItems.Add("DIR")  | out-null	

				$dt = new-object System.DateTime(1970, 1, 1, 0, 0, 0, 0, [System.DateTimeKind]::Utc)
				$dt = $dt.AddSeconds($_.access_time).ToLocalTime();
				
				$item.SubItems.Add($dt.ToString())  | out-null		
				
				$item.tag = $_
				$script:listViewFiles.Items.Add($item)	| out-null
			}
			
			$Files | where {$_.Type -ieq "file"} | % {
				$item = new-object System.Windows.Forms.ListViewItem($_.Name)
				$item.ImageIndex = 1
				$item.SubItems.Add((Format-DiskSize $_.size))  | out-null	

				$dt = new-object System.DateTime(1970, 1, 1, 0, 0, 0, 0, [System.DateTimeKind]::Utc)
				$dt = $dt.AddSeconds($_.access_time).ToLocalTime();
				
				$item.SubItems.Add($dt.ToString())  | out-null		
				
				$item.tag = $_
				$script:listViewFiles.Items.Add($item)	| out-null
			}
		}
	}
	# ---------------------------------------------------------------------------------------------------------------------
	function Test-FolderIsDVD {
		Param($Tag)

		#$Item.Tag | out-Host
						
		$IsDVDFolder = $False
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		$SearchUri = $Tag.Uri
		$Files = Get-VLCRemote-Files $script:CommonVLCRemoteController $SearchUri
		if ($Files) {
			$Files | where {($_.Type -ieq "file") -and ($_.Name -ieq "VIDEO_TS.IFO")} | % {
				$IsDVDFolder = $True
			}
			if (!$IsDVDFolder) {
				$Files | where {($_.Type -ieq "dir") -and ($_.Name -ieq "VIDEO_TS")} | % {
					$SubFiles = Get-VLCRemote-Files $script:CommonVLCRemoteController $_.Uri
					
					$SubFiles | where {($_.Type -ieq "file") -and ($_.Name -ieq "VIDEO_TS.IFO")} | % {
						$IsDVDFolder = $True
					}
				}
			}
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		Write-Output $IsDVDFolder
	}
	# ---------------------------------------------------------------------------------------------------------------------

Function Show-VLCRemoteFileExplorer {
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
	$script:formMainFileExplorer						= New-Object System.Windows.Forms.Form
		$PanelMain										= New-Object System.Windows.Forms.Panel
			
			$SplitContainerFileExplorer				= New-Object System.Windows.Forms.SplitContainer
				$PanelFileExplorerFolder			= New-Object System.Windows.Forms.Panel
					$script:TreeViewFolder 				= New-Object System.Windows.Forms.TreeView
				$PanelFileExplorerFiles				= New-Object System.Windows.Forms.Panel
					$script:listViewFiles					= New-Object System.Windows.Forms.ListView
						
			$PanelBottom							= New-Object System.Windows.Forms.Panel
				$Script:ProgressBar 						= New-Object System.Windows.Forms.ProgressBar
				$picBoxTraydown						= New-Object System.Windows.Forms.PictureBox
				
	#endregion OBJECT Definitions	
	#region BUILD Controls
	$formWidth   = 880
	$formHeight  = 540

	$treeviewWidth = 300
	$listviewWidth = 580
	
	$borderDist  = 5
	$dist = 3
		
	$picboxCOntrolWidth = 36
	$picboxCOntrolWidthSmall = 24
	# ---------------------------------------------------------------------------------------------------------------------

	$script:TreeViewFolder | % {
		#$_.Location = New-Object System.Drawing.Point(0,0)
		#$_.Size = New-Object System.Drawing.Size($treeviewWidth,$formHeight)
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_FileExplorer 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_FileExplorer 
				

		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (5)
		$_.Sorted = $false
		$_.HideSelection = $false
		$_.ShowLines = $true
		$_.ShowRootLines = $false
		$_.ShowNodeToolTips = $true
		$_.PathSeparator = "/"
		$_.SelectedImageIndex = 0
		$_.ImageIndex = 0;
		$_.ImageList = $imagelist
		$_.TabStop = $false	
	}
	# ---------------------------------------------------------------------------------------------------------------------
	$PanelFileExplorerFolder | % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "PanelFileExplorerFolder"
		$_.TabStop = $false
		$_.Controls.Add($script:TreeViewFolder)
	}
	# ---------------------------------------------------------------------------------------------------------------------
	$script:listViewFiles  | % {
		$_.Name = "ListViewFiles"	
		$_.CheckBoxes = $False
		$_.DataBindings.DefaultDataSourceUpdateMode = 0
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_FileExplorer 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_FileExplorer 
		
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.Location = New-Object System.Drawing.Point(0, 0)
		#$_.Size = New-Object System.Drawing.Size($listviewWidth,$formHeight)
		
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
		$_.SmallImageList = $ImageList
		$_.AutoArrange = $True
		#$_.ContextMenu = $null
		$_.ContextMenu = $contextMenuLV
	}

	$script:listViewFiles.Clear()
	[void]$script:listViewFiles.Columns.Add("Name", 220, [windows.forms.HorizontalAlignment]::left)
	[void]$script:listViewFiles.Columns.Add("Size", 100, [windows.forms.HorizontalAlignment]::Right)
	[void]$script:listViewFiles.Columns.Add("Modified", 130, [windows.forms.HorizontalAlignment]::Right)

	# ---------------------------------------------------------------------------------------------------------------------
	$PanelFileExplorerFiles   | % {
		#$_.Autosize = $True
		#$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink	
		#$_.Anchor =([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "PanelFileExplorerFiles"
		$_.TabStop = $false
		$_.Controls.Add($script:listViewFiles)		
	}
	# ---------------------------------------------------------------------------------------------------------------------
	$SplitContainerFileExplorer   | % {
		$_.Name = "SplitContainerFileExplorer"
		
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		#$_.Location = New-Object System.Drawing.Point(0,0)
		#$_.Size = New-Object System.Drawing.Size(705,$FormHeight)
		$_.SplitterDistance = 50
		$_.SplitterWidth = 3
		$_.TabStop = $false
		
		# Horizontal, Vertical . Horizontal meint, Oben und unten, Vertical meint links und rechts
		$_.Orientation = [System.Windows.Forms.Orientation]::Vertical
		
		$_.Panel1.Controls.Add($script:TreeViewFolder)
		$_.Panel2.Controls.Add($script:listViewFiles)		
	}
	# ---------------------------------------------------------------------------------------------------------------------	
	$Script:ProgressBar | % {
		$_.Autosize = $False
		$_.Location = New-Object System.Drawing.Point($borderDist,$borderDist)
		$_.Size = New-Object System.Drawing.Size(240,16)
		$_.Maximum = 0
		$_.Minimum = 0
		$_.Value = 0	
					
		$_.Name = "progressBar"
		$_.TabStop = $false
		$_.Style = [System.Windows.Forms.ProgressBarStyle]::Blocks
	}
	# ---------------------------------------------------------------------------------------------------------------------	
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
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_FileExplorerBottom 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_FileExplorerBottom 
				
		
		$_.Margin = New-Object System.Windows.Forms.Padding (0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "panelBottom"
		$_.TabStop = $false
		$_.Controls.Add($Script:ProgressBar)
		$_.Controls.Add($picBoxTraydown)
	}	
	# ---------------------------------------------------------------------------------------------------------------------	
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
		$_.Controls.Add($SplitContainerFileExplorer)			
		$_.Controls.Add($PanelBottom)			
	}
	# ---------------------------------------------------------------------------------------------------------------------	
	$script:formMainFileExplorer | % {
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		$_.BackColor = Get-VLCRemoteThemeBackground $script:ThemeElement_FileExplorer 
		$_.ForeColor = Get-VLCRemoteThemeForeground $script:ThemeElement_FileExplorer 
		
		#$_.BackColor = [System.Drawing.Color]::CornSilk
		$_.Name = "formDialogFileExplorer"
		$_.ControlBox = $false
		$_.ShowInTaskbar = $false
		$_.Padding = New-Object System.Windows.Forms.Padding (3,3,3,3)
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsExplorerWindowID
		
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
		
		$_.Text = "$script:ScriptName : FileExplorer"
		$_.Controls.Add($PanelMain)
			
		$_.Font = $Script:FontBase

	}	
	# ---------------------------------------------------------------------------------------------------------------------
	#endregion BUILD Controls
	# ---------------------------------------------------------------------------------------------------------------------
	$contextMenuLV.add_Popup({
	
		$menuItem_Play.Enabled = $false
		$menuItem_PlayAsDVD.Enabled = $False
		
		if ($script:listViewFiles.SelectedItems.count -eq 1) {
			$Item = $script:listViewFiles.SelectedItems[0]
			If ($Item.Tag.Type -ieq "file") {
				if (Test-ValidFilename $Item.tag.uri) {
					$menuItem_Play.Enabled = $true
				}
			} elseif ($Item.Tag.Type -ieq "dir") {
				if ((Test-FolderIsDVD $Item.Tag)) {
					$menuItem_PlayAsDVD.Enabled = $True
				}
			}
		} 
		#
		# ToDo : Hier Test auf ValidFilename komplett !!!!!!!!!!!!!!!!!!!
		#
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItem_Play.Add_Click({

		if ($script:listViewFiles.SelectedItems.Count -gt 0) {
			Foreach ($Item in $script:listViewFiles.SelectedItems) {
				$Tag = $Item.Tag
				Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Tag.Uri
			}
		} 
		Load-Playlist
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItem_PlayAsDVD.Add_Click({

		if ($script:listViewFiles.SelectedItems.Count -eq 1) {
			$Item = $script:listViewFiles.SelectedItems[0]
			$Tag = $Item.Tag
			$Uri = $Tag.Uri -replace "file:","dvd:"
			
			Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Uri
			
		}
	})
	# ---------------------------------------------------------------------------------------------------------------------
	
	$menuItem_PlayAndAddToPlaylist.Add_Click({
	
		if ($script:listViewFiles.SelectedItems.Count -gt 0) {
			$IsFirstItem = $true
			Foreach ($Item in $script:listViewFiles.SelectedItems) {
				$Tag = $Item.Tag
				$IsPlayed = Add-TagToPlaylist -Tag $Tag	-PlayFirstItem:$IsFirstItem
				if ($IsPlayed) {$IsFirstItem = $false}
			}
		} 
		Load-Playlist
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItem_AddToPlaylist.Add_Click({
		if ($script:listViewFiles.SelectedItems.Count -gt 0) {
			Foreach ($Item in $script:listViewFiles.SelectedItems) {
				$Tag = $Item.Tag
				$IsPlayed = Add-TagToPlaylist -Tag $Tag	-PlayFirstItem:$False
			}
		} 
		Load-Playlist
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:formMainFileExplorer.add_Load({
		TV-Add-RootsTree 
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:formMainFileExplorer.Add_Activated({
		$script:formMainFileExplorer.Opacity = $script:Opacity_Activated_Fileexplorer
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainFileExplorer.Add_DeActivate({
		$script:formMainFileExplorer.Opacity = $script:Opacity_Deactivate_Fileexplorer
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:TreeViewFolder.Add_BeforeExpand({
		TV-Add-Folder $_.Node
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:TreeViewFolder.Add_AfterSelect({
		$Tag = $_.Node.Tag 
		$script:listViewFiles.Items.Clear()
		PopulateListViewExplorerFiles $Tag
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:TreeViewFolder.Add_KeyDown({
		if ($_.KeyData -ieq "F5") {
			if ($script:TreeViewFolder.SelectedNode -ne $null) {
				TV-Add-Folder  $script:TreeViewFolder.SelectedNode -Forced:$true
				$Tag = $script:TreeViewFolder.SelectedNode.Tag 
				$script:listViewFiles.Items.Clear()
				PopulateListViewExplorerFiles $Tag
			}
		} 
	})	
	# ---------------------------------------------------------------------------------------------------------------------

	$script:TreeViewFolder.add_MouseUp({
		#"TV Event : MouseUP" | out-Host

		if ($_.Button -eq 'Right') {
		
			$P = New-Object System.Drawing.Point ($_.X,$_.Y)
			
			$Node = $script:TreeViewFolder.GetNodeAt($P)
			
			if ($Node -ne $Null) {
				
				$script:TreeViewFolder.SelectedNode = $Node 
				
				$contextMenuTV.Show($script:TreeViewFolder,$P)
				
			}
		}
	})
	# ---------------------------------------------------------------------------------------------------------------------	
	$script:listViewFiles.Add_Keydown({
		Param($o,$e)
		
		if ($e.Control -and ($e.Keycode -eq "A")) {
			foreach ($Item in $script:listViewFiles.Items) {
				$Item.Selected = $true
			}
		}
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:listViewFiles.add_DoubleClick({
		Param($o,$e)
		
		$Item = $o.FocusedItem
		if ($Item.Tag.Type -ieq "dir") {
			$script:listViewFiles.Items.Clear()
			PopulateListViewExplorerFiles $Item.Tag
		} elseif ($Item.Tag.Type -ieq "file") {
			$Tag = $Item.Tag
			Send-VLCRemote-Playfile  $script:CommonVLCRemoteController $Tag.Uri
			Load-Playlist
		}
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$script:listViewFiles.add_MouseDown({
		$MouseX = $_.X
		$MouseY = $_.Y
		
		$script:listViewFiles.ContextMenu = $null
		$menuItem_Play.Enabled = $true
		
		if ($_.Button -eq [Windows.Forms.MouseButtons]::Right){
		
			[System.Windows.Forms.ListViewHitTestInfo] $HitTestInfo = $script:listViewFiles.HitTest($MouseX, $MouseY)

			if ($HitTestInfo.Item) {
				$script:listViewFiles.ContextMenu = $contextMenuLV
			}
		} 
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$picBoxTraydown.Add_MouseClick({
		$script:formMainFileExplorer.Visible = $false
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItemTV_PlayAndAddToPlaylist.add_click({
		$Tag = $script:TreeViewFolder.SelectedNode.Tag
		$IsPlayed = Add-TagToPlaylist -Tag $Tag	-PlayFirstItem:$True
		
		Load-Playlist
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItemTV_AddToPlaylist.add_click({
		$Tag = $script:TreeViewFolder.SelectedNode.Tag
		$IsPlayed = Add-TagToPlaylist -Tag $Tag -PlayFirstItem:$False
		
		Load-Playlist
	})
	# ---------------------------------------------------------------------------------------------------------------------
	$menuItemTV_Refresh.add_click({
		if ($script:TreeViewFolder.SelectedNode -ne $null) {
			TV-Add-Folder  $script:TreeViewFolder.SelectedNode -Forced:$true
			$Tag = $script:TreeViewFolder.SelectedNode.Tag 
			$script:listViewFiles.Items.Clear()
			PopulateListViewExplorerFiles $Tag
		}
	})
	# ---------------------------------------------------------------------------------------------------------------------
	
	$script:formMainFileExplorer.Show() | out-null	
}
