// OpenAI OAuth callbacks are hardcoded to loopback URLs:
//   http://localhost:8080/auth/callback  ("Sign in with ChatGPT (Beta)")
//   http://localhost:1455/auth/callback  ("Codex login (browser)")
//
// OpenClaw binds those listeners on 127.0.0.1 *inside the container*, so a
// browser on Windows cannot reach them: Docker publishes ports on the
// container's eth0 address, never on its loopback interface.
//
// This process runs in a sidecar that shares the gateway's network namespace,
// so 127.0.0.1 here is the same loopback the gateway binds. It listens on the
// container-facing ports published by docker-compose.yml and pipes each
// connection back to the loopback listener, which makes the browser redirect
// work with no manual steps.
import net from "node:net";

const ROUTES = [
  // container-facing port -> gateway loopback port
  { listen: 18080, target: 8080 }, // Sign in with ChatGPT (token sharing)
  { listen: 11455, target: 1455 }, // Codex login (browser)
];

for (const { listen, target } of ROUTES) {
  const server = net.createServer((client) => {
    client.setNoDelay(true);
    const upstream = net.connect({ host: "127.0.0.1", port: target });
    upstream.setNoDelay(true);

    let closed = false;
    const teardown = () => {
      if (closed) return;
      closed = true;
      client.destroy();
      upstream.destroy();
    };

    client.on("error", teardown);
    upstream.on("error", teardown);
    client.on("close", teardown);
    upstream.on("close", teardown);

    client.pipe(upstream).pipe(client);
  });

  server.on("error", (error) => {
    console.error(`[oauth-forward] :${listen} -> 127.0.0.1:${target} failed: ${error.message}`);
  });

  server.listen(listen, "0.0.0.0", () => {
    console.log(`[oauth-forward] :${listen} -> 127.0.0.1:${target} ready`);
  });
}

for (const signal of ["SIGTERM", "SIGINT"]) {
  process.on(signal, () => process.exit(0));
}
