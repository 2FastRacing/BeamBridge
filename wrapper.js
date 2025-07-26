const net = require('net');
const { spawn } = require('child_process');

const BRIDGE_HOST = '127.0.0.1';
const BRIDGE_PORT = 29292;
const SERVER_NAME = 'Development01';

console.log(`[${SERVER_NAME}] Starting BeamMP Server...`);

const proc = spawn('BeamMP-Server.exe', [], {
    stdio: ['pipe', 'pipe', 'pipe']
});

// Log server stdout (optional)
proc.stdout.on('data', (data) => process.stdout.write(`[${SERVER_NAME}] ${data}`));
proc.stderr.on('data', (data) => process.stderr.write(`[${SERVER_NAME}] [ERR] ${data}`));

// Auto-restart on crash
proc.on('exit', (code) => {
    console.log(`[${SERVER_NAME}] Exited with code ${code}`);
    setTimeout(() => process.exit(1), 3000);
});

// Connect to the RCON bridge
const socket = net.connect(BRIDGE_PORT, BRIDGE_HOST, () => {
    console.log(`[${SERVER_NAME}] Connected to RCON bridge`);
});

// Send received command to BeamMP stdin
socket.on('data', (data) => {
    const command = data.toString().trim();
    console.log(`[${SERVER_NAME}] RCON > ${command}`);
    proc.stdin.write(command + '\n');
});

socket.on('error', (err) => {
    console.error(`[${SERVER_NAME}] Socket error:`, err.message);
});

function connectToBridge(retries = 20) {
    const socket = net.connect(BRIDGE_PORT, BRIDGE_HOST);

    socket.on('connect', () => {
        console.log(`[${SERVER_NAME}] Connected to RCON bridge`);
    });

    socket.on('error', (err) => {
        console.error(`[${SERVER_NAME}] Socket error: ${err.message}`);
        if (retries > 0) {
            console.log(`[${SERVER_NAME}] Retrying in 3s... (${retries} attempts left)`);
            setTimeout(() => connectToBridge(retries - 1), 3000);
        }
    });

    socket.on('data', (data) => {
        const command = data.toString().trim();
        console.log(`[${SERVER_NAME}] RCON > ${command}`);
        proc.stdin.write(command + '\n');
    });
}

connectToBridge();