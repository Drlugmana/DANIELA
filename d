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
        end as Severidad,
        A.Active
    from SQLdmRepository.dbo.Alerts A with (nolock)
    inner join SQLdmRepository.dbo.MetricInfo MI with (nolock)
        ON A.Metric = MI.Metric
    where A.ServerName is not null
      -- FILTRO DE TIEMPO (MISMA LÓGICA, VENTANA REAL)
      and dateadd(hour,-5,A.UTCOccurrenceDateTime) >= dateadd(hour,-4,getdate())
      and A.Message not like '%login%'
      and MI.Name IN
      (
        'Database Full (Percent)',
        'Log Full (Percent)',
        'Database Status',
        'Session Tempdb Space Usage (MB)',
        'Database Full (Size)',
        'Log Full (Size)',
        'SQL Server Error Log',
        'SQL Server Agent Status',
        'SQL Server Service',
        'Deadlock'
      )
      and A.Severity in (8,4)
)
select 
    P.Instancia,
    max(P.Fecha) as Fecha,
    P.Alerta,
    (
        select top(1)
            S.Mensaje
        from CTE S
        where P.Instancia = S.Instancia
          and P.Alerta = S.Alerta
        order by S.Fecha desc
    ) as Mensaje
from CTE P
group by
    P.Instancia,
    P.Alerta
order by 
    P.Instancia,
    max(P.Fecha)
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

    $arInstancia = New-Object System.Collections.ArrayList

    # =====================================================
    # Consulta de alertas SQLdm
    # =====================================================
    $dtLogs = Exec-SQLQuery "ECBPPRQ23,11423" $querySQLLogs

    if ($dtLogs -eq $null -or $dtLogs.Rows.Count -eq 0) {
        Write-Warning "No se encontraron alertas en SQLdm"
        return
    }

    # =====================================================
    # Identificación de instancias
    # =====================================================
    foreach ($drLogs in $dtLogs) {

        $instancia = $drLogs["Instancia"].ToString().Trim()

        if (!$arInstancia.Contains($instancia)) {

            $instanciaSQL = $instancia.Replace("'","''")

            $queryInstancias = @"
select 
    concat(MachineName,',',PortNumber) as Instancia1,
    concat(MachineName,InstanceName) as Instancia2
from Administracion_DB.dbo.connectlist
where Engine = 'S'
  and Status <> 'A'
  and concat(MachineName,InstanceName) = '$instanciaSQL'
"@

            $dtInsAUX = Exec-SQLQuery "ECBPPRQ23,11423" $queryInstancias

            foreach ($insAux in $dtInsAUX) {

                # NORMALIZACIÓN DE INSTANCIA
                $instance1 = $insAux["Instancia1"].ToString()
                $instance1 = $instance1 -replace ',+', ','
                $instance1 = $instance1.Trim(',')

                $dtVer = Exec-SQLQuery $instance1 $querySQLVersion

                if ($dtVer -ne $null -and $dtVer.Rows.Count -gt 0) {

                    $versionAux = $dtVer.Rows[0]["Version"].ToString()

                    if ($versionAux -match "2000|2005|2008") {
                        [void]$arInstancia.Add($instancia)
                    }
                }
            }
        }
    }

    # =====================================================
    # Generación de archivos LOG
    # =====================================================
    foreach ($instancia in $arInstancia) {

        $tabla = New-Object System.Data.DataTable
        [void]$tabla.Columns.Add("Mensaje",[string])

        foreach ($drLogs in $dtLogs) {

            if ($drLogs["Instancia"].ToString().Trim() -eq $instancia) {

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