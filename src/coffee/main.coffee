module.exports =
  SphereClient: require './client'
  Rest: require './connect/rest'
  OAuth2: require './connect/oauth2'
  ProductSync: require './sync/product-sync'
  OrderSync: require './sync/order-sync'
  InventorySync: require './sync/inventory-sync'
  TaskQueue: require './task-queue'
  Errors: require './errors'