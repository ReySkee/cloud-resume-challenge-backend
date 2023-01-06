@description('Azure Cosmos DB account name')
param accountName string = 'table-${uniqueString(resourceGroup().id)}'

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the container')
param containerName string = 'websitecounter'

// param kvName string = 'dpkeys${uniqueString(resourceGroup().id)}'

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: toLower(accountName)
  location: location
  tags: {
    defaultExperience: 'Azure Table'
  }
  kind: 'GlobalDocumentDB'
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    consistencyPolicy: {
      defaultConsistencyLevel: 'BoundedStaleness'
      maxIntervalInSeconds: 86400
      maxStalenessPrefix: 1000000
    }
    databaseAccountOfferType: 'Standard'
    
    defaultIdentity: 'FirstPartyIdentity'
    locations: locations
    enableAnalyticalStorage: false
    capabilities: [
      {
        name: 'EnableTable'
      }
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/tables@2022-08-15' = {
  parent: account
  name: containerName
  properties: {
    resource: {
      id: containerName
      
    }
  }
}


// resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//   name: kvName
// }

// resource stgSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: kv
//   name: 'cosmosName'

//   properties: {
//     value: account.name

//   }
// }

// resource tableKey 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: kv
//   name: '${account.name}-key'
//   properties: {
//     value: account.listKeys().primaryMasterKey
//   }
// }

// resource tableEp 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: kv
//   name: '${account.name}-EP'
//   properties: {
//     value: 'https://${account.name}.table.cosmos.azure.com:443/'
//   }
// }

// resource tableName 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: kv
//   name: 'counterName'
//   properties: {
//     value: container.name
//   }
// }

// resource tableName2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: kv
//   name: 'counterNameURL'
//   properties: {
//     value: tableName.properties.secretUri
//   }
// }


output stgID string = account.identity.principalId
output conName string = container.name
output cosName string = account.name
