<#
.SYNOPSIS

    The 'DALL-E OpenAI Image Generator for Sitecore' is a Sitecore PowerShell Extensions module that allows CMS users to 
    generate images using DALL-E API, and store them in the Media Library.

.DESCRIPTION

    'DALL-E OpenAI Image Generator for Sitecore' is a Sitecore PowerShell Extensions utility that 
    enables Designers, Developers, and Marketers to generate images using the DALL-E Open Artificial Intelligence
    directly in Sitecore's Media Library.

    An OpenAI API key is required:
    - https://beta.openai.com/account/api-keys

    This key is configured in the 'OpenAI API Key' field on the 'OpenAI API Setting' item installed alongside this module in Sitecore:
    - '/sitecore/system/Modules/PowerShell/Script Library/DALL-E OpenAI Image Generator/OpenAI API Settings'
    - {F102AE0D-6A5B-499B-9500-505D0E6F686F}

    The Sitecore Template for this setting item is located here:
    - '/sitecore/templates/Modules/DALL-E OpenAI Image Generator'

    [ DALL-E Resources ]
    - https://openai.com/dall-e-2
    - https://labs.openai.com/
    - https://beta.openai.com/docs/guides/images/usage
    - https://beta.openai.com/docs/api-reference/images
    - https://openai.com/blog/dall-e-api-now-available-in-public-beta/
    

.NOTES
    This script was developed to work as a `Context Menu` and a `Insert Item` PowerShell Script item.
    
    See the blog post:
    - https://www.sitecoregabe.com/2022/11/dall-e-openai-image-generator-for-sitecore.html

    November 2022
    Version: 1.0

.AUTHOR
    Gabe Streza

#>

function Invoke-ImageGeneration {
    param (
        [Parameter(Mandatory = $true)]
        [Item]$TargetItem,

        [Parameter(Mandatory = $true)]
        [string]$UserInput,

        [Parameter(Mandatory = $true)]
        [string]$SizeSelection,

        [Parameter(Mandatory = $true)]
        [string]$NumberOfImages,

        [Parameter(Mandatory = $true)]
        [string]$MediaItemNames
    )

    # Get the contextual item (Media Folder) where new Media Items will be created
    $targetItem = Get-Item $TargetItem.ID -Language $Language

    # Configure the OpenAI DALL-E API headers
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add("Content-Type", "application/json")
    $Headers.Add("Authorization", "Bearer $script:OPENAI_API_KEY")

    # Configure the OpenAI DALL-E API body
    $Body = '{
        "prompt": "'+ $UserInput+ '",
        "n": ' + [int]$NumberOfImages +',
        "size": "'+ $SizeSelection +'"
      }'

    try{
        # Call the OpenAI DALL-E API endpoint
        $result = Invoke-WebRequest -Method Post -Headers $Headers -UseBasicParsing -Uri $script:OPENAI_API_ENDPOINT -Body $Body  | Select-Object -Expand Content | ConvertFrom-Json

        # Set an image count (used for new Media Item name for multiple variations)
        $imageCount = 1

        # Iterate through each generated image URL
        foreach($url in $result.data.url){
            # Invoke function to download and create a new Media Item in the target Media Folder location
            Invoke-ImageSaveToMediaLibrary -ImageUrl $url -MediaFolderItem $TargetItem -MediaItemNames $MediaItemNames -ImageCount $imageCount
            Write-Host $url

            # Increment the image counter
            $imageCount += 1
        }
        return $result.data.url
    } 
    catch [System.Net.WebException] {
        # An error occurred calling the API
        Write-Host 'Error calling DALL-E OpenAI API' -ForegroundColor Red
        Write-Host $Error[0] -ForegroundColor Red
        return $null
    } 
}


function Invoke-ImageSaveToMediaLibrary{

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ImageUrl,
        
        [Parameter(Mandatory = $true)]
        [Item]
        $MediaFolderItem,

        [Parameter(Mandatory = $true)]
        [string]
        $MediaItemNames,

        [Parameter(Mandatory = $true)]
        [int]
        $ImageCount
    )

      # Configure the temporary location to download the file.
      $tempFolder = "$SitecoreDataFolder\temp"
   
      # Check existence of the path
      Test-Path $tempFolder

     # Create the temporary folder if it doesn't exist.
      if ((Test-Path $tempFolder) -eq 0) {
          New-Item -ItemType Directory -Force -Path $tempFolder
      }

      # Everything from DALL-E comes back as a PNG
      $extension = "png"

      # GUID for temporary file
      $tempId = New-Guid
      
      # Build file path to store the downloaded image
      $mediaPath = $MediaFolderItem.Paths.Path
      $filePath = "$tempFolder\dalle-gen-$tempId.$extension"

      # Download the image
      Invoke-WebRequest -Uri $url -OutFile $filePath

      # Create the Media Item using the downloaded image
      $mediaItemName = "$MediaItemNames-$imageCount"
      $mediaCreatorOptions = New-Object Sitecore.Resources.Media.MediaCreatorOptions
      $mediaCreatorOptions.Database = [Sitecore.Configuration.Factory]::GetDatabase("master");
      $mediaCreatorOptions.Language = [Sitecore.Globalization.Language]::Parse("en");
      $mediaCreatorOptions.Versioned = [Sitecore.Configuration.Settings+Media]::UploadAsVersionableByDefault;
      $mediaCreatorOptions.Destination = "$($mediaPath)/$($mediaItemName)";
      $mediaCreator = New-Object Sitecore.Resources.Media.MediaCreator
      $mediaCreator.CreateFromFile($filepath, $mediaCreatorOptions);

      # Delete downloaded image file
      Remove-Item $filePath
}

