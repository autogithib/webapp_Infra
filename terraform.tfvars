#servicepriciple-terraform
azure_subscription_id = "f23700aa-eaa5-4898-95aa-d4dc3622116d"
azure_client_id = "${var.client_id}"
azure_client_secret = "${var.client_secret}"
azure_tenant_id = "608147da-af1b-435d-bb8d-b4139988da46"

cluster_name      = "hackathon-webapp"
cluster_location  = "southeastasia"
instances         = ["hackathon-client1","hackathon-client2"]
admin_username    = "hackathon"
admin_password    = "Password1234!"
