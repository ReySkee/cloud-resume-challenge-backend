@description('The name of the function app that you wish to create.')
param appName string = 'cloud-fnapp${uniqueString(resourceGroup().id)}'


@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'node'

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'
var functionWorkerRuntime = runtime

// @secure()
// param endPoint string

// @secure()
// param accountKey string

// @secure()
// param accountName string


param cosmosName string

param kvName string = 'dpkeys${uniqueString(resourceGroup().id)}'

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosName
}

// resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//   name: kvName
// }



resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'ENDPOINT'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${cosmosDb.name}-EP)'
        }
        {
          name: 'ACCOUNT_NAME'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=cosmosName)'
        }
        {
          name: 'ACCOUNT_KEY'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${cosmosDb.name}-key)'
        }
        {
          name: 'TABLE_NAME'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=counterName)'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  parent: functionApp
  name: 'web'
  properties: { 
    branch: 'master'
    gitHubActionConfiguration: {
      generateWorkflowFile: true
       codeConfiguration:{
        runtimeStack: 'node'
        runtimeVersion: '16.x'
       }
       isLinux: false

    }
    deploymentRollbackEnabled: true
    isGitHubAction: false
    isMercurial: false
    isManualIntegration: false
    repoUrl: 'https://github.com/ReySkee/cloud-resume-challenge-backend'
  }
}


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    
  }
}

output funcAppID string = functionApp.identity.principalId
