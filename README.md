# Rust Server Container

A production-ready Docker container for running Rust game servers with support for Oxide and Carbon frameworks.

## Features

- **Framework Support**
  - Oxide/uMod
  - Carbon
  - Automatic framework updates
  - Clean framework switching

- **Extensions**
  - ChaosCode
  - Discord Integration
  - RustEdit
  - Automatic extension management

- **Server Management**
  - Automatic Steam updates
  - RCON support
  - Clean console output
  - Proper log management
  - Resource-efficient operation

## Building the Container

### Development Build
```bash
# Build from the repository root
docker build -t rust-dev:latest -f Dockerfile .

# Run locally
docker run -it --rm \
  -p 28015:28015 \
  -p 28016:28016 \
  -p 28017:28017 \
  -e FRAMEWORK=oxide \
  -e FRAMEWORK_UPDATE=1 \
  rust-dev:latest
```

### Production Build
```bash
# Build from the repository root
docker build -t ghcr.io/oaklydokely/rust-prod:latest -f Dockerfile .

# Push to GitHub Container Registry
docker push ghcr.io/oaklydokely/rust-prod:latest
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FRAMEWORK` | Server framework (oxide/carbon) | none |
| `FRAMEWORK_UPDATE` | Auto-update framework (0/1) | 0 |
| `CHAOS_EXT` | Install ChaosCode extension (0/1) | 0 |
| `DISCORD_EXT` | Install Discord extension (0/1) | 0 |
| `RUSTEDIT_EXT` | Install RustEdit extension (0/1) | 0 |

## Ports

| Port | Description |
|------|-------------|
| 28015 | Game server port |
| 28016 | RCON port |
| 28017 | Query port |

## Directory Structure

```
rust-container/
├── Dockerfile          # Container definition
├── entrypoint.sh       # Server startup script
├── install.sh         # SteamCMD installation
├── wrapper.js         # RCON and process management
└── README.md          # This file
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
