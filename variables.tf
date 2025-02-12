##############################################################################
# Module Level Variables
##############################################################################

variable "name" {
  description = "Name for VPC"
  type        = string
}

variable "resource_group_id" {
  description = "The resource group ID where the VPC to be created"
  type        = string
}

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VPC resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

##############################################################################

##############################################################################
# Optional VPC Variables
##############################################################################

variable "network_cidrs" {
  description = "List of Network CIDRs for the VPC. This is used to manage network ACL rules for cluster provisioning."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "classic_access" {
  description = "OPTIONAL - Classic Access to the VPC"
  type        = bool
  default     = false
}

variable "default_network_acl_name" {
  description = "OPTIONAL - Name of the Default ACL. If null, a name will be automatically generated"
  type        = string
  default     = null
}

variable "default_security_group_name" {
  description = "OPTIONAL - Name of the Default Security Group. If null, a name will be automatically generated"
  type        = string
  default     = null
}

variable "default_routing_table_name" {
  description = "OPTIONAL - Name of the Default Routing Table. If null, a name will be automatically generated"
  type        = string
  default     = null
}

variable "address_prefixes" {
  description = "OPTIONAL - IP range that will be defined for the VPC for a certain location. Use only with manual address prefixes"
  type = object({
    zone-1 = optional(list(string))
    zone-2 = optional(list(string))
    zone-3 = optional(list(string))
  })
  default = {
    zone-1 = null
    zone-2 = null
    zone-3 = null
  }
  validation {
    error_message = "Keys for `use_public_gateways` must be in the order `zone-1`, `zone-2`, `zone-3`."
    condition     = var.address_prefixes == null ? true : (keys(var.address_prefixes)[0] == "zone-1" && keys(var.address_prefixes)[1] == "zone-2" && keys(var.address_prefixes)[2] == "zone-3")
  }
}

##############################################################################


##############################################################################
# Network ACLs
##############################################################################

variable "network_acls" {
  description = "The list of ACLs to create. Provide at least one rule for each ACL."
  type = list(
    object({
      name                         = string
      add_ibm_cloud_internal_rules = optional(bool)
      add_vpc_connectivity_rules   = optional(bool)
      prepend_ibm_rules            = optional(bool)
      rules = list(
        object({
          name        = string
          action      = string
          destination = string
          direction   = string
          source      = string
          tcp = optional(
            object({
              port_max        = optional(number)
              port_min        = optional(number)
              source_port_max = optional(number)
              source_port_min = optional(number)
            })
          )
          udp = optional(
            object({
              port_max        = optional(number)
              port_min        = optional(number)
              source_port_max = optional(number)
              source_port_min = optional(number)
            })
          )
          icmp = optional(
            object({
              type = optional(number)
              code = optional(number)
            })
          )
        })
      )
    })
  )

  default = [
    {
      name                         = "vpc-acl"
      add_ibm_cloud_internal_rules = true
      add_vpc_connectivity_rules   = true
      prepend_ibm_rules            = true
      rules = [
        ## The below rules may be added to easily provide network connectivity for a loadbalancer
        ## Note that opening 0.0.0.0/0 is not FsCloud compliant
        # {
        #   name      = "allow-all-443-inbound"
        #   action    = "allow"
        #   direction = "inbound"
        #   tcp = {

        #     port_min = 443
        #     port_max = 443
        #     source_port_min = 1024
        #     source_port_max = 65535
        #   }
        #   destination = "0.0.0.0/0"
        #   source      = "0.0.0.0/0"
        # },
        # {
        #   name      = "allow-all-443-outbound"
        #   action    = "allow"
        #   direction = "outbound"
        #   tcp = {
        #     source_port_min = 443
        #     source_port_max = 443
        #     port_min = 1024
        #     port_max = 65535
        #   }
        #   destination = "0.0.0.0/0"
        #   source      = "0.0.0.0/0"
        # }
      ]
    }
  ]

  validation {
    error_message = "ACL rule actions can only be `allow` or `deny`."
    condition = length(distinct(
      flatten([
        # Check through rules
        for rule in flatten([var.network_acls[*].rules]) :
        # Return false action is not valid
        false if !contains(["allow", "deny"], rule.action)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule direction can only be `inbound` or `outbound`."
    condition = length(distinct(
      flatten([
        # Check through rules
        for rule in flatten([var.network_acls[*].rules]) :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition = length(distinct(
      flatten([
        # Check through rules
        for rule in flatten([var.network_acls[*].rules]) :
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }

}

##############################################################################


##############################################################################
# Public Gateways
##############################################################################

variable "use_public_gateways" {
  description = "Create a public gateway in any of the three zones with `true`."
  type = object({
    zone-1 = optional(bool)
    zone-2 = optional(bool)
    zone-3 = optional(bool)
  })
  default = {
    zone-1 = true
    zone-2 = false
    zone-3 = false
  }

  validation {
    error_message = "Keys for `use_public_gateways` must be in the order `zone-1`, `zone-2`, `zone-3`."
    condition     = keys(var.use_public_gateways)[0] == "zone-1" && keys(var.use_public_gateways)[1] == "zone-2" && keys(var.use_public_gateways)[2] == "zone-3"
  }
}

##############################################################################


##############################################################################
# Subnets
##############################################################################

variable "subnets" {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addressess. Public gateways will be enabled only in zones where a gateway has been created"
  type = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
    }))
  })

  default = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = true
        acl_name       = "vpc-acl"
      }
    ],
    zone-2 = [
      {
        name           = "subnet-b"
        cidr           = "10.20.10.0/24"
        public_gateway = true
        acl_name       = "vpc-acl"
      }
    ],
    zone-3 = [
      {
        name           = "subnet-c"
        cidr           = "10.30.10.0/24"
        public_gateway = false
        acl_name       = "vpc-acl"
      }
    ]
  }

  validation {
    error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
    condition     = keys(var.subnets)[0] == "zone-1" && keys(var.subnets)[1] == "zone-2" && keys(var.subnets)[2] == "zone-3"
  }
}

##############################################################################


##############################################################################
# Default Security Group Rules
##############################################################################

variable "security_group_rules" {
  description = "A list of security group rules to be added to the default vpc security group"
  default = [{
    name      = "default-sgr"
    direction = "inbound"
    remote    = "10.0.0.0/8"
  }]
  type = list(
    object({
      name      = string
      direction = string
      remote    = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }
}

variable "clean_default_security_group" {
  description = "Remove all rules from the default VPC security group (less permissive)"
  type        = bool
  default     = false
}

variable "clean_default_acl" {
  description = "Remove all rules from the default VPC ACL (less permissive)"
  type        = bool
  default     = false
}

variable "ibmcloud_api_visibility" {
  description = "IBM Cloud API visibility used by scripts run in this module. Must be 'public', 'private', or 'public-and-private'"
  type        = string
  default     = "public"

  validation {
    error_message = "IBM Cloud API visibility must be either 'public', 'private', or 'public-and-private'"
    condition     = (var.ibmcloud_api_visibility == "public") || (var.ibmcloud_api_visibility == "private") || (var.ibmcloud_api_visibility == "public-and-private")
  }
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key that will be used for authentication in scripts run in this module. Only required if certain options are chosen, such as the 'clean_default_*' variables being 'true'."
  type        = string
  sensitive   = true
  default     = null
}

##############################################################################


##############################################################################
# Add routes to VPC
##############################################################################

variable "routes" {
  description = "OPTIONAL - Allows you to specify the next hop for packets based on their destination address"
  type = list(
    object({
      name                          = string
      route_direct_link_ingress     = optional(bool)
      route_transit_gateway_ingress = optional(bool)
      route_vpc_zone_ingress        = optional(bool)
      routes = optional(
        list(
          object({
            action      = optional(string)
            zone        = number
            destination = string
            next_hop    = string
          })
      ))
    })
  )
  default = []
}

##############################################################################

##############################################################################
# VPC Flow Logs Variables
##############################################################################

variable "enable_vpc_flow_logs" {
  description = "Flag to enable vpc flow logs. If true, flow log collector will be created"
  type        = bool
  default     = false
}

variable "create_authorization_policy_vpc_to_cos" {
  description = "Create authorisation policy for VPC to access COS. Set as false if authorization policy exists already"
  type        = bool
  default     = false
}

variable "existing_cos_instance_guid" {
  description = "GUID of the COS instance to create Flow log collector"
  type        = string
  default     = null
}

variable "existing_storage_bucket_name" {
  description = "Name of the COS bucket to collect VPC flow logs"
  type        = string
  default     = null
}

variable "is_flow_log_collector_active" {
  description = "Indicates whether the collector is active. If false, this collector is created in inactive mode."
  type        = bool
  default     = true
}

##############################################################################
