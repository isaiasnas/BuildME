$pwd = pwd
[void][Reflection.Assembly]::LoadFile(([System.IO.Directory]::GetParent($MyInvocation.MyCommand.Path)).FullName + "\log4net.dll");
[log4net.LogManager]::ResetConfiguration();
$FileInfo = new-object System.IO.FileInfo "$pwd\config\log.xml"
[log4net.Config.XmlConfigurator]::Configure($FileInfo)
$Log = [log4net.LogManager]::GetLogger($env:computername);