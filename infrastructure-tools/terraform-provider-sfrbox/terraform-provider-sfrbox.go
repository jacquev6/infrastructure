package main

import (
  "github.com/hashicorp/terraform/plugin"
  "github.com/hashicorp/terraform/terraform"
  "github.com/hashicorp/terraform/helper/schema"
)

func main() {
  plugin.Serve(&plugin.ServeOpts {
    ProviderFunc: func() terraform.ResourceProvider {
      return &schema.Provider {
        Schema: map[string]*schema.Schema {
          "login": &schema.Schema {
            Type: schema.TypeString,
            Required: true,
            Description: "The SFR box login",
          },
          "password": &schema.Schema {
            Type: schema.TypeString,
            Required: true,
            Description: "The SFR box password",
          },
        },
        ResourcesMap: map[string]*schema.Resource {
          "sfrbox_dhcpentry": &schema.Resource {
            Schema: map[string]*schema.Schema {
              "mac": {
                Type: schema.TypeString,
                Required: true,
                ForceNew: true,
              },
              "ip": {
                Type: schema.TypeString,
                Required: true,
                ForceNew: true,
              },
            },

            Create: func (d *schema.ResourceData, m interface{}) error {
              mac := d.Get("mac").(string)
              d.SetId(mac)
              return nil
            },
            Read: func (d *schema.ResourceData, m interface{}) error {
              return nil
            },
            Delete: func (d *schema.ResourceData, m interface{}) error {
              return nil
            },
            Exists: func (d *schema.ResourceData, m interface{}) (bool, error) {
              return true, nil
            },
          },
        },
      }
    },
  })
}
