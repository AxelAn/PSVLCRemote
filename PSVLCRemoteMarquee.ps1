#################################################################################################
# Name			: 	PSVLCRemoteMarquee.ps1
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

# Note : Is defined in PSVLCRemote.ps1 first time
$Script:MarqueeAvailable = $True

$script:MarqueeController = $null
$Script:FontMarquee = New-Object System.Drawing.Font("Segoe UI",9, [System.Drawing.FontStyle]::Bold)

	$script:tmrTickMarquee = New-Object System.Windows.Threading.DispatcherTimer 
	$script:tmrTickMarquee.Stop()
	$script:tmrTickMarquee.IsEnabled = $false
	
#endregion SCRIPT VARIABLES


#
#################################################################################################
#
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
[System.Management.Automation.ScriptBlock]$SBTimeTickMarquee = {

	#$script:tmrTickMarquee.Stop()
	# ---------------------------------------------------------------------
	$MarqueeImageObject 	  = Get-MarqueeImage $script:MarqueeController
	$script:picBoxTitle.image	  = $MarqueeImageObject.Image
	$script:MarqueeController = $MarqueeImageObject.MC
	$script:MarqueeController.DrawPosX -= $script:MarqueeController.Step
	$script:tmrTickMarquee.Interval = [System.TimeSpan]::FromMilliseconds($script:MarqueeController.Frequency)
	# ---------------------------------------------------------------------	
	#$script:tmrTickMarquee.Start()
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	
Function Get-MarqueeTextSize {
[CmdletBinding()]
Param	(
			[System.Drawing.Font]$Font,
			[string]$Text
		)
		
		$bitmap   = New-Object System.Drawing.Bitmap(1,1)
		$Graphics = [System.Drawing.Graphics]::FromImage($bitmap)
		$Graphics.TextRenderingHint = 'AntiAliasGridFit'
		$Graphics.SmoothingMode = 'AntiAlias'
		$Graphics.PixelOffsetMode = 'HighQuality'
		$Graphics.InterpolationMode = 'HighQualityBicubic'
		
		$TextSize = ($Graphics.MeasureString($Text,$Font))
		
		$bitmap.Dispose()
		$Graphics.Dispose()
		
		Write-Output $TextSize
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function New-MarqueeController {
[CmdletBinding()]
Param	(
			$picBox
		)

		$TextHeight =  (Get-MarqueeTextSize -Font $script:FontMarquee -Text "Axel").Height
		$DrawPosY = ($picBox.Size.Height - $TextHeight)/2
		
		$MarqueeController = New-Object -TypeName PSObject -Property @{
																		DisplayMode		= "STATIC";
																		Width			= $picBox.Size.Width;
																		Height			= $picBox.Size.Height;
																		Frequency		= 80;
																		Step			= 1;
																		OriginalText  	= "";
																		Text			= "";
																		TextWidth		= 0;
																		DrawPosX		= 0;
																		DrawPosY		= $DrawPosY;
																		BackColor		= $picBox.BackColor
																		FontMarquee		= $script:FontMarquee
																		Bitmap			= $null
																		Graphics		= $Null
																		Brush			= $Null
																		FirstFrequency  = 2500
																	}
																	
		$MarqueeController.bitmap   = New-Object System.Drawing.Bitmap($MarqueeController.Width,$MarqueeController.Height)
		$MarqueeController.Graphics = [System.Drawing.Graphics]::FromImage($MarqueeController.bitmap)
		$MarqueeController.Graphics.TextRenderingHint = 'AntiAliasGridFit'		# This one is important
		$MarqueeController.Graphics.SmoothingMode = 'AntiAlias'					# The smoothing mode specifies whether lines, curves, and the edges of filled areas use smoothing (also called antialiasing). One exception is that path gradient brushes do not obey the smoothing mode. Areas filled using a PathGradientBrush are rendered the same way (aliased) regardless of the SmoothingMode property.
		$MarqueeController.Graphics.PixelOffsetMode = 'HighQuality'				# Use this property to specify either higher quality, slower rendering, or lower quality, faster rendering of the contents of this Graphics object.
		$MarqueeController.Graphics.InterpolationMode = 'HighQualityBicubic'	# The interpolation mode determines how intermediate values between two endpoints are calculated.
		
		$MarqueeController.brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Blue)
		Write-Output $MarqueeController
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Get-MarqueeImage {
[CmdletBinding()]
Param	(
			[PsObject]$MC
		)
		$SecondDraw = $False
		#$bitmap   = New-Object System.Drawing.Bitmap($MC.Width,$MC.Height)
		#$bitmap.MakeTransparent()		
		#$Graphics = [System.Drawing.Graphics]::FromImage($bitmap)
		$MC.Graphics.Clear('CornSilk')
		
		#$StringFormat = New-Object System.Drawing.StringFormat
		#$StringFormat.Alignment = 'Near'
		#$StringFormat.LineAlignment = 'Near'
		
		# Ensure the best possible quality rendering
		#$Graphics.TextRenderingHint = 'AntiAliasGridFit'		# This one is important
		#$Graphics.SmoothingMode = 'AntiAlias'					# The smoothing mode specifies whether lines, curves, and the edges of filled areas use smoothing (also called antialiasing). One exception is that path gradient brushes do not obey the smoothing mode. Areas filled using a PathGradientBrush are rendered the same way (aliased) regardless of the SmoothingMode property.
		#$Graphics.PixelOffsetMode = 'HighQuality'				# Use this property to specify either higher quality, slower rendering, or lower quality, faster rendering of the contents of this Graphics object.
		#$Graphics.InterpolationMode = 'HighQualityBicubic'		# The interpolation mode determines how intermediate values between two endpoints are calculated.
		
		#$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Blue)
		
		#$TextWidth = ($Graphics.MeasureString($MC.Text, $MC.FontMarquee)).Width
		
		if ($MC.DisplayMode	-eq "STATIC") {
			$MC.DrawPosX = ($MC.Width - $MC.TextWidth)/2
		} else {
			#$Over = $MC.TextWidth - $MC.Width
			if ([System.Math]::abs($MC.DrawPosX) -gt ($MC.TextWidth - $MC.Width)) {
				$SecondDraw = $True
			}
		}
		#("Width			 = {0}" -f $MC.Width) | out-host
		#("TextWidth		 = {0}" -f $MC.TextWidth) | out-host
		#("DrawPosX		 = {0}" -f $MC.DrawPosX) | out-host
		$drawpoint = New-Object -TypeName System.Drawing.PointF -Args ($MC.DrawPosX, $MC.DrawPosY)
		<#
		# Variante 1
		#
		if ([System.Math]::abs($MC.DrawPosX) -ge $TextWidth) {
			$MC.DrawPosX = $MC.Width
		}
		#>
		# ---------------------------------------------------------------------------------------
		$MC.Graphics.DrawString($MC.Text, $MC.FontMarquee, $MC.brush, $drawpoint)
		$MC.Graphics.Flush()
		#----------------------------------------------------------------------------------------
		<#
		# Variante 2
		#
		#>		
		if ($SecondDraw) {
			$DrawPosX2 = $MC.TextWidth - [System.Math]::abs($MC.DrawPosX)
			$drawpoint = New-Object -TypeName System.Drawing.PointF -Args ($DrawPosX2, $MC.DrawPosY)
			$MC.Graphics.DrawString($MC.Text, $MC.FontMarquee, $MC.brush, $drawpoint)
			$MC.Graphics.Flush()
			#("DrawPosX2		 = {0}" -f $DrawPosX2)   | out-host

			if ($DrawPosX2 -le 0) {$MC.DrawPosX = 0}
		}
		#("-----------------------------`n")   | out-host	
		$OutObject = New-Object -TypeName PSObject -Property @{MC = $MC;Image=($MC.bitmap.Clone());}
		Write-Output $OutObject
		#Write-Output $MC.bitmap.Clone()
	
	    #$bitmap.Dispose()
		#$Graphics.Dispose()
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Set-MarqueeText {
[CmdletBinding()]
Param	(
			[PsObject]$MC,
			[System.Windows.Forms.PictureBox]$picBox,
			[string]$Text
		)

	if ($Text -ne $MC.OriginalText) {
		$script:tmrTickMarquee.Stop()	
	
		$TextWidth =  [System.Math]::Round((Get-MarqueeTextSize -Font $MC.FontMarquee -Text $Text).Width)
		$MC.Text = $Text
		$MC.OriginalText = $Text
		$MC.TextWidth = $TextWidth
		$MC.DrawPosX = 0
		
		$script:tmrTickMarquee.Remove_Tick($SBTimeTickMarquee)
			
		if ($TextWidth -le $MC.Width) {
			$MC.DisplayMode		= "STATIC"

			$MarqueeImageObject = Get-MarqueeImage $MC 
			$picBox.image = $MarqueeImageObject.Image
			$MC = $MarqueeImageObject.MC
		
		} else {
			$MC.DisplayMode		= "SCROLL"
			$MC.Text += " "
			$MC.TextWidth = [System.Math]::Round((Get-MarqueeTextSize -Font $MC.FontMarquee -Text $MC.Text).Width)
			
			$MarqueeImageObject = Get-MarqueeImage $MC 
			$picBox.image = $MarqueeImageObject.Image
			$MC = $MarqueeImageObject.MC
			
			$script:tmrTickMarquee.Add_Tick($SBTimeTickMarquee)			
			$script:tmrTickMarquee.Interval = [System.TimeSpan]::FromMilliseconds($MC.FirstFrequency)	
			$script:tmrTickMarquee.Start()	
			<##>
		}
		
		
	}
	Write-Output $MC
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
####### MAIN     ################################################


####### END MAIN ################################################
