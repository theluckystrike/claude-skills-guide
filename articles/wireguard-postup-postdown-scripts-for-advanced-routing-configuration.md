---
layout: default
title: "WireGuard PostUp PostDown Scripts: Routing Guide"
description: "WireGuard PostUp PostDown Scripts: Routing Guide. Practical guide with working examples for developers."
date: 2026-03-17
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /wireguard-postup-postdown-scripts-for-advanced-routing-configuration/
categories: [security, guides]
tags: [wireguard, vpn-scripts, postup-postdown, routing, firewall, network-configuration]
score: 7
reviewed: true
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---


WireGuard's `PostUp` and `PostDown` directives are powerful features that allow you to execute shell commands automatically when your VPN tunnel is established or torn down. These scripts enable advanced routing configurations, automated firewall rule management, and dynamic network setup that responds to your VPN connection state.

## Understanding PostUp and PostDown

In your WireGuard configuration file (`wg0.conf`), the `PostUp` and `PostDown` options let you define commands that run after the interface is brought up or down, respectively. This automation is essential for complex network topologies where you need to configure routes, DNS servers, or firewall rules dynamically.

The commands in `PostUp` run once after the WireGuard interface is successfully created and configured. The commands in `PostDown` run just before the interface is destroyed. WireGuard processes multiple `PostUp` or `PostDown` lines in order, which lets you chain independent commands without combining them into a single shell invocation.

```ini
[Interface]
PrivateKey = <your-private-key>
Address = 10.0.0.2/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT

[Peer]
PublicKey = <peer-public-key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
```

## How wg-quick Processes These Directives

When you run `wg-quick up wg0`, it reads the `[Interface]` section and executes each `PostUp` line as a shell command via `/bin/sh -c`. The variable `%i` is substituted with the interface name, which is useful for writing reusable scripts:

```ini
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
```

Using `%i` makes your configuration portable. If you rename the interface from `wg0` to `wg-prod`, you don't need to update the PostUp/PostDown lines.

## PostUp vs PreUp and PostDown vs PreDown

WireGuard actually supports four hook points: `PreUp`, `PostUp`, `PreDown`, and `PostDown`. Understanding when each fires helps you place commands correctly:

| Hook | When It Runs | Common Use |
|------|-------------|-----------|
| PreUp | Before the interface is created | Load kernel modules, validate prerequisites |
| PostUp | After interface is up and routes applied | Add firewall rules, set DNS, add custom routes |
| PreDown | Before the interface is taken down | Notify services, flush connections |
| PostDown | After the interface is destroyed | Remove firewall rules, restore DNS, clean up routes |

Most configurations only need `PostUp` and `PostDown`. Use `PreDown` when you need to cleanly terminate connections before the tunnel disappears, such as notifying a load balancer to drain the node.

## Basic Firewall Configuration

One of the most common uses for PostUp/PostDown is managing iptables rules. This ensures your firewall adapts to your VPN connection automatically.

## Allowing Forward Traffic

```ini
[Interface]
Address = 10.0.0.2/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

This configuration enables IP forwarding through your VPN interface and sets up NAT for outgoing traffic. The MASQUERADE rule rewrites the source IP of forwarded packets to match the server's outbound interface (`eth0`), which is necessary for routing client traffic to the internet through the VPN server.

Make sure IP forwarding is enabled at the kernel level as well. Set this in `/etc/sysctl.conf`:

```ini
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Apply the change immediately with `sysctl -p /etc/sysctl.conf`. Without this setting, the iptables FORWARD rules will have no effect because the kernel will not route packets between interfaces regardless of firewall policy.

## Stateful Connection Tracking

For a more secure setup, restrict forwarding to established connections rather than accepting all forwarded traffic:

```ini
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -F FORWARD
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

The `conntrack` module allows return traffic for connections initiated through the VPN while blocking uninitiated inbound connections on the forwarding chain.

## DNS Configuration Automation

You can automatically change your DNS servers when the VPN connects, ensuring all DNS queries go through your VPN's DNS resolver.

```ini
[Interface]
Address = 10.0.0.2/24
PostUp = resolvectl dns wg0 10.0.0.1 && resolvectl domain wg0 ~.
PostDown = resolvectl revert wg0

