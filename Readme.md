# 🛡️ Filtora - Filter your aura

A powerful and elegant tool to filter and block distracting websites on your Mac. Filtora works at both the DNS and network level to ensure your digital space stays clean and focused, helping you maintain a positive digital aura.

## ✨ Features

- Blocks distracting websites at both DNS and network level
- Works with both IPv4 and IPv6 addresses
- Blocks all protocols (HTTP, HTTPS, etc.)
- Beautiful and intuitive user interface
- Includes backup and restore functionality
- Customizable filtering rules
- Support for wildcards and subdomains

## 📋 Prerequisites

- macOS operating system
- Administrator access (for running with sudo)
- Basic terminal knowledge
- Network interface access

## 🚀 Installation

1. Download or clone this repository:
   ```bash
   git clone [repository-url]
   cd website-blocker
   ```

2. Make the scripts executable:
   ```bash
   chmod +x blocker.sh unblocker.sh
   ```

3. Verify the scripts are executable:
   ```bash
   ls -l blocker.sh unblocker.sh
   ```

## ⚙️ Configuration

### Basic Configuration

1. Open `list.txt` in a text editor:
   ```bash
   nano list.txt
   ```

2. Add the websites you want to block, one per line:
   ```
   youtube.com
   tiktok.com
   example.com
   ```

### Advanced Configuration

#### Adding Subdomains
Add specific subdomains to block:
```
www.youtube.com
m.youtube.com
api.youtube.com
```

#### Using Wildcards
For broader blocking, use wildcards:
```
*.youtube.com
*.tiktok.com
```

#### Blocking Specific Paths
Add specific paths to block:
```
youtube.com/watch
tiktok.com/@username
```

## 🔒 Using the Blocker

### Basic Usage

#### To Block Websites:
```bash
sudo ./blocker.sh
```

#### To Unblock Websites:
```bash
sudo ./unblocker.sh
```

### Advanced Usage

#### View Current Blocked IPs:
```bash
# View IPv4 blocked addresses
sudo pfctl -t adult_sites -T show

# View IPv6 blocked addresses
sudo pfctl -t adult_sites6 -T show
```

#### Check PF Status:
```bash
# Check if PF is enabled
sudo pfctl -s info

# View current PF rules
sudo pfctl -s rules
```

#### Manual DNS Cache Flush:
```bash
# Flush DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

## 🔧 Customization

### Modifying Blocking Rules

1. Edit `blocker.sh` to customize blocking behavior:
   ```bash
   nano blocker.sh
   ```

2. Common modifications:
   - Change the interface name (default: auto-detected)
   - Modify DNS resolution timeout
   - Add custom PF rules
   - Change backup file location

### Adding Custom PF Rules

Add custom rules to the PF configuration section in `blocker.sh`:
```bash
# Example: Block specific ports
block in quick on $INTERFACE proto tcp from any to <adult_sites> port {80,443}
```

### Creating Backup Rules

The script automatically creates backups, but you can manually backup:
```bash
# Backup hosts file
sudo cp /etc/hosts /etc/hosts.backup

# Backup PF rules
sudo pfctl -s rules > pf_rules.backup
```

## 🔍 Verifying the Block

### Basic Verification
1. Try accessing blocked websites in your browser
2. Check if they're inaccessible
3. Verify in different browsers

### Advanced Verification
```bash
# Check hosts file entries
cat /etc/hosts | grep "0.0.0.0"

# Test DNS resolution
dig blocked-site.com

# Check network connections
sudo lsof -i -n
```

## ⚠️ Important Notes

- Always run the scripts with `sudo`
- The blocker modifies system files:
  - `/etc/hosts`
  - PF firewall rules
  - DNS cache
- Keep backups of original configurations
- Test changes in a controlled environment first

## 🆘 Troubleshooting

### Common Issues

1. Websites still accessible:
   ```bash
   # Run unblocker first
   sudo ./unblocker.sh
   
   # Clear browser cache
   # Chrome: chrome://settings/clearBrowserData
   # Safari: Preferences > Privacy > Manage Website Data
   
   # Run blocker again
   sudo ./blocker.sh
   ```

2. PF not working:
   ```bash
   # Check PF status
   sudo pfctl -s info
   
   # Reload PF rules
   sudo pfctl -f /etc/pf.conf
   ```

3. DNS issues:
   ```bash
   # Flush DNS cache
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   
   # Check DNS resolution
   dig example.com
   ```

### Advanced Troubleshooting

1. Check system logs:
   ```bash
   # View system logs
   log show --predicate 'process == "pfctl"'
   ```

2. Monitor network traffic:
   ```bash
   # Install tcpdump if needed
   brew install tcpdump
   
   # Monitor traffic to blocked sites
   sudo tcpdump -i en0 host youtube.com
   ```

## 📝 License

This project is open source and available for personal use. Commercial use requires permission.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

### Suggested Improvements
- Add GUI interface
- Create scheduled blocking
- Add whitelist functionality
- Implement category-based blocking
- Add logging and monitoring
