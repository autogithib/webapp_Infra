resource "azurerm_public_ip" "lb" {
    name                         = "pubip-lb"
    domain_name_label            = "hackathonlb-nginx"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Dynamic"
  }

#create Load balancer
resource "azurerm_lb" "nginx" {
  name                = "nginxlb"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  frontend_ip_configuration {
    name                 = "nginxlb-frontend-ip-config"
    public_ip_address_id = "${azurerm_public_ip.lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  loadbalancer_id     = "${azurerm_lb.nginx.id}"
  name                = "http_80_BackendPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_vms" {
  count                   = length(var.instances)
  network_interface_id    = "${element(azurerm_network_interface.instances.*.id, count.index )}"
  ip_configuration_name   = "backendpool-ipconfig"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.lb_backend_pool.id}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  loadbalancer_id     = "${azurerm_lb.nginx.id}"
  name                = "http-80"
  port                = 80
  protocol            = "tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

#resource "azurerm_lb_nat_rule" "lb_nat_rule" {
#  count                          = length(var.node_vm)
#  resource_group_name            = "${azurerm_resource_group.main.name}"
#  location                       = "${azurerm_resource_group.main.location}"
#  loadbalancer_id                = "${azurerm_lb.kubelb.id}"
#  name                           = "SSH-${var.node_vm[count.index]}"
#  protocol                       = "tcp"
#  frontend_port                  = "808${count.index + 1}"
#  backend_port                   = 22
#  frontend_ip_configuration_name = "kubelb-frontend-ip-config"  
#}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.main.name}"
  location                       = "${azurerm_resource_group.main.location}"
  loadbalancer_id                = "${azurerm_lb.nginx.id}"
  name                           = "lb_rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "nginxlb-frontend-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb_backend_pool.id}"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
 }

output svc_lb {
  value = ["${azurerm_lb.nginx.*}"]
  #"${azurerm_lb.kubelb.ip_address}","${azurerm_public_ip.master.*.fqdn}"]
}
