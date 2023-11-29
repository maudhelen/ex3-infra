// main.bicep

param registryName string = 'containerregistry'
param location string = 'East US'
param registryAcrAdminUserEnabled bool = true
param appServicePlanName string = 'serverfarm'
param siteName string = 'webapp'
param registryUsername string = 'maudhelen'
param registryPassword string = 'maud1234'

module registryModule './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: 'registryModule'
  params: {
    // Required parameters
    name: registryName
    // Non-required parameters
    location: location
    acrAdminUserEnabled: registryAcrAdminUserEnabled
  }
}

module serverfarmModule './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: 'serverfarmModule'
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

module siteModule './ResourceModules-main/modules/web/site/main.bicep' = {
  name: 'siteModule'
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
