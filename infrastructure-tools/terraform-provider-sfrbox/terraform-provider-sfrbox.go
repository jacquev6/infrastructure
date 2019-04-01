package main

// @todo Detect and report errors properly

import (
  // "fmt"
  "io/ioutil"
  "net/http"
  "net/url"
  // "os"
  "regexp"
  "strconv"
  "strings"
  "github.com/hashicorp/terraform/helper/schema"
  "github.com/hashicorp/terraform/plugin"
  "github.com/hashicorp/terraform/terraform"
)

func logger (fileName string) func(a... interface{}) {
  // logFile, _ := os.OpenFile(fileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
  // logFile.WriteString("\n")

  return func(a... interface{}) {
    // logFile.WriteString(fmt.Sprintln(a...))
  }
}

// @todo Put this type in its own module
type session struct {
  client *http.Client // @todo Why use a pointer here? What are the return semantics of Go?
  key string
  reservations map[string]string
}

func (session *session) Exists(mac string) bool {
  _, exists := session.reservations[mac]
  return exists
}

func (session *session) Get(mac string) string {
  ip := session.reservations[mac]
  return ip
}

func (session *session) Create(mac string, ip string) {
  macParts := strings.Split(mac, ":")
  ipParts := strings.Split(ip, ".")

  data := url.Values{
    "RgLanReserveMac0": {macParts[0]},
    "RgLanReserveMac1": {macParts[1]},
    "RgLanReserveMac2": {macParts[2]},
    "RgLanReserveMac3": {macParts[3]},
    "RgLanReserveMac4": {macParts[4]},
    "RgLanReserveMac5": {macParts[5]},
    "RgLanReserveIp3": {ipParts[len(ipParts) - 1]},
    "RgLanAddEntry": {"Ajouter"},
  }

  request, _ := http.NewRequest("POST", "http://192.168.0.1/goform/WebUiRgLanDhcpReserveIp?sessionKey=" + session.key, strings.NewReader(data.Encode()))
  request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
  request.Header.Set("Referer", "http://192.168.0.1/reseau-pb1-iplan.html")
  resp, _ := session.client.Do(request)
  defer resp.Body.Close()
  if(resp.StatusCode != 302) {
    panic("POST goform/WebUiRgLanDhcpReserveIp (create) not 302")
  }
  if(resp.Header["Location"][0] != "http://192.168.0.1/reseau-pb1-iplan.html") {
    panic("goform/WebUiRgLanDhcpReserveIp (create) location")
  }

  session.reservations[mac] = ip
}

func (session *session) Delete(mac string) {
  data := url.Values{
    "DhcpReservedDelete1": {mac},
    "DhcpReservedIpNum": {strconv.Itoa(len(session.reservations))},
    "RgLanRemoveEntry": {"Supprimer"},
  }

  request, _ := http.NewRequest("POST", "http://192.168.0.1/goform/WebUiRgLanDhcpReserveIp?sessionKey=" + session.key, strings.NewReader(data.Encode()))
  request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
  request.Header.Set("Referer", "http://192.168.0.1/reseau-pb1-iplan.html")
  resp, _ := session.client.Do(request)
  defer resp.Body.Close()
  if(resp.StatusCode != 302) {
    panic("POST goform/WebUiRgLanDhcpReserveIp (delete) not 302")
  }
  if(resp.Header["Location"][0] != "http://192.168.0.1/reseau-pb1-iplan.html") {
    panic("goform/WebUiRgLanDhcpReserveIp (delete) location")
  }

  delete(session.reservations, mac)
}

func main() {
  log := logger("./provider.sfrbox.log")

  sessionKeyRegex := regexp.MustCompile(`var SessionKey = '(.*)';`)
  reservationRegex := regexp.MustCompile(`<tr><td><input type="checkbox" name="DhcpReservedDelete." id="DhcpReservedDelete." value="..:..:..:..:..:.."/></td><td>.</td><td>(..:..:..:..:..:..)</td><td>(\d+.\d+.\d+.\d+)</td></tr>`)

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
              session := m.(*session)
              mac := d.Get("mac").(string)
              ip := d.Get("ip").(string)
              log("Create", mac, ip)
              if session.Exists(mac) {
                if (session.Get(mac) != ip) {
                  session.Delete(mac)
                  session.Create(mac, ip)
                }
              } else {
                session.Create(mac, ip)
              }
              d.SetId(mac)
              return nil
            },
            Read: func (d *schema.ResourceData, m interface{}) error {
              ip := m.(*session).Get(d.Id())
              log("Read", d.Id(), "->", ip)
              d.Set("mac", d.Id())
              d.Set("ip", ip)
              return nil
            },
            Delete: func (d *schema.ResourceData, m interface{}) error {
              log("Delete", d.Id())
              m.(*session).Delete(d.Id())
              return nil
            },
            Exists: func (d *schema.ResourceData, m interface{}) (bool, error) {
              exists := m.(*session).Exists(d.Id())
              log("Exists", d.Id(), "->", exists)
              return exists, nil
            },
          },
        },
        ConfigureFunc: func (d *schema.ResourceData) (interface{}, error) {
          // @todo Put this in a 'NewSession' function, and make it lazy: we don't need to call the sfrbox on "terraform plan -refresh=false"
          log("ConfigureFunc")

          client := &http.Client{
            CheckRedirect: func (req *http.Request, via []*http.Request) error {
              return http.ErrUseLastResponse
            },
          }

          resp, _ := client.Get("http://192.168.0.1/login.html")
          if(resp.StatusCode != 200) {
            panic("GET login.html not 200")
          }
          defer resp.Body.Close()
          body, _ := ioutil.ReadAll(resp.Body)
          sessionKey := sessionKeyRegex.FindStringSubmatch(string(body))[1]

          resp, _ = client.PostForm(
            "http://192.168.0.1/goform/login?sessionKey=" + sessionKey,
            url.Values{
              "loginUsername": {d.Get("login").(string)},
              "loginPassword": {d.Get("password").(string)},
              "envoyer": {"OK"},
            },
          )
          defer resp.Body.Close()
          if(resp.StatusCode != 302) {
            panic("POST goform/login not 302")
          }
          if(resp.Header["Location"][0] != "http://192.168.0.1/config.html") {
            panic("goform/login location")
          }

          reservations := make(map[string]string)
          resp, _ = client.Get("http://192.168.0.1/reseau-pb1-iplan.html")
          defer resp.Body.Close()
          body, _ = ioutil.ReadAll(resp.Body)
          for _, match := range reservationRegex.FindAllStringSubmatch(string(body), -1) {
            reservations[match[1]] = match[2]
          }

          session := &session{client, sessionKey, reservations} // @todo Why use a pointer here?

          return session, nil
        },
      }
    },
  })
}
