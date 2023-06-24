# mt5-mining-switch
a bat file to monitor the metatrader strategy tester agent and mine when it is idle

## CPU Monitor and Secondary Process Controller

This script monitors the CPU usage of a primary process and controls a secondary process based on the CPU usage threshold. It can be useful in scenarios where you want to allocate system resources dynamically.

### How It Works

1. The script sets up the following variables:
   - `primaryProcess`: Name of the primary process you want to monitor.
   - `secondaryProcess`: Name of the secondary process you want to control.
   - `secondaryParams`: Parameters to pass to the secondary process when starting it.
   - `threshold`: CPU usage threshold in percentage.

2. The script enters a continuous loop where it monitors the CPU usage of the primary process.

3. It uses PowerShell to get the CPU usage of the primary process. If the process is running, it sums up the CPU usage of all instances.

4. If the CPU usage exceeds the threshold, it checks if the secondary process is already started. If yes, it stops the secondary process.

5. If the CPU usage is below the threshold, it checks if the secondary process is not running. If yes, it starts the secondary process with the specified parameters.

6. The script repeats this process in a loop with a delay of 2 seconds between each iteration.

### Usage

1. Make sure you have the primary process and secondary process installed or available in the specified locations.

2. Modify the following variables in the script:
   - `primaryProcess`: Set it to the name of your primary process.
   - `secondaryProcess`: Set it to the name of your secondary process.
   - `secondaryParams`: Set it to any additional parameters for the secondary process.
   - `threshold`: Set it to the desired CPU usage threshold.

3. Save the script with a `.bat` file extension.

4. Double-click the script to run it. It will continuously monitor the CPU usage and control the secondary process accordingly.

Note: This script relies on PowerShell to interact with the system, so make sure PowerShell is available on your system.

Feel free to customize the script to fit your specific requirements. Happy stratagy testing and mining!
