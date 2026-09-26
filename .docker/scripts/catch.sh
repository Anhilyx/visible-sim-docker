# Verify that the script is being passed a folder name as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <project_name> [args...]"
    exit 1
fi

# Verify that the specified folder exists
if [ ! -d "/opt/VisibleSim/applicationsSrc/$1" ]; then
    echo "Error: Folder '/opt/VisibleSim/applicationsSrc/$1' does not exist."
    exit 1
fi

# Extract arguments from the command
DOCKER_CUSTOM_VAR__PROJECT_NAME="$1"
shift

# Build the application (1/2)
cd /opt/VisibleSim
sudo cp /opt/VisibleSim/.applicationsSrc/Makefile /opt/VisibleSim/applicationsSrc/Makefile
sudo DOCKER_CUSTOM_VAR__TARGET_APP="$DOCKER_CUSTOM_VAR__PROJECT_NAME" make
DOCKER_CUSTOM_VAR__MAKE_STATUS=$?
sudo rm /opt/VisibleSim/applicationsSrc/Makefile

# Check if the make command was successful
if [ $DOCKER_CUSTOM_VAR__MAKE_STATUS -ne 0 ]; then
    exit 1
fi

# Build the application (2/2)
sudo rm /opt/VisibleSim/applicationsBin/$DOCKER_CUSTOM_VAR__PROJECT_NAME/*.xml
sudo cp /opt/VisibleSim/applicationsSrc/$DOCKER_CUSTOM_VAR__PROJECT_NAME/*.xml /opt/VisibleSim/applicationsBin/$DOCKER_CUSTOM_VAR__PROJECT_NAME/

# Run the application
cd /opt/VisibleSim/applicationsBin/$DOCKER_CUSTOM_VAR__PROJECT_NAME
chmod +x "$DOCKER_CUSTOM_VAR__PROJECT_NAME"
sudo gdb -q -batch -ex run -ex bt --args ./"$DOCKER_CUSTOM_VAR__PROJECT_NAME" "$@"
DOCKER_CUSTOM_VAR__RUN_STATUS=$?

# Display the exit status of the application if it was terminated by a signal
if [ $DOCKER_CUSTOM_VAR__RUN_STATUS -gt 128 ]; then
    SIGNAL_NUM=$((DOCKER_CUSTOM_VAR__RUN_STATUS - 128))
    SIGNAL_NAME=$(kill -l "$SIGNAL_NUM" 2>/dev/null)
    echo "→ Programme terminé par le signal $SIGNAL_NUM (SIG$SIGNAL_NAME)"
    dmesg --ctime 2>/dev/null | tail -n 5
fi

exit $DOCKER_CUSTOM_VAR__RUN_STATUS
