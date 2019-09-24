#servicepriciple-terraform
subscription_id = "f23700aa-eaa5-4898-95aa-d4dc3622116d"
client_id = "${var.azure_client_id}"
client_secret = "${var.azure_client_secret}"
tenant_id = "608147da-af1b-435d-bb8d-b4139988da46"

cluster_name      = "hackathon-webapp"
cluster_location  = "southeastasia"
instances         = ["hackathon_client1","hackathon-client2"]
admin_username    = "hackathon"
admin_password    = "Password1234!"