# Global Host/Key script variables used for OpenAI API
$script:OPENAI_API_ENDPOINT = ""
$script:OPENAI_API_KEY = ""

# Settings item is located at `/sitecore/system/Modules/PowerShell/Script Library/DALL-E Image Generator/OpenAI API Settings`
$settingsItem = Get-Item "master://{F102AE0D-6A5B-499B-9500-505D0E6F686F}"

# Check for Settings item
if ($null -eq $settingsItem) {
    Show-Alert "'OpenAI API Settings' item is missing: '/sitecore/system/Modules/PowerShell/Script Library/DALL-E Image Generator/OpenAI API Settings.  Please check this path or reinstall the module."
    Exit
}

# 'Default Media Names' setting
if ($settingsItem.Fields["Default Media Names"].Value -ne "") {
    $script:DEFAULT_MEDIA_NAMES = $settingsItem.Fields["Default Media Names"].Value
    if($script:DEFAULT_MEDIA_NAMES -eq ""){
        $script:DEFAULT_MEDIA_NAMES = "AIGeneratedImage"
    }
}

# OpenAI API Endpoint setting
if ($settingsItem.Fields["OpenAI API Endpoint"].Value -ne "") {
    $script:OPENAI_API_ENDPOINT = $settingsItem.Fields["OpenAI API Endpoint"].Value
}
else {
    Show-Alert "Endpoint host must be present on the 'OpenAI API Settings' item (default value: https://api.openai.com/v1/images/generations).  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/DALL-E Image Generator/OpenAI API Settings'. `n`n ID: '{F102AE0D-6A5B-499B-9500-505D0E6F686F}'"
    Exit 
}

# OpenAI API Key setting
if ($settingsItem.Fields["OpenAI API Key"].Value -ne "") {
    $script:OPENAI_API_KEY = $settingsItem.Fields["OpenAI API Key"].Value
}
else {
    Show-Alert "API key must be present on the 'OpenAI API Settings'  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/DALL-E Image Generator/OpenAI API Settings'. `n`n ID: '{F102AE0D-6A5B-499B-9500-505D0E6F686F}'"
    Exit 
}

# Get the current context item
$item = Get-Item "."

# Create sizing options for DALL-E (restricted to these three sizes https://beta.openai.com/docs/api-reference/images/create#images/create-size)
$sizeOptions = New-Object System.Collections.Specialized.OrderedDictionary
$sizeOptions.Add("256x256", "256x256")
$sizeOptions.Add("512x512", "512x512")
$sizeOptions.Add("1024x1024", "1024x1024")

# Create number of images options for DALL-E
$numberOptions = New-Object System.Collections.Specialized.OrderedDictionary
for ($i = 1; $i -le 5; $i++) {
    $numberOptions.Add($i, $i)
}

# Window with options for user selection
$dialogProps = @{
    Parameters       = @(
        @{ Name = "userPrompt"; Title = "Input a prompt to send to DALL-E OpenAI API"; editor = "text" },
        @{ Name = "sizeSelection"; Title = "Image Size"; options = $sizeOptions; editor = "radio" },
        @{ Name = "numberOfImages"; Title = "Number of Images"; options = $numberOptions; editor = "radio" },
        @{ Name = "mediaItemNames"; Title = "Media Item Name(s)"; editor = "text" }
    )
    Description      = "Generate images in the Media Library using DALL-E OpenAI." 
    Title            = "DALL-E OpenAI Image Generator" 
    OkButtonName     = "Continue" 
    CancelButtonName = "Cancel"
    Width            = 425 
    Height           = 285 
    Icon             = "apps/32x32/Robot.png"
}

# Wait for user input from options menu
$dialogResult = Read-Variable @dialogProps
if ($dialogResult -ne "ok") {
    # Exit if cancelled
    Exit
}

# Confirm user prompt input and image size selections have been made
if (($null -eq $userPrompt) -or ($null -eq $sizeSelection)) {
    Show-Alert "You must senter a prompt and a size to generate an image from DALL-E."
    Exit
}

# Set the media items names to the default value if not inputted
if(($null -eq $mediaItemNames) -or ($mediaItemNames -eq "")){
     $mediaItemNames = $script:DEFAULT_MEDIA_NAMES
}

# Invoke the Image Generation function and pass in all parameters
Invoke-ImageGeneration -TargetItem $item -UserInput $userPrompt -SizeSelection $sizeSelection -NumberOfImages $numberOfImages -MediaItemNames $mediaItemNames