[Peer]
...
```

The `~.` domain suffix tells systemd-resolved to route all DNS queries through this interface by default, the tilde prefix means "all domains" and the dot represents the DNS search root. This is the correct way to set up full-tunnel DNS routing on modern Ubuntu and Fedora systems using systemd-resolved.

## DNS Leak Prevention

A common misconfiguration causes DNS queries to bypass the VPN even when all other traffic routes through it. To prevent DNS leaks on systems using resolv.conf directly:

```ini
PostUp = cp /etc/resolv.conf /etc/resolv.conf.backup
PostUp = echo "nameserver 10.0.0.1" > /etc/resolv.conf
PostUp = echo "nameserver 10.0.0.2" >> /etc/resolv.conf
PostDown = cp /etc/resolv.conf.backup /etc/resolv.conf
PostDown = rm -f /etc/resolv.conf.backup
```

This approach is less solid than using `resolvectl` because it overwrites the file rather than managing per-interface DNS configuration. Prefer `resolvectl` on systems where it is available.

On macOS with WireGuard-Go or Wireguard app:

```ini
PostUp = networksetup -setdnsservers Wi-Fi 10.0.0.1
PostDown = networksetup -setdnsservers Wi-Fi "Empty"
```

Replace `Wi-Fi` with your actual interface name as shown in System Preferences or via `networksetup -listallnetworkservices`.

## Split Tunneling with Custom Routes

PostUp scripts enable sophisticated split tunneling by adding specific routes only when the VPN is active.

```ini
[Interface]
Address = 10.0.0.2/24
PostUp = ip route add 192.168.50.0/24 via 10.0.0.1 dev wg0
PostUp = ip route add 10.8.0.0/16 via 10.0.0.1 dev wg0
PostDown = ip route del 192.168.50.0/24 via 10.0.0.1 dev wg0
PostDown = ip route del 10.8.0.0/16 via 10.0.0.1 dev wg0
```

This routes specific private network ranges through the VPN while keeping other traffic on your default connection.

## Policy-Based Routing with Route Tables

For more sophisticated split tunneling that avoids conflicts with the main routing table, use a separate routing table:

```ini
PostUp = ip rule add from 10.0.0.0/24 table 100
PostUp = ip route add default via 10.0.0.1 dev wg0 table 100
PostUp = ip route add 192.168.1.0/24 dev eth0 table 100
PostDown = ip rule del from 10.0.0.0/24 table 100
PostDown = ip route flush table 100
```

This creates a routing policy that applies only to traffic originating from the VPN subnet. All traffic from `10.0.0.0/24` uses table 100, which routes by default through the VPN but keeps local subnet traffic on the physical interface. Traffic from other addresses continues to use the main routing table unaffected.

## Source-Based Routing for Multi-WAN

If your server has multiple WAN interfaces and you want VPN clients to exit through a specific one:

```ini
PostUp = ip rule add from 10.0.0.0/24 lookup 200 priority 100
PostUp = ip route add default via 203.0.113.1 dev eth1 table 200
PostUp = ip route add 10.0.0.0/24 dev wg0 table 200
PostDown = ip rule del from 10.0.0.0/24 lookup 200 priority 100
PostDown = ip route flush table 200
```

Here, all VPN client traffic exits through `eth1` (your secondary WAN) rather than the default gateway on `eth0`. This is useful for separating VPN traffic from other server traffic for billing, bandwidth monitoring, or geographic routing purposes.

## Kill Switch Implementation

A VPN kill switch prevents data leaks by blocking all traffic when the VPN disconnects unexpectedly.

```ini
[Interface]
Address = 10.0.0.2/24
PostUp = iptables -I OUTPUT ! -o wg0 -j DROP
PostDown = iptables -D OUTPUT ! -o wg0 -j DROP
```

This iptables rule drops all outgoing traffic that doesn't go through the wg0 interface when the VPN is active. Be aware that this also blocks traffic to local services. A more practical kill switch allows local network and loopback traffic:

```ini
PostUp = iptables -I OUTPUT -o lo -j ACCEPT
PostUp = iptables -I OUTPUT -d 192.168.0.0/16 -j ACCEPT
PostUp = iptables -I OUTPUT -d 10.0.0.0/8 -j ACCEPT
PostUp = iptables -I OUTPUT ! -o wg0 -j DROP
PostDown = iptables -D OUTPUT -o lo -j ACCEPT
PostDown = iptables -D OUTPUT -d 192.168.0.0/16 -j ACCEPT
PostDown = iptables -D OUTPUT -d 10.0.0.0/8 -j ACCEPT
PostDown = iptables -D OUTPUT ! -o wg0 -j DROP
```

The ordering matters here, iptables evaluates rules in chain order, and `-I` inserts at the top of the chain. The DROP rule is inserted last, meaning the ACCEPT rules above it take precedence for local traffic. If you use `-A` (append) instead of `-I` (insert), the order is wrong depending on existing rules.

## Kill Switch with nftables

For systems using nftables, a kill switch is expressed as a set of named rules that are easier to manage atomically:

```ini
PostUp = nft add table inet wg_killswitch
PostUp = nft add chain inet wg_killswitch output { type filter hook output priority 0 \; policy drop \; }
PostUp = nft add rule inet wg_killswitch output oif lo accept
PostUp = nft add rule inet wg_killswitch output oif wg0 accept
PostUp = nft add rule inet wg_killswitch output ip daddr 192.168.0.0/16 accept
PostDown = nft delete table inet wg_killswitch
```

The `PostDown` command deletes the entire table and all its chains and rules in a single operation, which is cleaner than tracking individual rules.

## WireGuard with NFTables

For systems using nftables instead of iptables, the syntax is similar but uses the nft command.

```ini
[Interface]
Address = 10.0.0.2/24
PostUp = nft add rule ip filter FORWARD iif wg0 counter accept
PostUp = nft add rule ip filter FORWARD oif wg0 counter accept
PostUp = nft add rule ip nat postrouting oif eth0 masquerade
PostDown = nft delete rule ip filter FORWARD iif wg0 counter accept
PostDown = nft delete rule ip filter FORWARD oif wg0 counter accept
PostDown = nft delete rule ip nat postrouting oif eth0 masquerade
```

One limitation with inline `nft add rule` commands in PostUp is that deleting rules in PostDown requires knowing their handle numbers, which are assigned dynamically. A more reliable approach is to use a separate nftables configuration file:

```ini
PostUp = nft -f /etc/wireguard/wg0-nft.conf
PostDown = nft delete table ip wg0_rules
```

With the corresponding `/etc/wireguard/wg0-nft.conf`:

```nft
table ip wg0_rules {
 chain forward {
 type filter hook forward priority 0;
 iif "wg0" counter accept
 oif "wg0" counter accept
 }
 chain postrouting {
 type nat hook postrouting priority 100;
 oif "eth0" masquerade
 }
}
```

This approach is more maintainable and avoids the handle-number lookup problem.

## Advanced: IPv6 Support

Managing both IPv4 and IPv6 requires additional rules.

```ini
[Interface]
Address = 10.0.0.2/24, fd00::2/64
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = ip6tables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = ip6tables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Note that NAT masquerade for IPv6 requires the `ip6tables_nat` module and a kernel with IPv6 NAT support. Many deployments prefer to use native IPv6 addressing rather than NAT. If your server has a routable IPv6 prefix allocated to it, you can assign addresses from that prefix to clients directly, avoiding NAT entirely:

