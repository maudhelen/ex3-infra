param location string = 'East US'

// Registry Module
param registryName string = 'myRegistry'
param registryAcrAdminUserEnabled bool = true

module registry './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: 'registryModule'
  params: {
    name: registryName
    acrAdminUserEnabled: registryAcrAdminUserEnabled
    location: location
  }
}

// Serverfarm Module
param appServicePlanName string = 'serverfarm'

module serverfarm './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
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
    }
    reserved: true
  }
}

// Site Module

param registryImageName string
param registryImageVersion string

param siteName string = 'webapp'
param DOCKER_REGISTRY_SERVER_USERNAME string
@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string 

module siteModule './ResourceModules-main/modules/web/site/main.bicep' = {
  name: 'siteModule'
  params: {
    kind: 'app'
    name: siteName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${registryName}.azurecr.io/${registryImageName}:${registryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs : {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${registryName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: DOCKER_REGISTRY_SERVER_USERNAME
      DOCKER_REGISTRY_SERVER_PASSWORD: DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}
