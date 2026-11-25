@description('SQL logical server name')
param servers_sql_medicore_name string = 'sql-medicore'

@description('SQL database name')
param databaseName string = 'sqldb-medicore'

@description('Azure region')
param location string = 'spaincentral'

@description('SQL administrator login')
param administratorLogin string = 'medicoreadmin'

@secure()
@description('SQL administrator password')
param administratorPassword string

@description('Deploy the SQL database')
param deployDatabase bool = true

param tags object = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}

//=======================================//
// Azure SQL Logical Server
//=======================================//

resource servers_sql_medicore_name_resource 'Microsoft.Sql/servers@2023-08-01' = {
  name: servers_sql_medicore_name
  location: location
  tags: tags

  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    version: '12.0'
    minimalTlsVersion: '1.2'

    // Public endpoint remains enabled temporarily.
    // No broad firewall rule is created.
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

//=======================================//
// Azure SQL Database
//=======================================//

resource database 'Microsoft.Sql/servers/databases@2023-08-01' = if (deployDatabase) {
  parent: servers_sql_medicore_name_resource
  name: databaseName
  location: location
  tags: tags

  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }

  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    requestedBackupStorageRedundancy: 'Local'
    zoneRedundant: false
    isLedgerOn: false
  }
}
