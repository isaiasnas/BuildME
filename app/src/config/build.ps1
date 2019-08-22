$pwd = pwd
$logBase = [System.String]::Concat("log_", [System.DateTime]::Now.ToString("yyyyMMddHHmmss"), ".txt")

function execute {
    try {
        ForEach ($in in $xml.config.actions.action | Sort-Object { [int]$_.order }) {
            if ([System.Convert]::ToBoolean($in.enable)) {
                switch ($in.id) {
                    import {
                        $log.Info("copy files from $($in.from) to $([System.IO.Path]::Combine($pwd,$in.to))")
                        clear
                        copy -from $([System.IO.Path]::Combine($xml.config.root.dir, $in.from)) -to $([System.IO.Path]::Combine($pwd, $in.to))
                    }
                    erase {
                        $log.Debug("clear files from $([System.IO.Path]::Combine($pwd,$in.from))")
                        clear
                        erase -folder $([System.IO.Path]::Combine($pwd, $in.from))
                    }
                    clone {
                        $log.Warn("clone files from $($in.url) to $([System.IO.Path]::Combine($pwd,$in.to))")
                        clear
                        clone -url $in.url -folder $([System.IO.Path]::Combine($pwd, $in.to))
                    }
					          clonebranch {
                        $log.Warn("clone files from $($in.url) to $([System.IO.Path]::Combine($pwd,$in.to))")
                        clear
                        clonebranch -from $in.from -url $in.url -folder $([System.IO.Path]::Combine($pwd, $in.to))
                    }					
                    build {
                        $log.Warn("building files from $([System.IO.Path]::Combine($pwd,$in.from))")
                        #clear
						        buil -pBool $([System.Convert]::ToBoolean($in.out)) -build $([System.IO.Path]::Combine($xml.config.root.build, "MSBuild.exe")) -pOut $([System.IO.Path]::Combine($pwd, $in.to)) -pIn $([System.IO.Path]::Combine($pwd, $in.from))
                    }
					          copy {
                        $log.Info("copy files from $($in.from) to $([System.IO.Path]::Combine($pwd,$in.to))")
                        clear
                        copy -from $([System.IO.Path]::Combine($pwd, $in.from)) -to $([System.IO.Path]::Combine($pwd, $in.to))
                    }
                    play {
                        $log.Warn("executing files *.bat from $($in.from)")
                        clear
                        play -from $([System.IO.Path]::Combine($pwd, $in.from)) -to $in.to
                    }
					          restore {
                        $log.Warn("executing files *.bat from $($in.from)")
                        clear
                        restore -pIn $([System.IO.Path]::Combine($pwd, $in.from))
                    }
					          clear {
                        $log.Warn("executing files *.bat from $($in.from)")
                        clear
						        clear -folder $([System.IO.Path]::Combine($pwd, $in.from))
                    }
                }          
            }
        }
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    
    }
}

function clear {
    param([string]$folder)
    try {
        if ($debugLog -eq $true) {break}
        set-location -Path $pwd
        erase $folder -Force -Recurse
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function json {
    param([System.Object]$argObj)
    if ($debugLog -eq $true) {break}
}

function play {
    param([string]$from, [string]$to)
    try {
        if ($debugLog -eq $true) {break}
        set-location -Path $from
        start-process $to
		    Start-Sleep -s 10
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function restore {
    param([string]$pIn)
    try {
        if ($debugLog -eq $true) {break}
        .\nuget restore $pIn
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function build {
    param([string]$pIn, [string]$pOut, [string]$build, [bool]$pBool)
    try {
        if ($debugLog -eq $true) {break}
        if ($pBool -eq $true) {
			    &$build $pIn /t:Clean /t:Rebuild /p:Configuration=Release /p:DebugSymbols=false /p:DebugType=None /p:Platform="mixed platforms" /p:ReferencePath=$pwd\Dlls /p:OutDir=$pOut     			
        }
        else {
            &$build $pIn /t:Clean /t:Rebuild /p:Configuration=Release /p:DebugSymbols=false /p:DebugType=None /p:Platform="x86" /p:ReferencePath=$pwd\Dlls /p:OutDir=bin\Release\
        }
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function log {
    param([string]$pLog)
    try {
        if ($debugLog -eq $true) {break}
        Add-Content -Path $logBase -Value $pLog -Encoding UTF8
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function clonebranch {
    param([string]$url, [string]$folder, [string]$from)
    try {
        if ($debugLog -eq $true) {break}
        git clone -b $from $url $folder
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function clone {
    param([string]$url, [string]$folder)
    try {
        if ($debugLog -eq $true) {break}
        git clone $url $folder
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function copy {
    param([string]$from, [string]$to)
    try {
        if ($debugLog -eq $true) {break}
        xcopy  $from $to /y/r/i/E
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}

function erase {
    param([string]$folder)
    try {
        if ($debugLog -eq $true) {break}
        erase $folder -Force -Recurse
    }
    catch [System.Exception] {
        $log.Error($_.Exception)
        exit
    }
}