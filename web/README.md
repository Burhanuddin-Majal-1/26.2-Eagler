# Browser client files

This directory is served over HTTP on port **8081** by `scripts/web-start.sh`.

The repository includes a small `index.html` entry page. To make the actual game playable from this page, place your own compiled browser-client distribution in:

```
web/client/index.html
web/client/...
```

Keep the client's JavaScript, asset packs, language files, icons, and other referenced files in their original relative paths. Do not upload only the HTML shell if it depends on separate files.

Open the forwarded HTTPS URL for port 8081 to load this page. The browser client should connect to the separately forwarded WebSocket address for port **8082**.

The static web host does not generate or compile a game client.
