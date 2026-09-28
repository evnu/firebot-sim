# Replay

This is the replay server for simulations. During a simulation run, simulation components
report their telemetry to this server, which stores it. At a later point in time,
clients of this server can ask it to replay the telemetry at a client-defined rate back
to them. This simulates real time behavior of the simulated components.