```ini
Address = 10.0.0.1/24, 2001:db8:1::/48
PostUp = ip6tables -A FORWARD -i wg0 -j ACCEPT
PostUp = ip6tables -A FORWARD -o wg0 -j ACCEPT
PostDown = ip6tables -D FORWARD -i wg0 -j ACCEPT
PostDown = ip6tables -D FORWARD -o wg0 -j ACCEPT
```

Peers would receive addresses like `2001:db8:1::2/48` and route natively without masquerade.

## Multiple Peers with Different Rules

When managing multiple WireGuard peers, you can use environment variables to identify which peer connected.

```ini
Home Network Peer
[Peer]
PublicKey = <home-peer-key>
AllowedIPs = 192.168.1.0/24
PostUp = ip route add 192.168.1.0/24 via 10.0.0.1 dev wg0
PostDown = ip route del 192.168.1.0/24 via 10.0.0.1 dev wg0

Office Network Peer
[Peer]
PublicKey = <office-peer-key>
AllowedIPs = 10.20.0.0/16
PostUp = ip route add 10.20.0.0/16 via 10.0.0.2 dev wg0
PostDown = ip route del 10.20.0.0/16 via 10.0.0.2 dev wg0
```

For more complex multi-peer setups, offload the logic to a script:

```ini
PostUp = /etc/wireguard/postup.sh %i
PostDown = /etc/wireguard/postdown.sh %i
```

With `/etc/wireguard/postup.sh`:

```bash
#!/bin/bash
INTERFACE=$1

case $INTERFACE in
 wg0)
 iptables -A FORWARD -i wg0 -j ACCEPT
 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
 ip route add 192.168.1.0/24 via 10.0.0.1 dev wg0
 ;;
 wg1)
 iptables -A FORWARD -i wg1 -j ACCEPT
 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
 ip route add 10.20.0.0/16 via 10.1.0.1 dev wg1
 ;;
esac

echo "$(date): PostUp for $INTERFACE completed" >> /var/log/wireguard.log
```

Make the script executable: `chmod +x /etc/wireguard/postup.sh`. Always use absolute paths in PostUp/PostDown lines, both for the script itself and for any commands inside the script, to avoid failures due to PATH differences when running as root.

## Comparison: Inline Commands vs External Scripts

