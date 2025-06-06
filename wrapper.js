#!/usr/bin/env node

// Configuration
const config = {
    rcon: {
        host: process.env.RCON_IP || "localhost",
        port: process.env.RCON_PORT,
        password: process.env.RCON_PASS,
        reconnectInterval: 5000,
        maxReconnectAttempts: 10
    }
};

// Process startup command
let startupCmd = "";
const args = process.argv.splice(process.execArgv.length + 2);
startupCmd = args.join(" ");

if (startupCmd.length < 1) {
    console.log("Error: Please specify a startup command.");
    process.exit(1);
}

// Track seen percentages to reduce spam
const seenPercentage = new Set();
let connectionAttempts = 0;
let exited = false;

// Output filter to reduce spam and handle special messages
function filter(data) {
    const str = data.toString().trim();

    // Handle server startup completion
    if (str === "Server startup complete") {
        console.log(JSON.stringify({ done: "Server startup complete" }));
        return;
    }

    // Filter prefab loading spam
    if (str.startsWith("Loading Prefab Bundle ")) {
        const percentage = str.substr("Loading Prefab Bundle ".length);
        if (seenPercentage.has(percentage)) return;
        seenPercentage.add(percentage);
    }

    console.log(str);
}

// Start the game process
console.log("Starting Rust...");
const { exec } = require("child_process");
const gameProcess = exec(startupCmd);

// Handle process output
gameProcess.stdout.on('data', filter);
gameProcess.stderr.on('data', filter);

// Handle process exit
gameProcess.on('exit', (code) => {
    exited = true;
    if (code) {
        console.log(`Main game process exited with code ${code}`);
    }
});

// Initial command listener before RCON is ready
function initialListener(data) {
    const command = data.toString().trim();
    if (command === 'quit') {
        gameProcess.kill('SIGTERM');
    } else {
        console.log(`Unable to run "${command}" due to RCON not being connected yet.`);
    }
}

// Set up stdin for command input
process.stdin.resume();
process.stdin.setEncoding("utf8");
process.stdin.on('data', initialListener);

// Handle process termination
process.on('SIGTERM', () => {
    console.log("Received SIGTERM, cleaning up...");
    if (gameProcess) gameProcess.kill('SIGTERM');
    process.exit(0);
});

process.on('exit', () => {
    if (exited) return;
    console.log("Received request to stop the process, stopping the game...");
    gameProcess.kill('SIGTERM');
});

// RCON WebSocket connection
let waiting = true;
let ws = null;

function createPacket(command) {
    return JSON.stringify({
        Identifier: -1,
        Message: command,
        Name: "WebRcon"
    });
}

function poll() {
    if (connectionAttempts >= config.rcon.maxReconnectAttempts) {
        console.log("Maximum RCON connection attempts reached. Exiting...");
        process.exit(1);
    }

    const WebSocket = require("ws");
    const wsUrl = `ws://${config.rcon.host}:${config.rcon.port}/${config.rcon.password}`;
    
    try {
        if (connectionAttempts === 0) {
            console.log("Waiting for RCON to become available...");
        } else {
            console.log(`Retrying RCON connection (attempt ${connectionAttempts}/${config.rcon.maxReconnectAttempts})...`);
        }
        
        ws = new WebSocket(wsUrl);

        ws.on("open", () => {
            console.log("Connected to RCON. Assuming server started.");
            console.log(JSON.stringify({ done: "Server startup complete" }));
            
            waiting = false;
            connectionAttempts = 0;
            
            // Fix broken console output
            ws.send(createPacket('status'));

            // Remove initial listener and set up RCON command handling
            process.stdin.removeListener('data', initialListener);
            gameProcess.stdout.removeListener('data', filter);
            gameProcess.stderr.removeListener('data', filter);

            process.stdin.on('data', (text) => {
                ws.send(createPacket(text));
            });
        });

        ws.on("message", (data) => {
            try {
                const json = JSON.parse(data);
                if (json?.Message?.length > 0) {
                    console.log(json.Message);
                }
            } catch (e) {
                console.log("Error parsing RCON message:", e.message);
            }
        });

        ws.on("error", (err) => {
            waiting = true;
            connectionAttempts++;
            setTimeout(poll, config.rcon.reconnectInterval);
        });

        ws.on("close", () => {
            if (!waiting) {
                console.log("RCON connection closed.");
                exited = true;
                process.exit();
            }
        });
    } catch (err) {
        console.log(`Failed to create WebSocket connection: ${err.message}`);
        connectionAttempts++;
        setTimeout(poll, config.rcon.reconnectInterval);
    }
}

// Start RCON connection
poll();

