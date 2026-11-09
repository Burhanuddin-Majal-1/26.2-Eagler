# 26.2-Eagler

Eaglercraft web client and Minecraft server stack using Paper, Velocity, and the official EaglerXServer Velocity plugin.

## Network layout

- Eaglercraft WebSocket bridge: `0.0.0.0:8082`
- Java Edition Velocity proxy: `0.0.0.0:25565`
- Private Paper backend: `127.0.0.1:25566`

Keep the Paper backend private. Browser players connect through the EaglerXServer WebSocket listener on port 8082.

## Start the server

Run these commands from the repository root in the Codespace or Linux host:

```bash
git pull origin main
chmod +x scripts/*.sh
./scripts/bridge-start.sh
```

The first run installs the official EaglerXServer 1.1.1 plugin, starts Paper and Velocity to generate the plugin configuration, configures the WebSocket listener on port 8082, then restarts the network.

For later starts, the same command is safe to run again. To stop both servers:

```bash
./scripts/stop.sh
```

Logs:
- `server/paper-console.log`
- `proxy/velocity-console.log`

## Codespaces port forwarding

After startup, open the **Ports** tab in Codespaces and forward port **8082** for browser clients. Forward port **25565** only if Java Edition players also need to join. Do not expose port 25566.

Use the HTTPS/WSS address shown for forwarded port 8082 as the WebSocket address in the Eaglercraft client. If friends need to connect, the forwarded port must be made accessible to them in the Ports tab.

## Important compatibility note

EaglerXServer 1.1.1 officially documents support for EaglercraftX 1.8, Eaglercraft 1.12.2, and Eaglercraft 1.5.2 clients. Compatibility with a custom client labelled **26.2 / Zeus** is not confirmed by the upstream project. The bridge can start successfully while a client with an unsupported protocol still fails to join.

If the bridge starts but the client reports a protocol or handshake error, check the client protocol compatibility before changing the Paper or Velocity ports.

## Configuration

- Velocity template: `proxy/velocity.toml.example`
- Runtime Velocity config: `proxy/velocity.toml` (generated locally and ignored by Git)
- EaglerXServer runtime config: generated under `proxy/plugins/`

The plugin installer verifies the official release JAR using its published SHA-256 digest.
