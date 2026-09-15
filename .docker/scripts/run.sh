# Verify that the script is being passed a folder name as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

# Verify that the specified folder exists
if [ ! -d "/opt/VisibleSim/applicationsSrc/$1" ]; then
    echo "Error: Folder '/opt/VisibleSim/applicationsSrc/$1' does not exist."
    exit 1
fi

# Build the application (1/2)
cd /opt/VisibleSim
sudo cp /opt/VisibleSim/.applicationsSrc/Makefile /opt/VisibleSim/applicationsSrc/Makefile
sudo DOCKER_CUSTOM_VAR__TARGET_APP="$1" make
DOCKER_CUSTOM_VAR__MAKE_STATUS=$?
sudo rm /opt/VisibleSim/applicationsSrc/Makefile

# Check if the make command was successful
if [ $DOCKER_CUSTOM_VAR__MAKE_STATUS -ne 0 ]; then
    exit 1
fi

# Build the application (2/2)
sudo cp /opt/VisibleSim/applicationsSrc/$1/config.xml /opt/VisibleSim/applicationsBin/$1/config.xml

# Run the application
cd /opt/VisibleSim/applicationsBin/$1
chmod +x "$1"
sudo ./"$1" -c config.xml
