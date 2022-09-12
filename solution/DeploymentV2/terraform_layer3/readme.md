This is layer three of the ADS Go Fast Terraform deployment 

# Notes regarding permissions need to deploy this layer
This layer needs to read & write to the Azure Function Enterprise Application and Service Principal. Therefore the deployment account needs Application.ReadWrite.OwnedBy as well as Directory.Read.All in the Azure Graph API. It also needs to be an owner of the Azure Function Enterprise Application and Service Principal. If the deployment is Vnet Isolated it will also require the Azure network contributor role.

In order to write the function app secret into key vault it also requires secret read/write on the key vault used by the deployment.

# CICD Notes
Generally this layer only needs to run once and does not need to be part of ongoing CICD


