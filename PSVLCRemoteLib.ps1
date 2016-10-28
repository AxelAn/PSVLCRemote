#################################################################################################
# Name			: 	PSVLCRemoteLib.ps1
# Description	: 	
# Author		: 	Axel Pokrandt
# License		:	
# Date			: 	13.11.2015 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Set-StrictMode -Version Latest	
# Change: 
#			0.1.0		12.11.2015	Create...
#
#################################################################################################
#
# Globals
#
Add-Type -AssemblyName System.Net.Http
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
[System.String[]] $audiofileExt = @( "2sf", "2sflib", "3ga", "4mp", "5xb", "5xs", "669", "6cm", "8cm", "8med", "8svx", "a2b", "a2i", "a2m", "a2p", "a2t", "a2w", "a52", "aa", "aa3", "aac", "aax", "ab", "abc", "abm", "ac3", "acd", "ac", "ac", "acm", "acp", "act", "adg", "adt", "adts", "adv", "afc", "agm", "agr", "ahx", "aif", "aifc", "aiff", "aimppl", "ais", "akp", "al", "alac", "alaw", "alc", "all", "als", "amf", "amr", "ams", "ams", "amxd", "amz", "aob", "ape", "apf", "apl", "aria", "ariax", "asd", "ase", "at3", "atrac", "au", "au", "aud", "aup", "avastsounds", "avr", "awb", "ay", "b4s", "band", "bap", "bcs", "bdd", "bidule", "bnk", "bonk", "box", "brstm", "bun", "bwf", "bwg", "bww", "c01", "caf", "caff", "cda", "cdda", "cdlx", "cdo", "cdr", "cel", "cfa", "cfxr", "cgrp", "cidb", "ckb", "ckf", "cmf", "conform", "copy", "cpr", "cpt", "csh", "cts", "cwb", "cwp", "cwt", "d00", "d01", "dcf", "dcm", "dct", "ddt", "dewf", "df2", "dfc", "dff", "dig", "dig", "djr", "dls", "dm", "dmc", "dmf", "dmsa", "dmse", "dra", "drg", "ds", "ds2", "dsf", "dsm", "dsp", "dss", "dtm", "dts", "dtshd", "dvf", "dw", "dwa", "dwd", "ear", "efa", "efe", "efk", "efq", "efs", "efv", "emd", "emp", "emx", "emy", "eop", "esps", "evr", "expressionmap", "f2r", "f32", "f3r", "f4a", "f64", "far", "fda", "fdp", "fev", "fff", "flac", "flp", "fls", "fpa", "frg", "fsb", "fsm", "ftm", "ftm", "ftmx", "fzb", "fzf", "fzv", "g721", "g723", "g726", "gbproj", "gbs", "gig", "gio", "gio", "gm", "gp5", "gpbank", "gpk", "gpx", "gro", "groove", "gsm", "gsm", "h0", "h5b", "h5e", "h5s", "hbs", "hdp", "hma", "hmi", "hsb", "iaa", "ics", "iff", "igp", "igr", "imf", "imp", "ins", "ins", "ins", "isma", "it", "iti", "itls", "its", "jam", "jam", "jo", "j", "k25", "k26", "kar", "kfn", "kin", "kit", "kmp", "koz", "koz", "kpl", "krz", "ksc", "ksd", "ksf", "ksm", "kt2", "kt3", "ktp", "l", "la", "lof", "logic", "lqt", "lso", "lvp", "lwv", "m1a", "m3u", "m3u8", "m4a", "m4b", "m4p", "m4r", "ma1", "mbr", "mdc", "mdl", "med", "mgv", "mid", "midi", "mini2sf", "minincsf", "minipsf", "minipsf2", "miniusf", "mka", "mlp", "mmf", "mmm", "mmp", "mmp", "mmpz", "mo3", "mod", "mogg", "mp1", "mp2", "mp3", "mp_", "mpa", "mpc", "mpdp", "mpga", "mpu", "mscx", "mscz", "msv", "mt2", "mt9", "mte", "mtf", "mti", "mtm", "mtp", "mts", "mu3", "mui", "mus", "mus", "mus", "musa", "musx", "mux", "mux", "muz", "mwand", "mws", "mx3", "mx4", "mx5", "mx5template", "mxl", "mxmf", "myr", "mzp", "nap", "narrative", "nbs", "ncw", "nkb", "nkc", "nki", "nkm", "nks", "nkx", "nml", "nmsv", "note", "npl", "nra", "nrt", "nsa", "nsf", "nst", "ntn", "nvf", "nwc", "obw", "odm", "ofr", "oga", "ogg", "okt", "oma", "omf", "omg", "omx", "opus", "orc", "ots", "ove", "ovw", "ovw", "pac", "pandora", "pat", "pbf", "pca", "pcast", "pcg", "pcm", "pd", "peak", "pek", "pho", "phy", "pjunoxl", "pk", "pkf", "pla", "pls", "plst", "ply", "pna", "pno", "ppc", "ppcx", "prg", "prg", "psf", "psf1", "psf2", "psm", "psy", "ptcop", "ptf", "ptm", "pts", "ptx", "pvc", "q1", "q2", "qcp", "r", "r1m", "ra", "rad", "ram", "raw", "rax", "rbs", "rbs", "rcy", "record", "rex", "rfl", "rgrp", "rip", "rmf", "rmi", "rmj", "rmm", "rmx", "rng", "rns", "rol", "rsf", "rsn", "rso", "rta", "rti", "rtm", "rts", "rvx", "rx2", "s3i", "s3m", "s3z", "saf", "sam", "sap", "sb", "sbg", "sbi", "sbk", "sc2", "scs11", "sd", "sd", "sd2", "sd2f", "sdat", "sdii", "sds", "sdt", "sdx", "seg", "seq", "ses", "sesx", "sf", "sf2", "sfap0", "sfk", "sfl", "sfpack", "sfs", "sgp", "shn", "sib", "sid", "slp", "slx", "sma", "smf", "smp", "smp", "smpx", "snd", "snd", "snd", "sng", "sng", "sns", "snsf", "sou", "sph", "sppack", "sprg", "spx", "sseq", "sseq", "ssnd", "stap", "sth", "sti", "stm", "stw", "stx", "sty", "sty", "svd", "svx", "sw", "swa", "swav", "sxt", "syh", "syn", "syn", "syw", "syx", "tak", "tak", "td0", "tfmx", "tg", "thx", "tm2", "tm8", "tmc", "toc", "trak", "tsp", "tta", "tun", "txw", "u", "u8", "uax", "ub", "ulaw", "ult", "ulw", "uni", "usf", "usflib", "ust", "uw", "uwf", "v2m", "vag", "val", "vap", "vb", "vc3", "vdj", "vgm", "vgz", "vlc", "vmd", "vmf", "vmf", "vmo", "voc", "voi", "vox", "voxal", "vpl", "vpm", "vpw", "vqf", "vrf", "vsq", "vtx", "vyf", "w01", "w64", "wand", "wav", "wav", "wave", "wax", "wem", "wfb", "wfd", "wfm", "wfp", "wma", "wow", "wpk", "wpp", "wproj", "wrk", "wtpl", "wtpt", "wus", "wut", "wv", "wvc", "wve", "wwu", "wyz", "xa", "xa", "xfs", "xi", "xm", "xmf", "xmi", "xmz", "xp", "xpf", "xrns", "xsb", "xsp", "xspf", "xt", "xwb", "ym", "yookoo", "zab", "zpa", "zpl", "zvd", "zvr" )
[System.String[]] $videofileExt = @( "264", "3g2", "3gp", "3gp2", "3gpp", "3gpp2", "3mm", "3p2", "60d", "787", "890", "aaf", "aec", "aep", "aepx", "aet", "aetx", "ajp", "ale", "am", "amc", "amv", "amx", "anim", "aqt", "arcut", "arf", "asf", "asx", "avb", "avc", "avchd", "avd", "avi", "avp", "avs", "avs", "avv", "awlive", "axm", "bdm", "bdmv", "bdt2", "bdt3", "bik", "bin", "bix", "bmc", "bmk", "bnp", "box", "bs4", "bsf", "bu", "bvr", "byu", "camproj", "camrec", "camv", "ced", "cel", "cine", "cip", "clk", "clpi", "cmmp", "cmmtpl", "cmproj", "cmrec", "cpi", "cst", "cvc", "cx3", "d2v", "d3v", "dash", "dat", "dav", "db2", "dce", "dck", "dcr", "dcr", "ddat", "dif", "dir", "divx", "dlx", "dmb", "dmsd", "dmsd3d", "dmsm", "dmsm3d", "dmss", "dmx", "dnc", "dpa", "dpg", "dream", "dsy", "dv", "d", "dv4", "dvdmedia", "dvr", "dv", "dvx", "dxr", "dzm", "dzp", "dzt", "edl", "evo", "eye", "ezt", "f4f", "f4p", "f4v", "fbr", "fbr", "fbz", "fcp", "fcproject", "ffd", "flc", "flh", "fli", "flv", "flx", "ftc", "gcs", "gfp", "gl", "gom", "grasp", "gts", "gvi", "gvp", "h264", "hdmov", "hdv", "hkm", "ifo", "imovieproj", "imovieproject", "inp", "int", "ircp", "irf", "ism", "ismc", "ismclip", "ismv", "iva", "ivf", "ivr", "ivs", "izz", "izzy", "jmv", "jss", "jts", "jtv", "k3g", "kdenlive", "kmv", "ktn", "lrec", "lrv", "lsf", "lsx", "lvix", "m15", "m1pg", "m1v", "m21", "m21", "m2a", "m2p", "m2t", "m2ts", "m2v", "m4e", "m4u", "m4v", "m75", "mani", "meta", "mgv", "mj2", "mjp", "mjpg", "mk3d", "mkv", "mmv", "mnv", "mob", "mod", "modd", "moff", "moi", "moov", "mov", "movie", "mp21", "mp21", "mp2v", "mp4", "mp", "mp4v", "mpe", "mpeg", "mpeg1", "mpeg4", "mpf", "mpg", "mpg2", "mpgindex", "mpl", "mpl", "mpls", "mpsub", "mpv", "mpv2", "mqv", "msdvd", "mse", "msh", "mswmm", "mts", "mtv", "mvb", "mvc", "mvd", "mve", "mvex", "mvp", "mvp", "mvy", "mxf", "mxv", "mys", "ncor", "nsv", "nut", "nuv", "nvc", "ogm", "ogv", "ogx", "orv", "osp", "otrkey", "pac", "par", "pds", "pgi", "photoshow", "piv", "pjs", "playlist", "plproj", "pmf", "pmv", "pns", "ppj", "prel", "pro", "pro4dvd", "pro5dvd", "proqc", "prproj", "prtl", "psb", "psh", "pssd", "pva", "pvr", "pxv", "qt", "qtch", "qtindex", "qtl", "qtm", "qtz", "r3d", "rcd", "rcproject", "rdb", "rec", "rm", "rmd", "rmd", "rmp", "rms", "rmv", "rmvb", "roq", "rp", "rsx", "rts", "rts", "rum", "rv", "rvid", "rvl", "sbk", "sbt", "scc", "scm", "scm", "scn", "screenflow", "sdv", "sec", "sedprj", "seq", "sfd", "sfvidcap", "siv", "smi", "smi", "smil", "smk", "sml", "smv", "snagproj", "spl", "sqz", "ssf", "ssm", "stl", "str", "stx", "svi", "swf", "swi", "swt", "tda3mt", "tdt", "tdx", "thp", "tid", "tivo", "tix", "tod", "tp", "tp0", "tpd", "tpr", "trp", "ts", "tsp", "ttxt", "tvs", "usf", "usm", "vbc", "vc1", "vcpf", "vcr", "vcv", "vdo", "vdr", "vdx", "veg", "vem", "vep", "vf", "vft", "vfw", "vfz", "vgz", "vid", "video", "viewlet", "viv", "vivo", "vix", "vlab", "vob", "vp3", "vp6", "vp7", "vpj", "vro", "vs4", "vse", "vsp", "w32", "wcp", "webm", "wlmp", "wm", "wmd", "wmmp", "wmv", "wmx", "wot", "wp3", "wpl", "wtv", "wve", "wvx", "xej", "xel", "xesc", "xfl", "xlmv", "xmv", "xvid", "y4m", "yog", "yuv", "zeg", "zm1", "zm2", "zm3", "zmv" )
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Test-ValidFilename {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][string]$Pathname
		)	

	$valid = $false

	if ($Pathname.StartsWith("file:")) {
		$Pathname = ([System.Uri]::UnescapeDataString($Pathname) -replace "file:///","") -replace "//","/"
	}
	$Filename = Split-Path $Pathname -leaf
	
	if ($Filename.IndexOf(".") -gt -1) {
		$ext = $Filename.SubString($Filename.LastIndexOf(".")+1)
		
		if (($audiofileExt -icontains $ext) -or ($videofileExt -icontains $ext)) {
			$valid = $true
		}
	}
	

	Write-Output $valid
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-VLCRemoteController {
[CmdletBinding()]
Param	(	[string]$HostnameOrIP,
			[string]$Port,
			[string]$Username,
			[string]$Password,
			[string]$UseAutoIP
		)
	
	$cookieJar = new-object System.Net.CookieContainer
	try {
		([System.Net.Dns]::GetHostAddresses($HostnameOrIP)) | where {$_.AddressFamily -eq "InterNetwork"} | % {$RealIPAdress = $_.IPAddressToString }
	} catch {$RealIPAdress = ""}
	
	if ($RealIPAdress -ne "" -and ($UseAutoIP -eq "1")) {
		$baseURL = "http://" + $RealIPAdress + ":" + $Port + "/"
	} else {
		$baseURL = "http://" + $HostnameOrIP + ":" + $Port + "/"
	}
	
	$retVal = New-Object PSObject -Property @{
		HostnameOrIP	= $HostnameOrIP
		BaseURL 		= $BaseURL
		Username		= $Username
		Password 		= $Password
		CookieJar		= $CookieJar
		RealIPAdress    = $RealIPAdress
		UseAutoIP		= $UseAutoIP
	}
	Write-Output $retVal
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-VLCRemoteCommand {
[CmdletBinding()]
Param	(
			[string]$Site,
			[string]$Command,
			[string]$CommandValue,
			[string]$Parameter,
			[string]$ParameterValue
		)
	$tmpCommand = ""
	
	if ($Command -ne "") {
		$tmpCommand = "?" + $Command
		if ($CommandValue -ne "") {
			$tmpCommand += "=" + [System.Net.WebUtility]::URLEncode($CommandValue)
		}
		if ($Parameter -ne "") {
			$tmpCommand += "&" + $Parameter
			If ($ParameterValue -ne "") {
				$tmpCommand += "=" + [System.Net.WebUtility]::URLEncode($ParameterValue)
			}
		}
	}
	
	$retVal = New-Object PSObject -Property @{
		Site = $Site
		Command = $tmpCommand
	}
	Write-Output $retVal
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Test-Connection {
[CmdletBinding()]
Param	(
			[String]$HostnameOrIP,
			[String]$Port,
			[String]$Password
		)
		
	$IsValidConnection = $false
			
	$cookieJar = new-object System.Net.CookieContainer
	$URL = "http://" + $HostnameOrIP + ":" + $Port + "/requests/status.xml"
	$baseAddress = new-object System.Uri($url)
	
	$ClientHandler = new-object System.Net.Http.HttpClientHandler
	$ClientHandler.CookieContainer = $cookieJar
	
	$Client = new-object  System.Net.Http.HttpClient($ClientHandler)
	$Client.Timeout = New-Object System.Timespan(0,0,30)	# 30 Sekunden

	$authInfo = ":" + $Password
	$authInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($authInfo))

	$client.DefaultRequestHeaders.Authorization = new-object System.Net.Http.Headers.AuthenticationHeaderValue("basic", $authInfo)
	$Client.BaseAddress = $baseAddress
	
	$query = ""
	#$query | out-host
	[System.Threading.Tasks.Task[System.Net.Http.HttpResponseMessage]]$resultAsync = $client.GetAsync($query)
	
	while (!$resultAsync.IsCompleted) {Start-Sleep -MilliSeconds 50}
	
	if (!$resultAsync.IsFaulted) {
		[System.Net.Http.HttpResponseMessage]$HTTPResponse = $resultAsync.Result
		if ($HTTPResponse.IsSuccessStatusCode) {
			$resultStream = [System.Threading.Tasks.Task[string]]$HTTPResponse.Content.ReadAsStringAsync()
			while (!$resultStream.IsCompleted) {Start-Sleep -MilliSeconds 50}
			$dummyRequest = $ResultStream.Result
			$IsValidConnection = $true
		} 
	}
	
	$Client.Dispose()
	$ClientHandler.Dispose()
	
	Write-Output $IsValidConnection
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemoteRequest {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][PSObject]$Command
		)
		
	$DebugLevel = $False
	
	$returnRequest = $null
	
	$url = $VLCRemoteController.BaseURL + $Command.Site
	if ($Debuglevel) {$url | out-host}
	
	$baseAddress = new-object System.Uri($url)
	
	$ClientHandler = new-object System.Net.Http.HttpClientHandler
	$ClientHandler.CookieContainer = $VLCRemoteController.cookieJar
	
	$Client = new-object  System.Net.Http.HttpClient($ClientHandler)
	$Client.Timeout = New-Object System.Timespan(0,1,30)	# 90 Sekunden

	$authInfo = $VLCRemoteController.Username + ":" + $VLCRemoteController.Password
	$authInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($authInfo))

	$client.DefaultRequestHeaders.Authorization = new-object System.Net.Http.Headers.AuthenticationHeaderValue("basic", $authInfo)
	$Client.BaseAddress = $baseAddress
	
	$query = $Command.Command
	if ($Debuglevel) {$query | out-host}
	[System.Threading.Tasks.Task[System.Net.Http.HttpResponseMessage]]$resultAsync = $client.GetAsync($query)
	
	while (!$resultAsync.IsCompleted) {Start-Sleep -MilliSeconds 50}
	
	if (!$resultAsync.IsFaulted) {
		if ($Debuglevel) {"resultAsync ---------------------------------------------------------------------------------------" | Out-Host}
		if ($Debuglevel) {$resultAsync | select-object * | Out-Host}
		#$resultAsync | gm
		#$resultAsync | gm -static

		[System.Net.Http.HttpResponseMessage]$HTTPResponse = $resultAsync.Result
		if ($Debuglevel) {"HTTPResponse ---------------------------------------------------------------------------------------" | Out-Host}
		if ($Debuglevel) {$HTTPResponse | select-object * | Out-Host}
		# HttpResponseMessage : https://msdn.microsoft.com/library/windows/apps/dn279631
		if ($Debuglevel) {"StatusCode ---------------------------------------------------------------------------------------" | Out-Host}
		if ($Debuglevel) {[System.Int32]$HTTPResponse.Statuscode | Out-Host}

		if ($HTTPResponse.IsSuccessStatusCode) {

			# https://de.wikipedia.org/wiki/HTTP-Statuscode

			$resultStream = [System.Threading.Tasks.Task[string]]$HTTPResponse.Content.ReadAsStringAsync()
			if ($Debuglevel) {"resultStream ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" | out-host}
			if ($Debuglevel) {$resultStream | out-host}
			
			while (!$resultStream.IsCompleted) {Start-Sleep -MilliSeconds 50}
			
			if ($Debuglevel) {"resultStream ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" | out-host}
			if ($Debuglevel) {$resultStream | out-host}
			
			$returnRequest = $ResultStream.Result
		} else {
			Write-Host -Fore Red "#########################################################################################"
			$HTTPResponse | select-object * | Out-Host
			Write-Host -Fore Red "#########################################################################################"		
		}
	}
	
	$Client.Dispose()
	$ClientHandler.Dispose()
	
	if ($Debuglevel) {"##############################################################################################" | out-host}
	
	Write-Output $returnRequest
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-GetStatusAsXML {	# PRIVATE
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml" -Command "" -CommandValue "" -Parameter "" -ParameterValue ""

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command -Verbose

	Write-Output $result

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-GetVolumesAsXML {	# PRIVATE
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/browse.xml" -Command "uri" -CommandValue "file:///" -Parameter "" -ParameterValue ""

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

	Write-Output $result

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-GetFilesAsXML {		# PRIVATE
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$Foldername
		)
		
	if (-not($Foldername.StartsWith("file:"))) {
		$Foldername = (new-object System.Uri($Foldername)).ToString()
	}
	$Command = New-VLCRemoteCommand -Site "requests/browse.xml" -Command "uri" -CommandValue $Foldername -Parameter "" -ParameterValue ""

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command -Verbose

	Write-Output $result

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-GetPlaylistAsXML {	# PRIVATE
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/playlist.xml" -Command "uri" -CommandValue "" -Parameter "" -ParameterValue ""

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

	Write-Output $result

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemote-Status {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	# ---------------------------------------------------------
	Function Get-ValueFromNode {
	Param($node,$path)
		$r = ""
		if ($node) {
			$val = $node.SelectSingleNode($path)
			if ($val) {
				$r = $val.InnerXML
			} 
		}
		Write-Output $r
	}
	# ---------------------------------------------------------
	$result = Send-VLCRemote-GetStatusAsXML -VLCRemoteController $VLCRemoteController
	$Status = $null
	
	if ($result -ne $null) {
		$xml = [XML]$result

		$FS = ($xml.SelectSingleNode("/root/fullscreen")).InnerXML
		$FullScreen 	= if ( ($FS -eq "0") -or ($FS -ieq "false")) {$false} else {$true}
		
		$Random		 	= if (($xml.SelectSingleNode("/root/random")).InnerXML -eq "false") {$false} else {$true}
		$Loop		 	= if (($xml.SelectSingleNode("/root/loop")).InnerXML -eq "false") {$false} else {$true}
		$Repeat		 	= if (($xml.SelectSingleNode("/root/repeat")).InnerXML -eq "false") {$false} else {$true}
		$Time			= ($xml.SelectSingleNode("/root/time")).InnerXML
		$Volume 		= ($xml.SelectSingleNode("/root/volume")).InnerXML 
		$Length 		= ($xml.SelectSingleNode("/root/length")).InnerXML
		$Rate 			= ($xml.SelectSingleNode("/root/rate")).InnerXML
		$State 			= ($xml.SelectSingleNode("/root/state")).InnerXML
		$currentplid	= ($xml.SelectSingleNode("/root/currentplid")).InnerXML
		$audiodelay     = ($xml.SelectSingleNode("/root/audiodelay")).InnerXML
		$subtitledelay  = ($xml.SelectSingleNode("/root/subtitledelay")).InnerXML
		try {
			$aspectRatio  	= ($xml.SelectSingleNode("/root/aspectratio")).InnerXML
		} catch {
			$aspectRatio  	= "default"
		}
		$node 			= $xml.SelectSingleNode("/root/information/category[@name='meta']")
		
		$album 			= Get-ValueFromNode $node "info[@name='album']"
		$track_number 	= Get-ValueFromNode $node "info[@name='track_number']"
		$filename 		= Get-ValueFromNode $node "info[@name='filename']"
		$artist 		= Get-ValueFromNode $node "info[@name='artist']"
		$title 			= Get-ValueFromNode $node "info[@name='title']"
		$now_playing    = Get-ValueFromNode $node "info[@name='now_playing']"
		
		$node 			= $xml.SelectSingleNode("/root/information/category[@name='Stream 0']")

		$Typ 			= Get-ValueFromNode $node "info[@name='Typ']"
		$Codec 			= Get-ValueFromNode $node "info[@name='Codec']"

		# Special Check DVD
		if ($filename.StartsWith("dvd:")) {
			$Typ = "DVD"
		}
		
		$AudioStreams = @()
		$SubtitleStreams = @()
		if (($Typ -ieq "Video") -or ($Typ -ieq "DVD")) {
			#
			# 1. Looking for Audio-Streams
			$Nodes = $XML.SelectNodes("/root/information/category") | Sort-Object 
			ForEach ($N in $Nodes) {

				$StreamTyp 	= Get-ValueFromNode $N "info[@name='Typ']"
				if ($StreamTyp -ieq "Audio") {
					$StreamName = $N.GetAttribute("name")
					$StreamNumber = [int](($StreamName -replace "Stream","") -replace " ","") 
					$StreamCodec = Get-ValueFromNode $N "info[@name='Codec']"
					$StreamLang  = Get-ValueFromNode $N "info[@name='Sprache']"
					
					$AudioStream = New-Object PsObject -Property @{
						StreamText      = ($StreamCodec + " - (" + $StreamLang + ")")
						StreamNumber	= $StreamNumber
						StreamName		= $StreamName
						StreamCodec		= $StreamCodec
						StreamLang		= $StreamLang
					}

					$AudioStreams += $AudioStream
				}
			}
			# 2. Looking for SubTitle(s)
			ForEach ($N in $Nodes) {

				$StreamTyp 	= Get-ValueFromNode $N "info[@name='Typ']"
				if ($StreamTyp -ieq "Untertitel") {
					$StreamName = $N.GetAttribute("name")
					$StreamNumber = [int](($StreamName -replace "Stream","") -replace " ","") 
					$StreamDesc = Get-ValueFromNode $N "info[@name='Beschreibung']"
					if ($StreamDesc -eq "") {$StreamDesc = "Title $($StreamNumber)"}
					$StreamLang  = Get-ValueFromNode $N "info[@name='Sprache']"
					
					$SubtitleStream = New-Object PsObject -Property @{
						StreamText      = ($StreamDesc + " - (" + $StreamLang + ")")
						StreamNumber	= $StreamNumber
						StreamName		= $StreamName
						StreamDesc		= $StreamDesc
						StreamLang		= $StreamLang
					}

					$SubtitleStreams += $SubtitleStream
				}
			}
		}
		$SubtitleStreams = $SubtitleStreams | Sort-Object StreamNumber
		$Status = New-Object PSObject -Property @{
			Fullscreen 	= $FullScreen
			Time 		= $Time
			Volume 		= $Volume
			Length 		= $Length
			Rate		= $Rate
			Random		= $Random
			Loop		= $Loop
			Repeat		= $Repeat
			State		= $State
			Currentplid = $currentplid
			NowPlaying  = $now_playing
			Album			= $album
			Track_number   	= $track_number
			Filename       	= $filename
			Artist         	= $artist
			Title          	= $title
			Codec			= $Codec
			Typ				= $Typ
			AudioStreams	= @($AudioStreams)
			AudioDelay		= $audiodelay
			SubtitleStreams = @($SubtitleStreams)
			SubtitleDelay	= $subtitledelay
			AspectRatio 	= $aspectRatio
			RawResult		= $result
		}
	}
	Write-Output $Status

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemote-Volumes {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$result = Send-VLCRemote-GetVolumesAsXML -VLCRemoteController $VLCRemoteController
	$Volumes = $null
	
	if ($result -ne $null) {
		$xml = [XML]$result
		
		$Nodes = $xml.SelectNodes("/root/element")
		$Volumes = @()
		
		$Nodes | Foreach-Object {
			$Type  = $_.GetAttribute("type")
			$Path = $_.GetAttribute("path")
			$Uri = $_.GetAttribute("uri")
			$Name = $_.GetAttribute("name")
			$Size = $_.GetAttribute("size")
			$access_time = $_.GetAttribute("access_time")
			
			$Vol = New-Object PSObject -Property @{
				Type = $Type
				Path = $Path
				Uri	 = $Uri
				Name = $Name
				Size = $Size
				access_time = $access_time
			}
			$Volumes += $Vol
		}
	}
	Write-Output $Volumes
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemote-Playlist {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$result = Send-VLCRemote-GetPlaylistAsXML -VLCRemoteController $VLCRemoteController
	$Files = $null
	
	if ($result -ne $null) {
		$xml = [XML]$result
		
		$NodeBase = $xml.SelectSingleNode("/node/node[@ name='Wiedergabeliste']")
		$Nodes = $NodeBase.SelectNodes("leaf")
		
		$Files = @()
		
		$Nodes | Foreach-Object {
			$Name = $_.GetAttribute("name")
			[int]$Id = $_.GetAttribute("id")
			$Duration = $_.GetAttribute("duration")
			$Uri = $_.GetAttribute("uri")
			$Current = $_.GetAttribute("current")
			
			$File = New-Object PSObject -Property @{
				Name = $Name
				Id = $Id
				Duration = $Duration
				Uri = $Uri
				Current = $Current
			}
			$Files += $File
		}	
	}
	Write-Output $Files
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemote-Files {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$Foldername
			
		)
	$result = Send-VLCRemote-GetFilesAsXML -VLCRemoteController $VLCRemoteController -Foldername $Foldername
	$Files = $null
	if ($result -ne $null) {
		#$result | out-host
		$xml = [XML]$result

		$Nodes = $xml.SelectNodes("/root/element")
		$Files = @()
		
		$Nodes | where-object {(($_.type -ieq "dir") -and (-not($_.name -ieq '$RECYCLE.BIN')) -and (-not($_.name -ieq 'System Volume Information'))-and (-not($_.name -ieq '..')))} | Foreach-Object {
			$Type  = $_.GetAttribute("type")
			$Path = $_.GetAttribute("path")
			$Uri = $_.GetAttribute("uri")
			$Name = $_.GetAttribute("name")
			$Size = $_.GetAttribute("size")
			$access_time = $_.GetAttribute("access_time")
			
			$File = New-Object PSObject -Property @{
				Type = $Type
				Path = $Path
				Uri	 = $Uri
				Name = $Name
				Size = $Size
				access_time = $access_time
			}
			$Files += $File
		}
		$Nodes | where-object {$_.type -ieq "file"} | Foreach-Object {
			$Type  = $_.GetAttribute("type")
			$Path = $_.GetAttribute("path")
			$Uri = $_.GetAttribute("uri")
			$Name = $_.GetAttribute("name")
			$Size = $_.GetAttribute("size")
			$access_time = $_.GetAttribute("access_time")
			
			$File = New-Object PSObject -Property @{
				Type = $Type
				Path = $Path
				Uri	 = $Uri
				Name = $Name
				Size = $Size
				access_time = $access_time
			}
			$Files += $File
		}
	}
	Write-Output $Files
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-VLCRemote-FilesRecursive {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$Foldername
			
		)

	$FilesComplete = @()
	
	$FolderFiles = Get-VLCRemote-Files $VLCRemoteController $Foldername
	
	Foreach ($F in $FolderFiles) {
		
		if ($F.Type -ieq "dir") {
			$localFiles = Get-VLCRemote-FilesRecursive $VLCRemoteController $F.Uri
			Foreach ($SubF in $localFiles) {
			
				if (Test-ValidFilename $SubF.Uri) {
					$FilesComplete += $SubF
				}
			}
		} else {
			
			if (Test-ValidFilename $F.Uri) {
				$FilesComplete += $F
			}
		}
	
	}
	Write-Output $FilesComplete
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Playfile {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$Filename
		)
		
	if (-not($Filename.StartsWith("file:"))) {
		$Filename = (new-object System.Uri($Filename)).ToString()
	}
	$Command = New-VLCRemoteCommand -Site "requests/status.xml" -Command "command" -CommandValue "in_play" -Parameter "input" -ParameterValue $Filename

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Play {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_play" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-PlayItemFromPlaylist {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$PlaylistID
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_play" -Parameter "id" -ParameterValue $PlaylistID
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Pause {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_forcepause" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Resume {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
		
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_forceresume" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Stop {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_stop" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-NextTrack {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_next" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-PreviousTrack {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_previous" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-ToggleFullScreen {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "fullscreen" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-ToggleRandom {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_random" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-ToggleLoop {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_loop" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-ToggleRepeat {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_repeat" -Parameter "" -ParameterValue "" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetVolumeLevel {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[int]$Level
		)
	#
	# 100% -> 256
	# 125% -> 320
	#
	if ($level -lt 0) {$level = 0} elseif ($Level -gt 320) {$Level = 320}
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "volume" -Parameter "val" -ParameterValue "$Level" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateValue {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$Rate
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "rate" -Parameter "val" -ParameterValue "$Rate" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetKey {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$KeyValue
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "key" -Parameter "val" -ParameterValue $KeyValue
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateFaster {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "faster"
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateFasterFine {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "rate-faster-fine"
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateSlower {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "slower"
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateSlowerFine {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$Rate
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "rate-slower-fine"
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetRateNormal {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "rate-normal"
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetAudioTrackValue {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$TrackValue
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "audio_track" -Parameter "val" -ParameterValue "$TrackValue" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetAudioDelayValue {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$DelayValue
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "audiodelay" -Parameter "val" -ParameterValue "$DelayValue" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetSubtitleValue {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$SubtitleValue
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "subtitle_track" -Parameter "val" -ParameterValue "$SubtitleValue" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-SetAspectRatio {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$AspectRatio
		)
	
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "aspectratio" -Parameter "val" -ParameterValue "$AspectRatio" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-Seek {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[int]$ToSecond
		)
	#
	# Müsste jetzt hier abgeglichen werden mit dem Status <length> (in Seconds)
	# aber der VLC setzt Werte kleiner 0 oder größer als die Länge automatisch auf den Anfang, sprich 0
	#
	if ($ToSecond -lt 0) {$ToSecond = 0}
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "seek" -Parameter "val" -ParameterValue "$ToSecond" 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-ClearPlaylist {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_empty" -Parameter "" -ParameterValue ""
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-RemoveFromPlaylist {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[string]$PlaylistID
		)
	$Command = New-VLCRemoteCommand -Site "requests/status.xml"  -Command "command" -CommandValue "pl_delete" -Parameter "id" -ParameterValue $PlaylistID 
	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-AddFileToPlaylist {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[Parameter(Mandatory=$true)][string]$Filename
		)
		
	if (-not($Filename.StartsWith("file:"))) {
		$Filename = (new-object System.Uri($Filename)).ToString()
	}
	$Command = New-VLCRemoteCommand -Site "requests/status.xml" -Command "command" -CommandValue "in_enqueue" -Parameter "input" -ParameterValue $Filename

	$result = Send-VLCRemoteRequest -VLCRemoteController $VLCRemoteController -Command $Command 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Send-VLCRemote-QuitVLC {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController
		)
	Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "quit"
}
# ---------------------------------------------------------------------------------------------------------------------------------
Function Send-VLVDVDCommand {
[CmdletBinding()]
Param	(
			[Parameter(Mandatory=$true)][PSObject]$VLCRemoteController,
			[String]$Command
		)
		
	switch ($Command) {
	
		("UP")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "nav-up"
					break
				}
		("DOWN")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "nav-down"
					break
				}
		("LEFT")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "nav-left"
					break
				}
		("RIGHT")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "nav-right"
					break
				}
		("CHAPTER_PREV")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "chapter-prev"
					break
				}
		("CHAPTER_NEXT")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "chapter-next"
					break
				}
		("TITLE_PREV")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "title-prev"
					break
				}
		("TITLE_NEXT")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "title-next"
					break
				}
		("OK")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "nav-activate"
					break
				}
		("MENU")	{
					Send-VLCRemote-SetKey -VLCRemoteController $VLCRemoteController -KeyValue "disc-menu"
					break
				}
				
	}
}
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Test-Lib {
[CmdletBinding()]
Param	()
	$VLCRemoteController = New-VLCRemoteController -HostnameOrIP "HTPCHOME" -Port "8080" -Username "" -Password "1234" -UseAutoIP "1"

	
	$Status = Get-VLCRemote-Status -VLCRemoteController $VLCRemoteController
	$Status | fl *
	

}
#Test-Lib