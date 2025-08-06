#!/bin/bash
clean_up () {
    if [ $? -eq 1 ]; then
        cd /root || {
            echo "Unable to clean up."
            exit 1
        }
        echo "Cleaning up."
        apt-get remove --auto-remove -y puppet git
        if [ -d control.git ]; then
            rm -r control.git || echo "Unable to clean up directory."
        else
            echo "Nothing to clean up."
        fi
    fi
}

handle_interrupt() {
    echo "Script interrupted by user."
    exit 1
}

trap handle_interrupt INT
trap clean_up EXIT
apt-get update
apt-get install -y puppet git || {
    echo "Failed to install puppet and git. Aborting."
    exit 1
}

cd /root || {
    echo "Failed to change directory to /root. Aborting."
    exit 1
}
mkdir control.git || {
    echo "Failed to create directory control.git. Aborting."
    exit 1
}
cd control.git || {
    echo "Failed to change directory to control.git. Aborting."
    exit 1
}
git config --global init.defaultBranch main || {
    echo "Failed to configure git. Aborting."
    exit 1
}

git init --bare || {
    echo "Failed to initialize git repository. Aborting."
    exit 1
}

cd hooks || {
    echo "Hooks directory is missing. Aborting."
    exit 1
}

SCRIPT="post-receive"
echo "#!/bin/bash" > $SCRIPT
echo "echo \"Running receive hook\"" >> $SCRIPT
echo "WORKING_DIR=\"/root/checkout\"" >> $SCRIPT
echo "mkdir -p \"\$WORKING_DIR\"" >> $SCRIPT
echo "cd \"\$WORKING_DIR\" || { echo \"Error: Failed to change directory to \$WORKING_DIR\"; exit 1; }" >> $SCRIPT
echo "GIT_WORK_TREE=\"\$WORKING_DIR\" GIT_DIR=/root/control.git git checkout -f" >> $SCRIPT
echo "puppet apply --summarize \$WORKING_DIR" >> $SCRIPT
echo "rm -r \"\$WORKING_DIR\"" >> $SCRIPT
chmod +x "$SCRIPT"

