# Terraform / OpenTofu Provider for Proxmox VE

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/bpg/terraform-provider-proxmox)](https://github.com/bpg/terraform-provider-proxmox/releases/latest)
[![GitHub Release Date](https://img.shields.io/github/release-date/bpg/terraform-provider-proxmox)](https://github.com/bpg/terraform-provider-proxmox/releases/latest)
[![GitHub stars](https://img.shields.io/github/stars/bpg/terraform-provider-proxmox?style=flat)](https://github.com/bpg/terraform-provider-proxmox/stargazers)
[![All Contributors](https://img.shields.io/github/all-contributors/bpg/terraform-provider-proxmox)](#contributors)
[![Go Report Card](https://goreportcard.com/badge/github.com/bpg/terraform-provider-proxmox)](https://goreportcard.com/report/github.com/bpg/terraform-provider-proxmox)
[![Conventional Commits](https://img.shields.io/badge/conventional%20commits-v1.0.0-ff69b4)](https://www.conventionalcommits.org/en/v1.0.0/)
[![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/bpg/terraform-provider-proxmox?utm_source=oss&utm_medium=github&utm_campaign=bpg%2Fterraform-provider-proxmox&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)](https://www.coderabbit.ai/)
[![Wakatime](https://wakatime.com/badge/github/bpg/terraform-provider-proxmox.svg)](https://wakatime.com/@a51a1a51-85c3-497b-b88a-3b310a709909/projects/vdtgmpvjom)

A Terraform / OpenTofu Provider that adds support for Proxmox Virtual Environment.

This repository is a fork of <https://github.com/danitso/terraform-provider-proxmox> which is no longer maintained.

## Compatibility Promise

This provider is compatible with Proxmox VE 8.x (currently **8.3**).

> [!IMPORTANT]
> Proxmox VE 7.x is NOT supported. While some features might work with 7.x, we do not test against it, and issues specific to 7.x will not be addressed.

While the provider is on version 0.x, it is not guaranteed to be backward compatible with all previous minor versions.
However, we will try to maintain backward compatibility between provider versions as much as possible.

## Requirements

### Production Requirements

- [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-virtual-environment/) 8.x
- TLS 1.3 for the Proxmox API endpoint (legacy TLS 1.2 is optionally supported)
- [Terraform](https://www.terraform.io/downloads.html) 1.5.x+ or [OpenTofu](https://opentofu.org) 1.6.x+

### Development Requirements

- [Go](https://golang.org/doc/install) 1.24 (to build the provider plugin)
- [Docker](https://www.docker.com/products/docker-desktop/) (optional, for running dev tools)

## Using the Provider

You can find the latest release and its documentation in the [Terraform Registry](https://registry.terraform.io/providers/bpg/proxmox/latest).

## Testing the Provider

To test the provider, simply run `make test`.

```sh
make test
```

Tests are limited to regression tests, ensuring backward compatibility.

A limited number of acceptance tests are available in the `proxmoxtf/test` directory, mostly for "new" functionality implemented using the Terraform Provider Framework.
These tests are not run by default, as they require a Proxmox VE environment to be available.
They can be run using `make testacc`. The Proxmox connection can be configured using environment variables; see the provider documentation for details.

## Deploying the Example Resources

There are a number of TF examples in the `example` directory, which can be used to deploy a Container, VM, or other Proxmox resources in your test Proxmox environment.

### Prerequisites

The following assumptions are made about the test environment:

- It has one node named `pve`
- The node has local storages named `local` and `local-lvm`
- The "Snippets" content type is enabled in the `local` storage
- Default Linux Bridge "vmbr0" is VLAN aware (datacenter -> pve -> network -> edit & apply)

Create `example/terraform.tfvars` with the following variables:

```sh
virtual_environment_endpoint                 = "https://pve.example.doc:8006/"
virtual_environment_ssh_username             = "terraform"
virtual_environment_api_token                = "root@pam!terraform=00000000-0000-0000-0000-000000000000"
```

Then run `make example` to deploy the example resources.

If you don't have a free Proxmox cluster to play with, there is a dedicated [how-to tutorial](docs/guides/setup-proxmox-for-tests.md) on how to set up Proxmox inside a VM and run `make example` on it.

## Future Work

The provider is using the [Terraform SDKv2](https://developer.hashicorp.com/terraform/plugin/sdkv2), which is considered legacy and is in maintenance mode.
Work has started to migrate the provider to the new [Terraform Plugin Framework](https://developer.hashicorp.com/terraform/plugin/framework), with the aim of releasing it as a new major version **1.0**.

## Known Issues

### Disk Images Cannot Be Imported by Non-PAM Accounts

Due to limitations in the Proxmox VE API, certain actions need to be performed using SSH. This requires the use of a PAM account (standard Linux account).

### Disk Images from VMware Cannot Be Uploaded or Imported

Proxmox VE does not currently support VMware disk images directly.
However, you can still use them as disk images by using this workaround:

```hcl
resource "proxmox_virtual_environment_file" "vmdk_disk_image" {
  content_type = "iso"
  datastore_id = "datastore-id"
  node_name    = "node-name"

  source_file {
    # We must override the file extension to bypass the validation code
    # in the Proxmox VE API.
    file_name = "vmdk-file-name.img"
    path      = "path-to-vmdk-file"
  }
}

resource "proxmox_virtual_environment_vm" "example" {
  //...

  disk {
    datastore_id = "datastore-id"
    # We must tell the provider that the file format is vmdk instead of qcow2.
    file_format  = "vmdk"
    file_id      = "${proxmox_virtual_environment_file.vmdk_disk_image.id}"
  }

  //...
}
```

### Snippets Cannot Be Uploaded by Non-PAM Accounts

Due to limitations in the Proxmox VE API, certain files (snippets, backups) need to be uploaded using SFTP.
This requires the use of a PAM account (standard Linux account).

### Cluster Hardware Mappings Cannot Be Created by Non-PAM Accounts

Due to limitations in the Proxmox VE API, cluster hardware mappings must be created using the `root` PAM account (standard Linux account) due to [IOMMU](https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit#Virtualization) interactions.
Hardware mappings allow the use of [PCI "passthrough"](https://pve.proxmox.com/wiki/PCI_Passthrough) and [map physical USB ports](https://pve.proxmox.com/wiki/USB_Physical_Port_Mapping).

## Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for a list of contributors to this project.

## Repository Metrics

<picture>
  <img src="https://gist.githubusercontent.com/bpg/2cc44ead81225542ed1ef0303d8f9eb9/raw/metrics.svg?p" alt="Metrics">
</picture>

## Sponsorship

❤️ This project is sponsored by:

- [TJ Zimmerman](https://github.com/zimmertr)
- [Elias Alvord](https://github.com/elias314)
- [laktosterror](https://github.com/laktosterror)
- [Greg Brant](https://github.com/gregbrant2)
- [Serge](https://github.com/sergelogvinov)
- [Daniel Brennand](https://github.com/dbrennand)

Thanks again for your continuous support, it is much appreciated! 🙏

## Acknowledgements

This project has been developed with **GoLand** IDE under the [JetBrains Open Source license](https://www.jetbrains.com/community/opensource/#support), generously provided by JetBrains s.r.o.

<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/GoLand_icon.png" alt="GoLand logo" width="80">
