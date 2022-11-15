#
# Author:   Swetha
#
# Date:     Nov 15, 2022
#
# Purpose:  This script enumerates all of the Azure Subscriptions visible to a login and looks for DTU based Azure SQL DBs.
#           Then updates them with custom DTU as per users requirement
#
$PremDTU = $args[0]
$StdDTU = $args[1]

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$sysdbs = "master", "tempdb", "msdb", "model"
$editions = "Standard", "Premium", "Basic"
$editionmap = @{Standard="General Purpose"; Premium="Business Critical"; Basic="General Purpose"}
$dtulookup = @{ Basic=5; S0=10; S1=20; S2=50; S3=100; S4=200; S6=400; S7=800; S9=1600; S12=3000; P1=125; P2=250; P4=500; P6=1000; P11=1750; P15=4000 }

# log into Azure
Connect-AzAccount -WarningAction SilentlyContinue

# get visible subscriptions for login
$subscriptions = Get-AzSubscription
ForEach($subscription in $subscriptions)
{
    # set the current subscription
    Set-AZContext -SubscriptionId $subscription | Out-Null

    $outfile = "c:\temp\$($subscription.Name).csv"
    "Processing: $($subscription.Name) to output file: $outfile"

    # delete target CSV, since we only append
    Remove-Item $outfile -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    # get resource groups in this subscription
    $rgs = Get-AzResourceGroup
    ForEach($rg in $rgs) 
    {
        # get all SQL Servers (this includes DW)
        $SQLServers = Get-AzSqlServer -ResourceGroup $rg.ResourceGroupName
        ForEach($srv in $SQLServers)
        {
            # get database properties
            $dbs = Get-AzSqlDatabaseExpanded -ResourceGroup $rg.ResourceGroupName -ServerName $srv.ServerName
            ForEach($db in $dbs)
            {
                # filter out vCore and DW
                if ($sysdbs -notcontains $db.DatabaseName -and $editions -contains $db.Edition)
                {
                    # we have no vCPU metrics for ElasticPools - so we need to look the number of Dtu's up
                    if ($db.CurrentServiceObjectiveName -eq "ElasticPool")
                    {
                        $ep = Get-AzSqlElasticPool -ResourceGroupName $rg.ResourceGroupName -ServerName $srv.ServerName -ElasticPoolName $db.ElasticPoolName
                        $DTU = $ep.Dtu
                        if ($db.Edition -eq 'Premium')
                        {

							Set-AzSqlElasticPool -ResourceGroupName "$ResourceGroup" -ServerName "$Server" -ElasticPoolName "$ElasticPool" -Dtu $PremDTU -DatabaseDtuMax 100 -DatabaseDtuMin 20 
                        }
                        else
                        {
                            Set-AzSqlElasticPool -ResourceGroupName "$ResourceGroup" -ServerName "$Server" -ElasticPoolName "$ElasticPool" -Dtu $StdDTU -DatabaseDtuMax 100 -DatabaseDtuMin 20 
                        }
                    }

                }
            }
        }
    }
}
