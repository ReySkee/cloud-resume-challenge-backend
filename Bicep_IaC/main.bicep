targetScope = 'subscription'

@description('Location parity')
param location string = 'australiaeast'

@description('User ID')
param objectId string

@description('Resource Group name')
param rgName string

@secure()
param swatoken string 

@description('Static web app location due to availability')
param swaLoc string = 'eastasia'

resource resG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

module fapp2 'modules/fappSettings.bicep' = {
  name: 'functionAppSetting'
  scope: resG
  params: {
    location: resG.location
    cosmosName: cosmosDb.outputs.cosName
  }
  dependsOn:[
    cosmosDb
  ]
}

module secrets 'modules/secrets.bicep' = {
  name: 'addSecrets'
  scope: resG
  dependsOn: [
    kv
  ]
}

module cosmosDb 'modules/cosmosDb.bicep' = {
  name: 'cosmosDb'
  scope: resG
  params: {
    location: resG.location
  }
}

module kv 'modules/keyVault.bicep' = {
  name: 'kvault'
  scope: resG 
  params: {
    location: resG.location
    objectId: objectId
    fappId: fapp2.outputs.funcAppID
    stgId: cosmosDb.outputs.stgID
  }
  dependsOn:[
    cosmosDb
    fapp2
  ]
}

module swa 'modules/swa.bicep' = {
  name: 'swa'
  scope: resG 
  params: {
    swatoken: swatoken
    location: swaLoc
  }
}

