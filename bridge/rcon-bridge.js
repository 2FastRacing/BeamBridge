const dgram = require('dgram');
const net = require('net');

const MAGIC = Buffer.from([0xff, 0xff, 0xff, 0xff]);
const PORT = 28016;
const TCP_PORT = 29292; // Bridge <-> wrappers

const server = dgram.createSocket('udp4');
const wrappers = new Set();

// Accept wrapper connections
const tcpServer = net.createServer((socket) => {
    console.log(`[RCON Bridge] Wrapper connected: ${socket.remoteAddress}`);
    wrappers.add(socket);

    socket.on('close', () => {
        wrappers.delete(socket);
        console.log(`[RCON Bridge] Wrapper disconnected.`);
    });

    socket.on('error', () => {
        wrappers.delete(socket);
    });
});

tcpServer.listen(TCP_PORT, () => {
    console.log(`[RCON Bridge] TCP wrapper port: ${TCP_PORT}`);
});

server.on('message', (msg, rinfo) => {
    if (!msg.slice(0, 4).equals(MAGIC)) return;

    const payload = msg.slice(4).toString('utf8').trim();
    const [prefix, password, ...commandParts] = payload.split(' ');
    const command = commandParts.join(' ').replace(/\0/g, '').trim();

    if (!command) return;

    console.log(`[RCON Bridge] ${rinfo.address}:${rinfo.port} > ${command}`);

    // Broadcast command to all wrappers
    wrappers.forEach((sock) => {
        try {
            sock.write(command + '\n');
        } catch (e) {
            console.warn("Failed to write to wrapper:", e.message);
        }
    });
});

server.bind(PORT, () => {
    console.log(`[RCON Bridge] Listening for RCON UDP on ${PORT}`);
});
