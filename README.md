# IBM Secure Landing Zone VPC module

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-landing-zone-vpc?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module creates the following IBM Cloud&reg; Virtual Private Cloud (VPC) network components:

- VPC: Creates a VPC in a resource group and supports classic access. The VPC and components are specified in the [main.tf](main.tf) file.
- Public gateways: Optionally create public gateways in the VPC in each of the three zones of the VPC's region.
- Subnets: Create one to three zones in the [subnet.tf](subnet.tf) file.
- Network ACLs: Create network ACLs with multiple rules. By default, VPC network ACLs can have no more than 25 rules.
- VPN gateways: Create VPN gateways on your subnets by using the `vpn_gateways` variable. For more information about VPN gateways on VPC, see [About site-to-site VPN gateways](https://cloud.ibm.com/docs/vpc?topic=vpc-using-vpn) in the IBM Cloud docs.
- VPN gateway connections: Add connections to a VPN gateway.

![vpc-module](./.docs/vpc-module.png)

## Presets

In addition to this root module, this repository provides two submodules that call the root module with presets and defaults that are aligned with the general [Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-vpc-architecture-about) management and workload VPC topologies. See the [landing-zone-submodules](/landing-zone-submodule/) for details.

## Before you begin

In addition to the [Terraform CLI](https://www.terraform.io/), some features of this module require additional software.

If the `clean_default_security_group` or `clean_default_acl` input variables are set to `true`, you need the IBM Cloud CLI and VPC plug-in:

- Install or update the [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)
- Install of update the [VPC infrastructure CLI plug-in](https://cloud.ibm.com/docs/cli?topic=cli-vpc-reference)

## Usage
```terraform
module vpc {
  source  = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  resource_group_id           = var.resource_group_id
  region                      = var.region
  prefix                      = var.prefix
  tags                        = var.tags
  vpc_name                    = var.vpc_name
  classic_access              = var.classic_access
  network_acls                = var.network_acls
  use_public_gateways         = var.use_public_gateways
  subnets                     = var.subnets
  vpn_gateways                = var.vpn_gateways
}
```

## Subnets

 You can create a maximum of three zones in the [subnet.tf](subnet.tf) file. The zones are defined as lists in the file, and then are converted to objects before the resources are provisioned. The conversion ensures that the addition or deletion of subnets affects only the added or deleted subnets, as shown in the following example.

```terraform
module.subnets.ibm_is_subnet.subnet["gcat-multizone-subnet-a"]
module.subnets.ibm_is_subnet.subnet["gcat-multizone-subnet-b"]
module.subnets.ibm_is_subnet.subnet["gcat-multizone-subnet-c"]
module.subnets.ibm_is_vpc_address_prefix.subnet_prefix["gcat-multizone-subnet-a"]
module.subnets.ibm_is_vpc_address_prefix.subnet_prefix["gcat-multizone-subnet-b"]
module.subnets.ibm_is_vpc_address_prefix.subnet_prefix["gcat-multizone-subnet-c"]
```

## Required IAM access policies
You need the following permissions to run this module.

- IAM services
    - **VPC Infrastructure** services
        - `Editor` platform access
    - **No service access**
        - **Resource Group** \<your resource group>
        - `Viewer` resource group access

To attach access management tags to resources in this module, you need the following permissions.

- IAM Services
    - **Tagging** service
        - `Administrator` platform access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Default Example](examples/default)
- [ Landing Zone example](examples/landing_zone)
<!-- END EXAMPLES HOOK -->
---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.52.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamic_values"></a> [dynamic\_values](#module\_dynamic\_values) | ./dynamic_values | n/a |
| <a name="module_unit_tests"></a> [unit\_tests](#module\_unit\_tests) | ./dynamic_values | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_flow_log.flow_logs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_flow_log) | resource |
| [ibm_is_network_acl.network_acl](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_network_acl) | resource |
| [ibm_is_public_gateway.gateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_public_gateway) | resource |
| [ibm_is_security_group_rule.default_vpc_rule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_rule) | resource |
| [ibm_is_subnet.subnet](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_subnet) | resource |
| [ibm_is_vpc.vpc](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc) | resource |
| [ibm_is_vpc_address_prefix.address_prefixes](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_address_prefix) | resource |
| [ibm_is_vpc_address_prefix.subnet_prefix](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_address_prefix) | resource |
| [ibm_is_vpc_routing_table.route_table](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_routing_table) | resource |
| [ibm_is_vpc_routing_table_route.routing_table_routes](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_routing_table_route) | resource |
| [null_resource.clean_default_acl](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.clean_default_security_group](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [ibm_is_vpc_address_prefixes.get_address_prefixes](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_vpc_address_prefixes) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the VPC resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | OPTIONAL - IP range that will be defined for the VPC for a certain location. Use only with manual address prefixes | <pre>object({<br>    zone-1 = optional(list(string))<br>    zone-2 = optional(list(string))<br>    zone-3 = optional(list(string))<br>  })</pre> | <pre>{<br>  "zone-1": null,<br>  "zone-2": null,<br>  "zone-3": null<br>}</pre> | no |
| <a name="input_classic_access"></a> [classic\_access](#input\_classic\_access) | OPTIONAL - Classic Access to the VPC | `bool` | `false` | no |
| <a name="input_clean_default_acl"></a> [clean\_default\_acl](#input\_clean\_default\_acl) | Remove all rules from the default VPC ACL (less permissive) | `bool` | `false` | no |
| <a name="input_clean_default_security_group"></a> [clean\_default\_security\_group](#input\_clean\_default\_security\_group) | Remove all rules from the default VPC security group (less permissive) | `bool` | `false` | no |
| <a name="input_create_authorization_policy_vpc_to_cos"></a> [create\_authorization\_policy\_vpc\_to\_cos](#input\_create\_authorization\_policy\_vpc\_to\_cos) | Create authorisation policy for VPC to access COS. Set as false if authorization policy exists already | `bool` | `false` | no |
| <a name="input_default_network_acl_name"></a> [default\_network\_acl\_name](#input\_default\_network\_acl\_name) | OPTIONAL - Name of the Default ACL. If null, a name will be automatically generated | `string` | `null` | no |
| <a name="input_default_routing_table_name"></a> [default\_routing\_table\_name](#input\_default\_routing\_table\_name) | OPTIONAL - Name of the Default Routing Table. If null, a name will be automatically generated | `string` | `null` | no |
| <a name="input_default_security_group_name"></a> [default\_security\_group\_name](#input\_default\_security\_group\_name) | OPTIONAL - Name of the Default Security Group. If null, a name will be automatically generated | `string` | `null` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Flag to enable vpc flow logs. If true, flow log collector will be created | `bool` | `false` | no |
| <a name="input_existing_cos_instance_guid"></a> [existing\_cos\_instance\_guid](#input\_existing\_cos\_instance\_guid) | GUID of the COS instance to create Flow log collector | `string` | `null` | no |
| <a name="input_existing_storage_bucket_name"></a> [existing\_storage\_bucket\_name](#input\_existing\_storage\_bucket\_name) | Name of the COS bucket to collect VPC flow logs | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API Key that will be used for authentication in scripts run in this module. Only required if certain options are chosen, such as the 'clean\_default\_*' variables being 'true'. | `string` | `null` | no |
| <a name="input_ibmcloud_api_visibility"></a> [ibmcloud\_api\_visibility](#input\_ibmcloud\_api\_visibility) | IBM Cloud API visibility used by scripts run in this module. Must be 'public', 'private', or 'public-and-private' | `string` | `"public"` | no |
| <a name="input_is_flow_log_collector_active"></a> [is\_flow\_log\_collector\_active](#input\_is\_flow\_log\_collector\_active) | Indicates whether the collector is active. If false, this collector is created in inactive mode. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for VPC | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | The list of ACLs to create. Provide at least one rule for each ACL. | <pre>list(<br>    object({<br>      name                         = string<br>      add_ibm_cloud_internal_rules = optional(bool)<br>      add_vpc_connectivity_rules   = optional(bool)<br>      prepend_ibm_rules            = optional(bool)<br>      rules = list(<br>        object({<br>          name        = string<br>          action      = string<br>          destination = string<br>          direction   = string<br>          source      = string<br>          tcp = optional(<br>            object({<br>              port_max        = optional(number)<br>              port_min        = optional(number)<br>              source_port_max = optional(number)<br>              source_port_min = optional(number)<br>            })<br>          )<br>          udp = optional(<br>            object({<br>              port_max        = optional(number)<br>              port_min        = optional(number)<br>              source_port_max = optional(number)<br>              source_port_min = optional(number)<br>            })<br>          )<br>          icmp = optional(<br>            object({<br>              type = optional(number)<br>              code = optional(number)<br>            })<br>          )<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "add_ibm_cloud_internal_rules": true,<br>    "add_vpc_connectivity_rules": true,<br>    "name": "vpc-acl",<br>    "prepend_ibm_rules": true,<br>    "rules": []<br>  }<br>]</pre> | no |
| <a name="input_network_cidrs"></a> [network\_cidrs](#input\_network\_cidrs) | List of Network CIDRs for the VPC. This is used to manage network ACL rules for cluster provisioning. | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix that you would like to append to your resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to which to deploy the VPC | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the VPC to be created | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | OPTIONAL - Allows you to specify the next hop for packets based on their destination address | <pre>list(<br>    object({<br>      name                          = string<br>      route_direct_link_ingress     = optional(bool)<br>      route_transit_gateway_ingress = optional(bool)<br>      route_vpc_zone_ingress        = optional(bool)<br>      routes = optional(<br>        list(<br>          object({<br>            action      = optional(string)<br>            zone        = number<br>            destination = string<br>            next_hop    = string<br>          })<br>      ))<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of security group rules to be added to the default vpc security group | <pre>list(<br>    object({<br>      name      = string<br>      direction = string<br>      remote    = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "direction": "inbound",<br>    "name": "default-sgr",<br>    "remote": "10.0.0.0/8"<br>  }<br>]</pre> | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addressess. Public gateways will be enabled only in zones where a gateway has been created | <pre>object({<br>    zone-1 = list(object({<br>      name           = string<br>      cidr           = string<br>      public_gateway = optional(bool)<br>      acl_name       = string<br>    }))<br>    zone-2 = list(object({<br>      name           = string<br>      cidr           = string<br>      public_gateway = optional(bool)<br>      acl_name       = string<br>    }))<br>    zone-3 = list(object({<br>      name           = string<br>      cidr           = string<br>      public_gateway = optional(bool)<br>      acl_name       = string<br>    }))<br>  })</pre> | <pre>{<br>  "zone-1": [<br>    {<br>      "acl_name": "vpc-acl",<br>      "cidr": "10.10.10.0/24",<br>      "name": "subnet-a",<br>      "public_gateway": true<br>    }<br>  ],<br>  "zone-2": [<br>    {<br>      "acl_name": "vpc-acl",<br>      "cidr": "10.20.10.0/24",<br>      "name": "subnet-b",<br>      "public_gateway": true<br>    }<br>  ],<br>  "zone-3": [<br>    {<br>      "acl_name": "vpc-acl",<br>      "cidr": "10.30.10.0/24",<br>      "name": "subnet-c",<br>      "public_gateway": false<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tags for the resource created | `list(string)` | `null` | no |
| <a name="input_use_public_gateways"></a> [use\_public\_gateways](#input\_use\_public\_gateways) | Create a public gateway in any of the three zones with `true`. | <pre>object({<br>    zone-1 = optional(bool)<br>    zone-2 = optional(bool)<br>    zone-3 = optional(bool)<br>  })</pre> | <pre>{<br>  "zone-1": true,<br>  "zone-2": false,<br>  "zone-3": false<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr_blocks"></a> [cidr\_blocks](#output\_cidr\_blocks) | List of CIDR blocks present in VPC stack |
| <a name="output_network_acls"></a> [network\_acls](#output\_network\_acls) | List of shortnames and IDs of network ACLs |
| <a name="output_public_gateways"></a> [public\_gateways](#output\_public\_gateways) | Map of public gateways by zone |
| <a name="output_subnet_detail_list"></a> [subnet\_detail\_list](#output\_subnet\_detail\_list) | A list of subnets containing names, CIDR blocks, and zones. |
| <a name="output_subnet_detail_map"></a> [subnet\_detail\_map](#output\_subnet\_detail\_map) | A map of subnets containing IDs, CIDR blocks, and zones |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The IDs of the subnets |
| <a name="output_subnet_zone_list"></a> [subnet\_zone\_list](#output\_subnet\_zone\_list) | A list containing subnet IDs and subnet zones |
| <a name="output_vpc_crn"></a> [vpc\_crn](#output\_vpc\_crn) | CRN of VPC created |
| <a name="output_vpc_flow_logs"></a> [vpc\_flow\_logs](#output\_vpc\_flow\_logs) | Details of VPC flow logs collector |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of VPC created |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of VPC created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
