param location string = 'East US'

// Registry Module
param registryName string = 'myRegistry'
param registryAcrAdminUserEnabled bool = true

module registryModule './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: 'registryModule'
  params: {
    name: registryName
    acrAdminUserEnabled: registryAcrAdminUserEnabled
    location: location
  }
}

// Serverfarm Module
param appServicePlanName string = 'serverfarm'

module serverfarmModule './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: 'serverfarmModule'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
      kind: 'Linux'
      reserved: true
    }
  }
}

// Site Module
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string

param siteName string = 'webapp'
param registryUsername string = 'maudhelen'
param registryPassword string = 'maud1234'

module siteModule './ResourceModules-main/modules/web/site/main.bicep' = {
  name: 'siteModule'
  params: {
    kind: 'app'
    name: siteName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}',
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: registryUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: registryPassword
    }
  }
}
