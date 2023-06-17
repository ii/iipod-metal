resource "coder_metadata" "key" {
  resource_id = tls_private_key.secret.id
  count       = data.coder_workspace.ii.start_count
  hide        = true
  item {
    key   = "algorithm"
    value = tls_private_key.secret.algorithm
  }
  item {
    key   = "rsa_bits"
    value = tls_private_key.secret.rsa_bits
  }
  # Maybe some logic to display ecdsa_curve based on algorithm?
  # item {
  #   key   = "ecdsa_curve"
  #   value = tls_private_key.secret.ecdsa_curve
  # }
}

resource "coder_metadata" "registration" {
  resource_id = acme_registration.email.id
  count       = data.coder_workspace.ii.start_count
  hide        = true
  item {
    key   = "email"
    value = acme_registration.email.email_address
  }
  item {
    key   = "registration_url"
    value = acme_registration.email.registration_url
  }
}

resource "coder_metadata" "certificate" {
  resource_id = acme_certificate.wildcard.id
  count       = data.coder_workspace.ii.start_count
  icon        = "https://raw.githubusercontent.com/cert-manager/cert-manager/master/logo/logo.svg"
  # hide        = true
  item {
    key   = "emacs"
    value = "http://emacs.${local.dns_zone}"
  }
  item {
    key   = "vnc"
    value = "http://novnc.${local.dns_zone}"
  }
  item {
    key   = "ttyd"
    value = "http://ttyd.${local.dns_zone}"
  }
  item {
    key   = "hubble"
    value = "http://hubble.${local.dns_zone}"
  }
  item {
    key   = "domain"
    value = acme_certificate.wildcard.certificate_domain
  }
  item {
    key   = "cert_url"
    value = acme_certificate.wildcard.certificate_url
  }
  item {
    key   = "expires"
    value = acme_certificate.wildcard.certificate_not_after
  }
}

resource "tls_private_key" "secret" {
  algorithm = "RSA"
  # rsa_bits  = 4096
}

resource "acme_registration" "email" {
  account_key_pem = tls_private_key.secret.private_key_pem
  email_address   = "cert@ii.coop"
}

resource "acme_certificate" "wildcard" {
  account_key_pem           = acme_registration.email.account_key_pem
  common_name               = "*.${local.dns_zone}"
  subject_alternative_names = [local.dns_zone]
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/guides/dns-providers-pdns#argument-reference
  dns_challenge {
    provider = "pdns"
  }
}

