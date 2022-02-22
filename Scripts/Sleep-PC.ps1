$signature = @"
[DllImport("powrprof.dll")]
public static extern bool SetSuspendState(bool Hibernate,bool ForceCritical,bool DisableWakeEvent);
"@
$func = Add-Type -memberDefinition $signature -namespace "Win32Functions" -name "SetSuspendStateFunction" -passThru
$func::SetSuspendState($false, $false, $false)