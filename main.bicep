metadata description = 'This bicep file deploys a container registry, app service plan, and web app.'

param registryName string = 'containerregistry'
param location string = 'East US'
param registryAcrAdminUserEnabled bool = true
param appServicePlanName string = 'serverfarm'
param siteName string = 'webapp'
param registryUsername string = 'maudhelen'
param registryPassword string = 'maud1234'

module registry './modules/container-registry/registry/main.bicep' = {
  name: 'containerregistry'
  params: {
    // Required parameters
    name: registryName
    // Non-required parameters
    location: location
    acrAdminUserEnabled: registryAcrAdminUserEnabled
  }
}

module serverfarm './modules/web/serverfarm/main.bicep' = {
  name: 'serverfarm'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: '1'
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module site './modules/web/site/main.bicep' = {
  name: 'site'
  params: {
    kind: 'app'
    name: siteName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|containerregistry.azurecr.io/flask-demo:latest'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs : {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${registryName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: registryUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: registryPassword
      }
  }
}