Choosing between inline PostUp commands and external script files depends on your configuration's complexity:

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| Inline commands | Simple, self-contained, easy to read | Hard to share logic, difficult to debug, no branching | Simple setups, 1-3 rules |
| External script | Reusable, testable, logging support, full bash logic | Extra file to manage, permissions to set | Complex setups, multiple interfaces |
| Here-doc in PostUp | No extra file, supports multiline | Unusual syntax, harder to read | Medium complexity |

For production deployments, external scripts are almost always preferable. They can be version-controlled, tested independently, and modified without editing the WireGuard configuration directly.

## Troubleshooting PostUp/PostDown Issues

When your PostUp or PostDown commands fail, WireGuard may not provide detailed error messages. Here are debugging strategies:

Test commands manually: Run your PostUp commands in a terminal to verify they work before adding them to the config.

Use absolute paths: Always use full paths like `/usr/sbin/iptables` instead of just `iptables`. When wg-quick executes commands, the PATH may not include all the directories in your interactive shell's PATH.

Redirect output to logs: Add logging to your scripts.

```ini
PostUp = /bin/sh -c 'iptables -A FORWARD -i wg0 -j ACCEPT >> /var/log/wg-setup.log 2>&1'
```

Check WireGuard logs:

```bash
sudo wg show
sudo journalctl -u wg-quick@wg0 -f
```

Handle rule duplication on restart: If wg-quick crashes or the interface goes down without PostDown running, your PostUp rules may already exist when you bring the interface back up, causing `iptables` to error on duplicate rule insertion. Use `-C` to check before adding:

```bash
#!/bin/bash
iptables -C FORWARD -i wg0 -j ACCEPT 2>/dev/null || iptables -A FORWARD -i wg0 -j ACCEPT
```

Verify the rule took effect:

```bash
sudo iptables -L FORWARD -n -v
sudo iptables -t nat -L POSTROUTING -n -v
sudo ip route show table all
```

Common failure modes:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Tunnel up but no internet | Missing MASQUERADE rule or IP forwarding disabled | Check sysctl, verify POSTROUTING chain |
| DNS still leaks | DNS override not applied or wrong interface | Verify with `resolvectl status wg0` |
| Kill switch blocks local traffic | Missing ACCEPT rules for lo/LAN | Add ACCEPT rules before DROP rule |
| PostDown fails silently | Trying to delete a rule that doesn't exist | Use `-C` checks or `2>/dev/null` |
| Rules duplicate on restart | PostDown didn't run before PostUp | Use idempotent rule checks |

## Best Practices

Always clean up: Ensure your PostDown commands exactly reverse what PostUp does. Orphaned iptables rules after a VPN session ends create security vulnerabilities and can cause hard-to-diagnose connectivity issues.

Use iptables-save/iptables-restore for complex rule sets to avoid rule duplication on restarts. Instead of individual add/delete commands, save a clean ruleset to a file and restore from it:

```ini
PostUp = iptables-restore < /etc/wireguard/wg0-iptables.rules
PostDown = iptables-restore < /etc/wireguard/wg0-iptables-clean.rules
```

Test thoroughly: Verify your configuration works after system reboots and network changes. Behavior can differ between initial boot and restart of the wg-quick service, particularly when systemd unit ordering is involved.

Consider failures: Design your scripts to handle cases where some commands might fail. Use `|| true` to allow non-critical commands to fail without aborting the entire PostUp sequence, and use explicit error handling for critical rules.

Prefer named tables and chains: When using nftables, creating named tables for WireGuard rules makes PostDown trivial, a single `nft delete table` removes everything cleanly.

Document your rules: Add comments to your PostUp script explaining why each rule exists. Firewall configurations become difficult to maintain when the reasoning is not preserved alongside the commands.

## Conclusion

WireGuard's PostUp and PostDown directives transform a simple VPN tunnel into a fully programmable network solution. By automating routing, firewall rules, and DNS configuration, you can create sophisticated VPN setups that adapt dynamically to connection states while maintaining security and privacy.

Whether you need a simple kill switch or complex multi-peer routing with policy-based forwarding tables, these hooks provide the flexibility to customize your WireGuard deployment precisely. The key is to treat PostUp and PostDown as complementary pairs, every rule added on up must be removed on down, and to move beyond inline commands to external scripts as your configuration grows in complexity. With good logging, idempotent rule checks, and thorough testing across reboot scenarios, a WireGuard configuration built on solid PostUp/PostDown practices will be both reliable and maintainable over time.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=wireguard-postup-postdown-scripts-for-advanced-routing-configuration)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [WireGuard Performance Tuning for Large File Transfer Optimization Guide](/wireguard-performance-tuning-large-file-transfer-optimization-guide/)
- [Chrome Block Phishing Extension: A Developer Guide to.](/chrome-block-phishing-extension/)
- [Chrome Check Link Safety: Developer Tools and Techniques](/chrome-check-link-safety/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)




