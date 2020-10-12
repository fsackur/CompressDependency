@{
    Description       = 'Package dependency modules into a single .ps1 and reinflate them like a self-extracting zip!'
    ModuleToProcess   = 'CompressRequiredModules.psm1'
    ModuleVersion     = '0.0.1'
    GUID              = 'ecdcdd30-fc42-4306-8b6c-f657e680acdc'

    Author            = 'Freddie Sackur'
    CompanyName       = 'Dusty Fox'
    Copyright         = '(c) Freddie Sackur. All rights reserved.'
    PowerShellVersion = '5.0'

    RequiredModules   = @()

    FunctionsToExport = @(
        'Compress-Dependency'
    )

    PrivateData       = @{
        PSData = @{
            ProjectUri    = 'https://raw.githubusercontent.com/fsackur/CompressRequiredModules'
            LicenseUri    = 'https://raw.githubusercontent.com/fsackur/CompressRequiredModules/main/LICENSE'
            ReleaseNotes  = 'https://raw.githubusercontent.com/fsackur/CompressRequiredModules/main/CHANGELOG.md'

            Tags          = @(
                'Dependency',
                'Module'
            )
        }
    }
}
