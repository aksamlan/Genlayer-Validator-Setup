# 🚀 GenLayer Validator Automated Setup - First Steps

**Congratulations!** You now have a complete, professional GenLayer validator setup repository.

## 📦 What You Have

This repository includes:
- ✅ **One-command installation** - Interactive and automated modes
- ✅ **Docker & Binary support** - Choose your preferred method  
- ✅ **Built-in monitoring** - Grafana Alloy integration
- ✅ **Easy upgrades** - Minimal downtime upgrade scripts
- ✅ **Health checks** - Automated diagnostics
- ✅ **Complete documentation** - Quick start to advanced configs
- ✅ **Production-ready** - Security, logging, resource limits

## 🎯 Quick Start (3 Commands)

```bash
# 1. Make scripts executable (if needed)
chmod +x install.sh scripts/*.sh scripts/utils/*.sh

# 2. Run installation
./install.sh --interactive

# 3. Start your validator
cd node-docker && docker compose --profile node up -d
```

**That's it!** Your validator is running.

## 📚 Essential Files

| File | Purpose |
|------|---------|
| `README.md` | Complete documentation (START HERE) |
| `docs/QUICK_START.md` | 30-minute setup guide |
| `install.sh` | Main installation script |
| `Makefile` | Convenient command shortcuts |
| `STRUCTURE.md` | Project structure explanation |

## 🛠️ Common Commands

Using Makefile (recommended):
```bash
make install          # Run installation
make start            # Start validator
make stop             # Stop validator
make logs             # View logs
make health           # Health check
make monitor          # Setup monitoring
make upgrade          # Upgrade node
make help             # Show all commands
```

Direct commands:
```bash
# Installation
./install.sh --interactive

# Health check
./scripts/utils/health-check.sh

# Monitoring setup
./scripts/setup-monitoring.sh

# Upgrade
./scripts/upgrade.sh --version v0.4.6 --backup
```

## 📖 Documentation Guide

**New to GenLayer validators?**
→ Start with `docs/QUICK_START.md`

**Need configuration help?**
→ Check `docs/CONFIGURATION_EXAMPLES.md`

**Understanding the project?**
→ Read `STRUCTURE.md`

**Troubleshooting issues?**
→ See "Troubleshooting" section in `README.md`

## 🔧 Before You Deploy

1. **Set file permissions** (if cloning from Git):
   ```bash
   chmod +x install.sh
   chmod +x scripts/*.sh
   chmod +x scripts/utils/*.sh
   ```

2. **Review security**:
   - Use strong passwords in `.env`
   - Never commit `.env` to Git (already in `.gitignore`)
   - Backup your operator key regularly
   - Keep your owner wallet offline (cold storage)

3. **Get prerequisites**:
   - 42,000+ GEN tokens for staking
   - LLM provider API key (Heurist, Anthropic, OpenAI, etc.)
   - ZKSync RPC endpoints (ask in Discord #testnet-asimov)

4. **Plan your setup**:
   - Single validator: Use default ports
   - Multiple validators: See `docs/CONFIGURATION_EXAMPLES.md`
   - Production: Review production configs in examples

## 🌐 Cloud Deployment

This setup works on:
- ✅ AWS EC2 (t3.xlarge or larger)
- ✅ Google Cloud (n2-standard-4)
- ✅ Azure (Standard_D4s_v3)
- ✅ DigitalOcean (8GB/4vCPU droplet)
- ✅ Any VPS with Docker support

See cloud-specific examples in `docs/CONFIGURATION_EXAMPLES.md`

## 🔍 Project Structure

```
genlayer-validator-setup/
├── README.md                    # Main docs (comprehensive)
├── install.sh                   # Installation script ⭐
├── Makefile                     # Command shortcuts
├── scripts/
│   ├── upgrade.sh              # Upgrade automation
│   ├── setup-monitoring.sh     # Monitoring setup
│   ├── templates/              # Config templates
│   └── utils/                  # Helper scripts
├── docs/
│   ├── QUICK_START.md          # Beginner guide
│   └── CONFIGURATION_EXAMPLES.md  # Config examples
└── examples/
    └── genlayer-validator.service  # Systemd service
```

## 🎓 Learning Path

**Day 1**: Quick Start
1. Read `docs/QUICK_START.md`
2. Run `./install.sh --interactive`
3. Start validator
4. Verify it's working

**Day 2**: Configuration
1. Review `docs/CONFIGURATION_EXAMPLES.md`
2. Optimize your config for production
3. Set up monitoring
4. Test backup/restore

**Day 3**: Operations
1. Practice health checks
2. Test upgrade procedure (on testnet)
3. Set up systemd service (optional)
4. Join Discord community

## 🤝 Community Resources

- **Discord**: #testnet-asimov (ask questions, get RPC URLs)
- **Docs**: https://docs.genlayer.com (official documentation)
- **GitHub**: Report bugs, request features
- **Updates**: Follow announcements for new versions

## ⚠️ Important Reminders

1. **Never commit sensitive data**:
   - `.env` files are in `.gitignore` - keep them local
   - Never share private keys or passwords
   - Backup keystores securely offline

2. **Keep software updated**:
   - Watch for new node versions
   - Use `./scripts/upgrade.sh` for updates
   - Test upgrades on testnet first

3. **Monitor your validator**:
   - Set up centralized monitoring
   - Check logs regularly
   - Run health checks periodically

4. **Secure your stake**:
   - Use separate owner (cold) and operator (hot) wallets
   - Keep owner wallet offline
   - Backup operator key to secure location

## 🚀 Next Steps

1. **Initialize Your Setup**:
   ```bash
   ./install.sh --interactive
   ```

2. **Read the Full Documentation**:
   ```bash
   cat README.md  # Or open in your favorite editor
   ```

3. **Join Discord**:
   - Get RPC endpoints
   - Ask questions
   - Stay updated

4. **Start Validating**:
   ```bash
   cd node-docker
   docker compose --profile node up -d
   docker logs -f genlayer-node
   ```

## 💡 Pro Tips

- Use `make help` to see all available commands
- Run `make health` regularly to check validator status
- Set up monitoring early to track performance
- Join Discord early to stay updated
- Bookmark the official docs

## 🎉 You're Ready!

This repository gives you everything needed to run a professional GenLayer validator.

**Questions?** Check the docs or ask in Discord!

**Issues?** Open a GitHub issue with details.

**Success?** Share your experience with the community!

---

**Made with ❤️ for the GenLayer Community**

Happy Validating! 🚀
