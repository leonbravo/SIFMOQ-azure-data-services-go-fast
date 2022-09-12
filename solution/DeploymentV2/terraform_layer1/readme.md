This is layer three of the ADS Go Fast Terraform deployment 

# Notes regarding permissions need to deploy this layer
This layer creates the Enterprise Applications and Service Principals required by the Web Application and Function Application. Therefore the deployment account needs Application.ReadWrite.OwnedBy as well as Directory.Read.All in the Azure Graph API. It also needs to be an owner of the Azure Function Enterprise Application and Service Principal.

# CICD Notes
Generally this layer only needs to run once and does not need to be part of ongoing CICD


