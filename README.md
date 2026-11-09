# 26.2-Eagler

Browser client hosting and Minecraft server stack using Paper, Velocity, and the official EaglerXServer Velocity plugin.

## Network layout

- Browser website (HTTP): `0.0.0.0:8081`
- Eaglercraft WebSocket bridge: `0.0.0.0:8082`
- Java Edition Velocity proxy: `0.0.0.0:25565`
- Private Paper backend: `127.0.0.1:25566`

This keeps the same user-facing flow as the reference EaglercraftX-Server project: open the website to load the browser entry page, then the client connects to the WebSocket endpoint. This repository keeps its existing Velocity + Paper architecture rather than replacing it with the older BungeeCord/Waterfall stack.

## Start the server

Run from the repository root in the Codespace or Linux host:

```bash
git pull origin main
chmod +x scripts/*.sh
./scripts/bridge-start.sh
```

The bridge startup script installs EaglerXServer, generates its configuration on first run, configures the WebSocket listener on port 8082, then starts Paper, Velocity, and the static website host.

For later starts, use the same command. To stop the services:

```bash
./scripts/stop.sh
```

## Website and client files

The static website is served from the `web/` directory on port **8081**.

- Entry page: `web/index.html`
- Client entry expected at: `web/client/index.html`
- Client assets: keep them in their original relative folder structure under `web/client/`

The repository currently includes the website entry page, not a compiled game client distribution. Add your own compiled browser-client files under `web/client/` before expecting the Launch Client link to open the game. The static host does not compile or generate the client.

## Codespaces port forwarding

Open the **Ports** tab and forward:

- **8081** — website; open its HTTPS URL in your browser
- **8082** — Eaglercraft WebSocket; use its WSS URL in the browser client's Direct Connect field
- **25565** — optional Java Edition access

Do not expose port **25566**; it is the private Paper backend.

## Compatibility

EaglerXServer 1.1.1 documents support for EaglercraftX 1.8, Eaglercraft 1.12.2, and Eaglercraft 1.5.2 clients. Compatibility with a custom client labelled **26.2 / Zeus** is not confirmed. A working website and open WebSocket port do not guarantee that an unsupported client protocol can join.

## Configuration and logs

- Velocity template: `proxy/velocity.toml.example`
- Runtime Velocity config: `proxy/velocity.toml` (generated locally and ignored by Git)
- EaglerXServer config: `proxy/plugins/eaglerxserver/`
- Website log: `web/web-console.log`
- Velocity log: `proxy/velocity-console.log`
- Paper log: `server/paper-console.log`

The EaglerXServer installer verifies the downloaded release JAR with SHA-256.
