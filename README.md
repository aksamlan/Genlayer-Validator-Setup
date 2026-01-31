# GenLayer Validator Setup - Automated Installation

<div align="center">

![GenLayer Logo](https://github.com/aksamlan/Genlayer-Validator-Explorer/raw/main/public/logo.jpg)

**One-Command Validator Setup for GenLayer Network**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)](https://www.docker.com/)
[![Binary](https://img.shields.io/badge/Binary-Supported-green.svg)](https://github.com/yeagerai/genlayer-node)

[Features](#-features) • [Quick Start](#-quick-start) • [Installation](#-installation) • [Documentation](#-documentation) • [Support](#-support)

</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Installation Methods](#-installation-methods)
  - [Docker Installation](#docker-installation-recommended)
  - [Binary Installation](#binary-installation)
- [Configuration](#-configuration)
- [Validator Setup](#-validator-setup)
- [Monitoring](#-monitoring)
- [Maintenance](#-maintenance)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 About

This repository provides **automated setup scripts** for running a GenLayer validator node. GenLayer is a blockchain network that leverages Large Language Models (LLMs) for executing Intelligent Contracts.

**What this automates:**
- ✅ System requirements verification
- ✅ Dependency installation (Docker, Node.js, Python, GenLayer CLI)
- ✅ Node software download and configuration
- ✅ Validator wallet creation and staking
- ✅ LLM provider configuration
- ✅ Monitoring setup (optional)
- ✅ Zero-downtime upgrades

---

## ✨ Features

### 🚀 One-Command Installation
```bash
./install.sh --method docker --llm-provider heurist
```

### 🎛️ Multiple Installation Methods
- **Docker** (Recommended) - Containerized deployment with docker-compose
- **Binary** - Native Linux binary for advanced users

### 🤖 Interactive Setup Wizard
- Guided configuration with validation
- Smart detection of existing installations
- Automatic system compatibility checks

### 📊 Built-in Monitoring
- Prometheus metrics collection
- Grafana Alloy for log aggregation
- Integration with GenLayer Foundation dashboard

### 🔄 Easy Upgrades
- Minimal-downtime upgrade procedure
- Automatic backup before upgrades
- Version verification and rollback support

### 🛠️ Utility Scripts
- Health check and diagnostics
- Log viewer and analyzer
- Validator status checker

---

## 📦 Prerequisites

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | 64-bit Linux (Ubuntu 20.04+ recommended) |
| **CPU** | 8-core AMD64 |
| **RAM** | 16 GB minimum |
| **Disk** | 128 GB SSD/NVMe |
| **Network** | 100 Mbps |
| **GPU** | Not required (unless running local LLM) |

### Software Requirements

The installation script will check and install these if missing:
- Docker & Docker Compose (for Docker method)
- Python 3 with pip and venv
- Node.js v18+
- Git
- curl, wget, tar

### Tokens Required

You need **at least 42,000 GEN tokens** to become a validator through staking.

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/genlayer-validator-setup.git
cd genlayer-validator-setup
```

### 2. Run the Installation Script

**Interactive Mode (Recommended for first-time users):**
```bash
./install.sh --interactive
```

**Automated Mode (if you know your configuration):**
```bash
./install.sh --method docker --llm-provider heurist --version latest
```

### 3. Follow the Prompts

The script will:
1. ✅ Check your system meets requirements
2. ✅ Install necessary dependencies
3. ✅ Download and configure the node
4. ✅ Help you create or import a validator wallet
5. ✅ Configure your LLM provider
6. ✅ Optionally set up monitoring

### 4. Start Your Validator

**For Docker installations:**
```bash
cd node-docker
docker compose --profile node up -d
```

**For Binary installations:**
```bash
cd node-v0.4.5  # or your version
./bin/genlayernode run -c $(pwd)/configs/node/config.yaml --password 'your-password'
```

---

## 📚 Installation Methods

### Docker Installation (Recommended)

Docker provides the easiest and most reliable way to run a validator node.

**Advantages:**
- ✅ Isolated environment
- ✅ Easy updates
- ✅ Built-in monitoring support
- ✅ No system-wide dependency conflicts

**Installation:**
```bash
./install.sh --method docker --llm-provider heurist
```

**Start the node:**
```bash
cd node-docker
docker compose --profile node up -d
```

**View logs:**
```bash
docker logs -f genlayer-node
```

**Stop the node:**
```bash
docker compose --profile node down
```

---

### Binary Installation

For advanced users who prefer running the node natively.

**Advantages:**
- ✅ Better performance (no containerization overhead)
- ✅ Direct access to binaries
- ✅ Easier debugging

**Installation:**
```bash
./install.sh --method binary --version v0.4.5 --llm-provider anthropic
```

**Start the node:**
```bash
cd node-v0.4.5

# Start WebDriver container
docker compose up -d

# Start the node
./bin/genlayernode run -c $(pwd)/configs/node/config.yaml --password 'your-password'
```

**Tip:** Use `screen` or `tmux` to keep the node running in the background:
```bash
screen -S genlayer-validator
./bin/genlayernode run -c $(pwd)/configs/node/config.yaml --password 'your-password'
# Press Ctrl+A, then D to detach
```

---

## ⚙️ Configuration

### Environment Variables (.env)

The `.env` file contains all runtime configuration:

```bash
# Node Version
NODE_VERSION=v0.4.5

# Authentication
NODE_PASSWORD=your_secure_password

# Ports
NODE_RPC_PORT=9151
NODE_OPS_PORT=9153
WEBDRIVER_PORT=4444

# LLM Provider (choose one)
HEURISTKEY=your_api_key
# ANTHROPICKEY=your_api_key
# OPENAIKEY=your_api_key

# Validator Configuration
GENLAYERNODE_NODE_VALIDATORWALLETADDRESS=0x...
GENLAYERNODE_NODE_OPERATORADDRESS=0x...
```

### Node Configuration (config.yaml)

The main node configuration file is located at `configs/node/config.yaml`:

```yaml
rollup:
  genlayerchainrpcurl: "https://your-zksync-rpc-url"
  genlayerchainwebsocketurl: "wss://your-zksync-ws-url"

consensus:
  contractmainaddress: "0x67fd4aC71530FB220E0B7F90668BAF977B88fF07"
  contractdataaddress: "0xB6E1316E57d47d82FDcEa5002028a554754EF243"

node:
  mode: "validator"
  validatorWalletAddress: "0x..."
  operatorAddress: "0x..."
```

**Important:** You must update the `genlayerchainrpcurl` and `genlayerchainwebsocketurl` with your actual ZKSync RPC endpoints.

### LLM Provider Configuration

GenLayer validators can use various LLM providers:

| Provider | Environment Variable | Get API Key |
|----------|---------------------|-------------|
| **Heurist** | `HEURISTKEY` | [heurist.ai](https://heurist.ai) |
| **Anthropic** | `ANTHROPICKEY` | [console.anthropic.com](https://console.anthropic.com) |
| **OpenAI** | `OPENAIKEY` | [platform.openai.com](https://platform.openai.com) |
| **Comput3** | `COMPUT3KEY` | [comput3.ai](https://comput3.ai) |
| **io.net** | `IOINTELLIGENCE_API_KEY` | [io.net](https://io.net) |

Configure your chosen provider in the `.env` file.

---

## 👛 Validator Setup

### Creating a New Validator Wallet

If you're setting up a validator for the first time:

```bash
genlayer staking wizard
```

The wizard will guide you through:
1. Creating an owner account
2. Selecting the network (testnet-asimov)
3. Verifying your GEN balance (minimum 42,000 GEN)
4. Creating and exporting an operator keystore
5. Staking your tokens
6. Setting your validator identity

**Save these addresses:**
- ✅ Validator Wallet Address (for config)
- ✅ Operator Address (for config)
- ✅ Operator keystore file path (for import)

### Importing Existing Validator

If you already have a validator wallet:

**For Docker installations:**
```bash
# First, start the container
docker compose --profile node up -d

# Then import the key
docker exec -it genlayer-node /app/bin/genlayernode account import \
  --password "your-node-password" \
  --passphrase "your-keystore-passphrase" \
  --path "/path/to/operator-keystore.json" \
  -c /app/configs/node/config.yaml \
  --setup
```

**For Binary installations:**
```bash
cd node-v0.4.5
./bin/genlayernode account import \
  --password "your-node-password" \
  --passphrase "your-keystore-passphrase" \
  --path "/path/to/operator-keystore.json" \
  -c $(pwd)/configs/node/config.yaml \
  --setup
```

### Verifying Your Validator

Check your validator status:
```bash
genlayer staking validator-info --validator 0xYourValidatorWalletAddress
```

Check active validators:
```bash
genlayer staking active-validators
```

### Managing Your Stake

**Add more stake:**
```bash
genlayer staking validator-deposit --amount 1000gen
```

**Exit validator (initiates 7-epoch unbonding):**
```bash
genlayer staking validator-exit --shares 100
```

**Claim after unbonding:**
```bash
genlayer staking validator-claim
```

**Update validator identity:**
```bash
genlayer staking set-identity \
  --validator 0x... \
  --moniker "New Name" \
  --website "https://your-site.com"
```

---

## 📊 Monitoring

### Local Monitoring

Your validator exposes metrics at `http://localhost:9153/metrics`

**Check metrics manually:**
```bash
curl http://localhost:9153/metrics
```

**Health check:**
```bash
curl http://localhost:9153/health
```

**Run automated health check:**
```bash
./scripts/utils/health-check.sh
```

### Centralized Monitoring (GenLayer Foundation)

Contributing your metrics helps the Foundation monitor network health and may positively influence testnet rewards.

**Setup monitoring:**
```bash
./scripts/setup-monitoring.sh
```

You'll need credentials from the GenLayer Foundation (ask in #testnet-asimov Discord).

**Start monitoring services:**
```bash
docker compose --profile monitoring up -d
```

**View monitoring status:**
```bash
docker logs -f genlayer-node-alloy
```

**Access Alloy UI:**
```
http://localhost:12345/targets
```

---

## 🔧 Maintenance

### Viewing Logs

**Docker:**
```bash
# Follow logs in real-time
docker logs -f genlayer-node

# View last 100 lines
docker logs --tail 100 genlayer-node

# View logs from specific time
docker logs --since 30m genlayer-node
```

**Binary:**
```bash
# Logs are in data/node/logs/
tail -f data/node/logs/node.log

# Or if using json logs
cat data/node/logs/node.log | jq
```

### Running Diagnostics

**Docker:**
```bash
docker exec genlayer-node ./bin/genlayernode doctor
```

**Binary:**
```bash
./bin/genlayernode doctor
```

### Upgrading Your Node

Use the upgrade script for minimal-downtime upgrades:

```bash
./scripts/upgrade.sh --version v0.4.6 --backup
```

**For Docker installations:**
- The script automatically pulls the new image
- Stops the old container
- Starts with the new version

**For Binary installations:**
- Downloads and extracts new version
- Copies your configuration and data
- Prepares new installation directory

### Backup and Restore

**Backup your operator key:**
```bash
# Docker
docker exec genlayer-node /app/bin/genlayernode account export \
  --password "your-node-password" \
  --address "your-operator-address" \
  --passphrase "your-backup-passphrase" \
  --path "/app/data/backup.key" \
  -c /app/configs/node/config.yaml

docker cp genlayer-node:/app/data/backup.key ./backup.key

# Binary
./bin/genlayernode account export \
  --password "your-node-password" \
  --address "your-operator-address" \
  --passphrase "your-backup-passphrase" \
  --path "/secure/location/backup.key" \
  -c $(pwd)/configs/node/config.yaml
```

**⚠️ IMPORTANT:** Store your backup securely! Losing your operator key means you'll need to set up a new operator.

**Restore from backup:**
```bash
# Use the same import command as initial setup
./bin/genlayernode account import \
  --password "your-node-password" \
  --passphrase "your-backup-passphrase" \
  --path "/path/to/backup.key" \
  -c $(pwd)/configs/node/config.yaml \
  --setup
```

### Restarting Your Node

**Docker:**
```bash
docker compose --profile node restart
```

**Binary:**
```bash
# Stop the current process (Ctrl+C or kill the process)
# Then start again
./bin/genlayernode run -c $(pwd)/configs/node/config.yaml --password 'your-password'
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Installation Fails

**Problem:** Script fails during dependency installation

**Solution:**
```bash
# Run with sudo if permissions issue
sudo ./install.sh --method docker

# Or install dependencies manually first
sudo apt-get update
sudo apt-get install curl wget git docker.io docker-compose-plugin
```

#### 2. Docker Permission Denied

**Problem:** `permission denied while trying to connect to the Docker daemon`

**Solution:**
```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in for changes to take effect
# Or run:
newgrp docker
```

#### 3. Node Not Starting

**Problem:** Container exits immediately or node crashes

**Solution:**
```bash
# Check logs for specific error
docker logs genlayer-node

# Common causes:
# - Wrong password
# - Incorrect RPC URLs in config.yaml
# - Operator key not imported
# - Insufficient resources

# Verify configuration
docker exec genlayer-node ./bin/genlayernode doctor
```

#### 4. RPC Connection Errors

**Problem:** `failed to connect to ZKSync RPC`

**Solution:**
```bash
# Verify RPC URLs in config.yaml
cat configs/node/config.yaml | grep genlayerchain

# Test connectivity
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  YOUR_RPC_URL
```

#### 5. Metrics Not Showing

**Problem:** Monitoring dashboard shows no data

**Solution:**
```bash
# Check metrics locally
curl http://localhost:9153/metrics

# Check Alloy logs
docker logs genlayer-node-alloy

# Verify .env credentials
cat .env | grep CENTRAL_

# Restart Alloy
docker compose --profile monitoring restart
```

#### 6. Low Disk Space

**Problem:** "no space left on device"

**Solution:**
```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a --volumes

# Remove old logs
rm -rf data/node/logs/*.log.gz

# Consider moving data directory to larger disk
```

#### 7. Memory Issues

**Problem:** Node crashes due to OOM (Out of Memory)

**Solution:**
```bash
# Check memory usage
free -h

# Increase Docker memory limit
# Edit docker-compose.yaml:
services:
  genlayer-node:
    mem_limit: 8g
    mem_reservation: 4g

# Or add swap space
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Getting Help

If you can't resolve the issue:

1. **Check logs:**
   ```bash
   # Full node logs
   docker logs genlayer-node > node-logs.txt
   
   # System info
   ./scripts/utils/health-check.sh > health-check.txt
   ```

2. **Join Discord:** Ask in #testnet-asimov channel
3. **GitHub Issues:** Open an issue with logs attached
4. **Documentation:** Visit [docs.genlayer.com](https://docs.genlayer.com)

---

## ❓ FAQ

### Q: How much GEN do I need to become a validator?
**A:** Minimum 42,000 GEN for self-stake.

### Q: Can I run multiple validators on one machine?
**A:** Yes, but you need to configure different ports for each node and ensure sufficient resources (RAM, CPU).

### Q: Do I need a GPU?
**A:** No, unless you're running LLMs locally. Most validators use cloud LLM providers.

### Q: What happens if my node goes offline?
**A:** Your validator will miss blocks and may receive penalties. Consider using monitoring and alerts.

### Q: Can I change my LLM provider later?
**A:** Yes, just update the API key in `.env` and restart the node.

### Q: How do I check my validator rewards?
**A:** Use: `genlayer staking validator-info --validator YOUR_ADDRESS`

### Q: What's the unbonding period?
**A:** 7 epochs. After exiting, you must wait before claiming your stake.

### Q: Can I run this in the cloud?
**A:** Yes! Works great on AWS EC2, GCP Compute Engine, Azure VMs, or any VPS with the required specs.

### Q: Is there a web UI for managing the validator?
**A:** Currently, management is CLI-based. A web UI may be added in future releases.

### Q: How do I update to a new version?
**A:** Use the upgrade script: `./scripts/upgrade.sh --version NEW_VERSION`

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs

Open an issue with:
- Clear description of the problem
- Steps to reproduce
- System information
- Log outputs

### Suggesting Enhancements

Open an issue tagged with `enhancement`:
- Description of the feature
- Use cases
- Implementation ideas (optional)

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Use shellcheck for bash scripts
- Follow existing formatting
- Add comments for complex logic
- Update documentation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Links

- **GenLayer Website:** [genlayer.com](https://genlayer.com)
- **Documentation:** [docs.genlayer.com](https://docs.genlayer.com)
- **Discord:** [discord.gg/genlayer](https://discord.gg/genlayer)
- **Twitter:** [@GenLayer](https://twitter.com/GenLayer)

---

## 🙏 Acknowledgments

- GenLayer Foundation for the validator software
- Yeager.ai team for development
- Community contributors
- All validators securing the network

---

## ⚠️ Disclaimer

Running a validator involves risks:
- Financial risk from staking
- Technical responsibility for uptime
- Potential for slashing/penalties

Ensure you understand these risks before proceeding. This software is provided "as is" without warranty.

---

<div align="center">

**Happy Validating! 🚀**

If you find this helpful, please ⭐ star the repository!

Made with ❤️ by the HusoNode

</div>
