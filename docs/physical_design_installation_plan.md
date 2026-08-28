# ARe-UBNN-KWS Physical Design Installation Plan

## Current Machine
- **CPU:** AMD Ryzen 7 7445HS w/ Radeon 740M Graphics
- **RAM:** 15.27 GB (16 GB installed)
- **Disk:** C: 98.77 GB Free | E: 285.62 GB Free
- **OS:** Microsoft Windows 11 Home (10.0.26200)

## Existing Tools
- **Yosys:** VERIFIED (via OSS CAD Suite)
- **Icarus Verilog:** VERIFIED (via OSS CAD Suite)
- **GTKWave:** VERIFIED (via OSS CAD Suite)

## Missing Tools
- WSL2 Linux distribution
- Container runtime (Docker Desktop)
- OpenLane/OpenROAD
- Complete SKY130 PDK (Current is partial)
- KLayout
- NGSpice

## Recommended Installation Order
1. **Enable & Install WSL2:** Run `wsl --install -d Ubuntu-22.04` in an Administrator PowerShell.
2. **Install Docker Desktop:** Download and install Docker Desktop for Windows, ensuring the "Use the WSL 2 based engine" setting is checked.
3. **Install OpenLane:** Inside the Ubuntu terminal, run:
   - `git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git`
   - `cd OpenLane`
   - `make pull-openlane`
4. **Provision SKY130 PDK:** Inside the OpenLane directory, run:
   - `make pdk`
   - *This will automatically download and configure the complete Volare SKY130 PDK, including all missing standard cells.*
5. **Install KLayout & NGSpice:** Inside Ubuntu, run `sudo apt update && sudo apt install klayout ngspice`.

## Estimated Disk Usage
- **WSL2 Ubuntu Image:** ~2 GB
- **Docker Images (OpenLane):** ~3-5 GB
- **Volare SKY130 PDK:** ~5-10 GB
- **Total Estimated:** ~10-17 GB
*(Sufficient space is available on drive C: and E:)*

## Risks
- **RAM Constraint:** The physical design flow for a large design can consume significant memory. The 16GB available is sufficient for the 16-PE ARe-UBNN-KWS, but Docker memory limits in `.wslconfig` should be configured to allow at least 12GB to the WSL VM to prevent OOM errors during detailed routing.
- **Path Translation:** Running OpenLane via Docker inside WSL on files stored in the Windows filesystem (`/mnt/e/...`) can cause permission and symlink issues. It is highly recommended to copy the project to the WSL native filesystem (e.g., `~/Are_UBNN_KWS`) before running `make mount`.

## Recovery Strategy
If the Docker installation fails or corrupts, use `wsl --unregister Ubuntu-22.04` to wipe the environment cleanly and restart Step 1, as the Windows source directory (`E:\Are_UBNN_KWS`) is safely isolated from the Linux filesystem.