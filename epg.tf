### Point to NetOps remote backend to get info about Tenant, VRF,etc

data "terraform_remote_state" "networking" {
  backend = "remote"
  config = {
    organization = "cisco-dcn-ecosystem"
    workspaces = {
      name = "jristain-app-test"
    }
  }
}

provider "aci" {
  # cisco-aci user name
  username = var.aci_username
  password =  var.aci_password
  url      = var.apic_url
  insecure = true
}

resource "aci_tenant" "terraform_tenant" {
  name        = var.tenant
  description = "This tenant is created by terraform"
}

resource "aci_vrf" "vrf" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = var.vrf
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = var.bd1
  unicast_route = "yes"
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_subnet" "subnet" {
  parent_dn        = aci_bridge_domain.bd1.id
  ip               = "10.27.1.1/24"
  preferred        = "no"
  scope            = ["private"]
}

resource "aci_bridge_domain" "bd2" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = var.bd2
  unicast_route = "yes"
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_subnet" "subnet" {
  parent_dn        = aci_bridge_domain.bd2.id
  ip               = "10.27.2.1/24"
  preferred        = "no"
  scope            = ["private"]
}

resource "aci_application_profile" "terraform_ap" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = var.app
}

resource "aci_application_epg" "VMM1" {
  application_profile_dn = aci_application_profile.terraform_ap.id
  name                   = var.epg1
  relation_fv_rs_bd      = aci_bridge_domain.bd1.name
}

resource "aci_application_epg" "VMM2" {
  application_profile_dn = aci_application_profile.terraform_ap.id
  name                   = var.epg2
  relation_fv_rs_bd      = aci_bridge_domain.bd2.name
}

 resource "aci_epg_to_domain" "terraform_epg_domain" {
  application_epg_dn    = aci_application_epg.VMM1.id
  tdn                   = "uni/vmmp-VMware/dom-jr-dvs"
  res_imedcy            = "pre-provision"
  instr_imedcy          = "immediate"
#  vmm_allow_promiscuous = "accept"
#  vmm_forged_transmits  = "reject"
#  vmm_mac_changes       = "accept"
}

resource "aci_epg_to_domain" "terraform_epg_domain" {
  application_epg_dn    = aci_application_epg.VMM2.id
  tdn                   = "uni/vmmp-VMware/dom-jr-dvs"
  res_imedcy            = "pre-provision"
  instr_imedcy          = "immediate"
#  vmm_allow_promiscuous = "accept"
#  vmm_forged_transmits  = "reject"
#  vmm_mac_changes       = "accept"
}
