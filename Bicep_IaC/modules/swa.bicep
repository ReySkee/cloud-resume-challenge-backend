param swaName string = 'dpweb-${uniqueString(resourceGroup().id)}'
param sku string = 'Free'
param location string = 'East Asia'

@secure()
param swatoken string

resource swaResource 'Microsoft.Web/staticSites@2022-03-01' = {
  name: swaName
  location: location
  sku: {
    name: sku
    tier: sku
  }

  properties: {
     
    repositoryToken: swatoken
    repositoryUrl: 'https://github.com/ReySkee/cloud-resume-challenge-frontend'
    branch: 'main'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'GitHub'
    enterpriseGradeCdnStatus: 'Disabled'
    buildProperties: {
      appLocation: 'front-end/'
      outputLocation: 'dist'
    }
  }
}







