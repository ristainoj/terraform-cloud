resource "aci_filter" "VMM" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = "VMM"
}

resource "aci_filter_entry" "VMM" {
  filter_dn     = aci_filter.VMM.id
  name          = "test_tf_entry"
  description   = "This entry is created by terraform ACI provider"
  ether_t       = "unspecified"
}

resource "aci_contract" "VMM" {
  tenant_dn = aci_tenant.terraform_tenant.id
  name      = "VMM"
}

resource "aci_contract_subject" "VMM" {
  contract_dn                  = aci_contract.VMM.id
  name                         = "VMM_Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.VMM.id]
}

resource "aci_epg_to_contract" "Consumer" {
  application_epg_dn = aci_application_epg.VMM1.id
  contract_dn        = aci_contract.VMM.id
  contract_type      = "consumer"
}

resource "aci_epg_to_contract" "Provider" {
  application_epg_dn = aci_application_epg.VMM2.id
  contract_dn        = aci_contract.VMM.id
  contract_type      = "provider"
}
