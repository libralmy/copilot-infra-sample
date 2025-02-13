RESOURCE_GROUP="emily-container-apps-group"
ENVIRONMENT_NAME="emily-storage-environment"
LOCATION="eastus2"
STORAGE_ACCOUNT_NAME="emilyacastorageaccount"
STORAGE_SHARE_NAME="emilyfileshare"
STORAGE_MOUNT_NAME="emilystoragemount"


az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --query "properties.provisioningState"

az containerapp env create \
  --name $ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION" \
  --query "properties.provisioningState"


az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT_NAME \
  --location "$LOCATION" \
  --kind StorageV2 \
  --sku Standard_LRS \
  --enable-large-file-share \
  --query provisioningState

az storage share-rm create \
  --resource-group $RESOURCE_GROUP \
  --storage-account $STORAGE_ACCOUNT_NAME \
  --name $STORAGE_SHARE_NAME \
  --quota 1024 \
  --enabled-protocols SMB \
  --output table

STORAGE_ACCOUNT_KEY=`az storage account keys list -n $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv`

az containerapp env storage set \
  --access-mode ReadWrite \
  --azure-file-account-name $STORAGE_ACCOUNT_NAME \
  --azure-file-account-key $STORAGE_ACCOUNT_KEY \
  --azure-file-share-name $STORAGE_SHARE_NAME \
  --storage-name $STORAGE_MOUNT_NAME \
  --name $ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table

CONTAINER_APP_NAME="my-container-app"

az containerapp create \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image nginx \
  --min-replicas 1 \
  --max-replicas 1 \
  --target-port 80 \
  --ingress external \
  --query properties.configuration.ingress.fqdn

#https://my-container-app.salmonbeach-9c084e65.eastus2.azurecontainerapps.io/
az containerapp show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --output yaml > app.yaml


  az containerapp update \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --yaml app.yaml \
  --output table

  az containerapp exec --name my-container-app --resource-group emily-container-apps-group