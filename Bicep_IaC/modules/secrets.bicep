@description('Specifies the name of the key vault.')
param keyVaultName string = 'dpkeys${uniqueString(resourceGroup().id)}'

@description('Azure Cosmos DB account name')
param accountName string = 'table-${uniqueString(resourceGroup().id)}'

@description('The name for the container')
param containerName string = 'websitecounter'

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}


resource account 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: accountName
}

resource container 'Microsoft.DocumentDB/databaseAccounts/tables@2022-08-15' existing = {
  parent: account
  name: containerName
}


resource stgSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: 'cosmosName'
  properties: {
    value: account.name
  }
}

resource tableKey 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: '${account.name}-key'
  properties: {
    value: account.listKeys().primaryMasterKey
  }
}

resource tableEp 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: '${account.name}-EP'
  properties: {
    value: 'https://${account.name}.table.cosmos.azure.com:443/'
  }
}

resource tableName 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: 'counterName'
  properties: {
    value: container.name
  }
}

