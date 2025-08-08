#!/bin/bash
clean_up () {
    if [ $? -eq 1 ]; then
        cd /root || {
            echo "Unable to clean up."
            exit 1
        }
        echo "Cleaning up."
        apt-get remove --auto-remove -y puppet git ruby-rubygems
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
apt-get update

apt-get install -y --no-install-recommends git ruby-rubygems || {
    echo "Failed to install ruby. Aborting."
    exit 1
}

if ! gem list -i r10k; then
  gem install r10k
fi

if ! gem list -i puppet; then
  gem install puppet
fi

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
full_repo_path=$(pwd)
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

cat << 'POST_RECEIVE' > post-receive
#!/bin/bash
echo "Running receive hook"
WORKING_DIR="/root/checkout"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR" || { echo "Error: Failed to change directory to $WORKING_DIR"; exit 1; }
GIT_WORK_TREE="$WORKING_DIR" GIT_DIR=/root/control.git git checkout -f
echo "Current directory: $(pwd)"
echo "Listing files:"
if [ -f Puppetfile ]; then
    echo "Puppetfile found. Running r10k puppetfile install..."
    r10k -v info puppetfile install
else
    echo "No Puppetfile found. Not installing any modules."
fi
ls modules
puppet apply --modulepath="$WORKING_DIR/modules" --debug --summarize $WORKING_DIR/manifests
rm -r "$WORKING_DIR"
POST_RECEIVE
chmod +x post-receive
