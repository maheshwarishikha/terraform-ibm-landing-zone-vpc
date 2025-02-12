##############################################################################
# Create new VPC
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name                        = var.prefix != null ? "${var.prefix}-${var.name}-vpc" : "${var.name}-vpc"
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = length([for prefix in values(coalesce(var.address_prefixes, {})) : prefix if prefix != null]) != 0 ? "manual" : null
  default_network_acl_name    = var.default_network_acl_name
  default_security_group_name = var.default_security_group_name
  default_routing_table_name  = var.default_routing_table_name
  tags                        = var.tags
  access_tags                 = var.access_tags
}

##############################################################################


##############################################################################
# Address Prefixes
##############################################################################

locals {
  # For each address prefix
  address_prefixes = {
    for prefix in module.dynamic_values.address_prefixes :
    (prefix.name) => prefix
  }
}

resource "ibm_is_vpc_address_prefix" "address_prefixes" {
  for_each = local.address_prefixes
  name     = each.value.name
  vpc      = ibm_is_vpc.vpc.id
  zone     = each.value.zone
  cidr     = each.value.cidr
}

data "ibm_is_vpc_address_prefixes" "get_address_prefixes" {
  depends_on = [ibm_is_vpc_address_prefix.address_prefixes, ibm_is_vpc_address_prefix.subnet_prefix]
  vpc        = ibm_is_vpc.vpc.id
}
##############################################################################


##############################################################################
# Create vpc route resource
##############################################################################

resource "ibm_is_vpc_routing_table" "route_table" {
  for_each                      = module.dynamic_values.routing_table_map
  name                          = "${var.prefix}-${var.name}-route-${each.value.name}"
  vpc                           = ibm_is_vpc.vpc.id
  route_direct_link_ingress     = each.value.route_direct_link_ingress
  route_transit_gateway_ingress = each.value.route_transit_gateway_ingress
  route_vpc_zone_ingress        = each.value.route_vpc_zone_ingress
}

resource "ibm_is_vpc_routing_table_route" "routing_table_routes" {
  for_each      = module.dynamic_values.routing_table_route_map
  vpc           = ibm_is_vpc.vpc.id
  routing_table = ibm_is_vpc_routing_table.route_table[each.value.route_table].routing_table
  zone          = "${var.region}-${each.value.zone}"
  name          = each.key
  destination   = each.value.destination
  action        = each.value.action
  next_hop      = each.value.next_hop
}

##############################################################################


##############################################################################
# Public Gateways (Optional)
##############################################################################

locals {
  # create object that only contains gateways that will be created
  gateway_object = {
    for zone in keys(var.use_public_gateways) :
    zone => "${var.region}-${index(keys(var.use_public_gateways), zone) + 1}" if var.use_public_gateways[zone]
  }
}

resource "ibm_is_public_gateway" "gateway" {
  for_each       = local.gateway_object
  name           = "${var.prefix}-${var.name}-public-gateway-${each.key}"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  zone           = each.value
  tags           = var.tags
  access_tags    = var.access_tags
}

##############################################################################

##############################################################################
# Add VPC to Flow Logs
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_flow_logs_inputs = (var.enable_vpc_flow_logs) ? ((var.create_authorization_policy_vpc_to_cos) ? ((var.existing_cos_instance_guid != null && var.existing_storage_bucket_name != null) ? true : tobool("Please provide COS instance & bucket name to create flow logs collector.")) : ((var.existing_storage_bucket_name != null) ? true : tobool("Please provide COS bucket name to create flow logs collector"))) : false
}

# Create authorization policy to allow VPC to access COS instance
resource "ibm_iam_authorization_policy" "policy" {
  count = (var.enable_vpc_flow_logs) ? ((var.create_authorization_policy_vpc_to_cos) ? 1 : 0) : 0

  source_service_name         = "is"
  source_resource_type        = "flow-log-collector"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = var.existing_cos_instance_guid
  roles                       = ["Writer"]
}

# Create VPC flow logs collector
resource "ibm_is_flow_log" "flow_logs" {
  count = (var.enable_vpc_flow_logs) ? 1 : 0

  name           = "${var.prefix}-${var.name}-logs"
  target         = ibm_is_vpc.vpc.id
  active         = var.is_flow_log_collector_active
  storage_bucket = var.existing_storage_bucket_name
  resource_group = var.resource_group_id
  tags           = var.tags
  access_tags    = var.access_tags
}

##############################################################################

##############################################################################
# Clean default network objects if required
##############################################################################

resource "null_resource" "clean_default_security_group" {
  count = (var.clean_default_security_group) ? 1 : 0
  # only clean if default security group changes
  triggers = {
    security_group_id = ibm_is_vpc.vpc.default_security_group
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/fix_security_group.sh -s '${ibm_is_vpc.vpc.default_security_group}' -r '${var.region}' -g '${var.resource_group_id}' -v '${var.ibmcloud_api_visibility}'"
    interpreter = ["bash", "-c"]
    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
    }
  }
}

resource "null_resource" "clean_default_acl" {
  count = (var.clean_default_acl) ? 1 : 0
  # only clean if default acl changes
  triggers = {
    acl_id = ibm_is_vpc.vpc.default_network_acl
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/fix_access_control_list.sh -a '${ibm_is_vpc.vpc.default_network_acl}' -r '${var.region}' -g '${var.resource_group_id}' -v '${var.ibmcloud_api_visibility}'"
    interpreter = ["bash", "-c"]
    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
    }
  }
}
