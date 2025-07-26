# BeamBridge

BeamBridge is a powerful RCON bridge and wrapper system for BeamMP dedicated servers. Built using Node.js and Lua, it enables:

- ✅ Centralized remote command dispatch across multiple BeamMP servers  
- 🔐 Secure RCON password-based validation  
- 🔁 Automatic server restarts on crash  
- 📡 Real-time communication between Node.js and BeamMP via stdin/stdout  
- 📁 Optional JSON file fallback for command queueing

Ideal for server admins looking to scale, automate, and remotely manage multiple BeamMP instances with ease.

## Components
- **Lua Plugin** – Handles inbound RCON commands within BeamMP
- **Node.js Bridge** – Listens for UDP RCON packets and relays commands
- **Server Wrapper** – Wraps BeamMP server process to enable input injection

## License
MIT
