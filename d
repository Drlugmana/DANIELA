# =========================================================
# Variables Globales
# =========================================================
[int] $timeout = 15

[string] $querySQLVersion = @"
select @@version as Version
"@

[string] $querySQLLogs = @"
WITH CTE AS
(
    select 
        A.ServerName as Instancia,
        dateadd(hour,-5,A.UTCOccurrenceDateTime) as Fecha,
        MI.Name as Alerta,
        A.Heading as Cabecera,
        A.Message as Mensaje,
        case A.Severity
            when 8 then 'Critical'
            when 4 then 'Warning'
            when 2 then 'Info'
            when 1 then 'Normal'
            when 0 then 'None'
            else cast(A.Severity as varchar)
        end as Severidad
    from SQLdmRepository.dbo.Alerts A with (nolock)
    inner join SQLdmRepository.dbo.MetricInfo MI with (nolock)
        ON A.Metric = MI.Metric
    where A.ServerName is not null
      and dateadd(hour,-5,A.UTCOccurrenceDateTime) >= dateadd(hour,-6,getdate())
)
select 
    Instancia,
    max(Fecha) as Fecha,
    Alerta,
    max(Mensaje) as Mensaje,
    max(Severidad) as Severidad
from CTE
group by
    Instancia,
    Alerta
order by 
    Instancia,
    max(Fecha)
"@

# =========================================================
# Método de ejecución SQL
# =========================================================
function Exec-SQLQuery ($instance, $querySQL)
{
    $connSQL = New-Object System.Data.SqlClient.SqlConnection
    $cmdSQL  = New-Object System.Data.SqlClient.SqlCommand
    $daSQL   = New-Object System.Data.SqlClient.SqlDataAdapter
    $dsSQL   = New-Object System.Data.DataSet

    try {
        $connSQL.ConnectionString = "Server=$instance;Database=master;Integrated Security=True;Connection Timeout=$timeout"
        $cmdSQL.Connection = $connSQL
        $cmdSQL.CommandText = $querySQL
        $cmdSQL.CommandTimeout = $timeout
        $daSQL.SelectCommand = $cmdSQL
        [void]$daSQL.Fill($dsSQL)
        return $dsSQL.Tables[0]
    }
    catch {
        Write-Error "Error SQL en $instance : $($_.Exception.Message)"
        return $null
    }
    finally {
        $connSQL.Dispose()
        $cmdSQL.Dispose()
        $daSQL.Dispose()
        $dsSQL.Dispose()
    }
}

# =========================================================
# Método principal
# =========================================================
function main()
{
    [string] $strPath = "\\Precwfs003\h$\Backup_SQL_04\Dynatrace\Logs"

    if (!(Test-Path $strPath)) {
        Write-Error "No existe la ruta $strPath"
        return
    }

    Remove-Item "$strPath\*.log" -Force -ErrorAction SilentlyContinue

    $dtLogs = Exec-SQLQuery "ECBPPRQ23,11423" $querySQLLogs

    if ($dtLogs -eq $null -or $dtLogs.Rows.Count -eq 0) {
        Write-Warning "No se encontraron alertas en SQLdm"
        return
    }

    # =====================================================
    # Generación directa de archivos LOG (FUNCIONAL)
    # =====================================================
    foreach ($instancia in ($dtLogs | Select-Object -ExpandProperty Instancia -Unique)) {

        $tabla = New-Object System.Data.DataTable
        [void]$tabla.Columns.Add("Mensaje",[string])

        foreach ($drLogs in $dtLogs) {
            if ($drLogs["Instancia"] -eq $instancia) {

                $row = $tabla.NewRow()
                $row.Mensaje =
                    $drLogs["Instancia"] + "`t" +
                    $drLogs["Alerta"] + "`t" +
                    $drLogs["Severidad"] + "`t" +
                    $drLogs["Mensaje"]

                $tabla.Rows.Add($row)
            }
        }

        if ($tabla.Rows.Count -gt 0) {

            $fileName = $instancia.Replace('\','_')
            $filePath = "$strPath\$fileName.log"

            Write-Host "Generando log para $instancia" -ForegroundColor Green

            $tabla |
                Format-Table -HideTableHeaders -AutoSize |
                Out-File -FilePath $filePath -Encoding utf8
        }
    }
}

cls
main