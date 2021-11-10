#!/bin/bash

VERSION="v0.1"
#===================================================================
# title           setup-new-computer.sh
# author          arcweld
#                 https://github.com/arcweld
# based on original work by
#   jkesler@vendasta.com, https://github.com/joelkesler
# forked from https://github.com/vendasta/setup-new-computer-script
#===================================================================
#   A shell script to help with the quick setup and installation of tools and
#   applications for new laptops
#
#   Quick Instructions:
#
#   1. Make the script executable:
#      chmod +x ./setup-new-computer.sh
#
#   2. Run the script:
#      ./setup-new-computer.sh
#
#   3. Some installs will need your password
#
#   4. You will be promted to fill out your git email and name.
#      Use the email and name you use for Github
#
#   5. Follow the Post Installation Instructions in the Readme:
README="https://github.com/arcweld/setup-new-computer-script#post-installation-instructions"
#
#===============================================================================


# Tools to make available. Please also adjust code to sudo apt-get  install
options[0]="Visual Studio Code";    devtoolchoices[0]="+"
options[1]="Atom";                  devtoolchoices[1]=""
options[2]="Jetbrains IntelliJ";     devtoolchoices[2]=""


#===============================================================================
#  Functions
#===============================================================================


printHeading() {
    printf "\n\n\n\e[0;36m$1\e[0m \n"
}

printDivider() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\n"
}

printError() {
    printf "\n\e[1;31m"
    printf %"$COLUMNS"s |tr " " "-"
    if [ -z "$1" ]      # Is parameter #1 zero length?
    then
        printf "     There was an error ... somewhere\n"  # no parameter passed.
    else
        printf "\n     Error Installing $1\n" # parameter passed.
    fi
    printf %"$COLUMNS"s |tr " " "-"
    printf " \e[0m\n"
}

printStep() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\nInstalling $1...\n";
    $2 || printError "$1"
}

printLogo() {
cat << "EOT"

   __ _ _ __ _____      _____| | __| |
  / _` | '__/ __\ \ /\ / / _ \ |/ _` |
 | (_| | | | (__ \ V  V /  __/ | (_| |
  \__,_|_|  \___| \_/\_/ \___|_|\__,_|
 ------------------------------------------
    Q U I C K   S E T U P   S C R I P T


    NOTE:
    You can exit the script at any time by
    pressing CONTROL+C a bunch
EOT
}

showToolsMenuLoop() {
    # from https://serverfault.com/a/777849
    printLogo
    printHeading "Select Tech Tools"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
        echo ""
        for NUM in "${!options[@]}"; do
            echo "[""${devtoolchoices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
        done
        echo ""
}

writetoBashProfile() {
cat << EOT >> ~/.bash_profile


# --------------------------------------------------------------------
# Begin Bash autogenerated content from setup-new-computer.sh   $VERSION
# --------------------------------------------------------------------

# Supress "Bash no longer supported" message
export BASH_SILENCE_DEPRECATION_WARNING=1

# Setting up Path for Linux
export PATH=/usr/local/sbin:\$PATH

# Bash Autocompletion
if [ -f "/usr/bin/apt"]; then
  sudo apt update
  sudo apt install bash-completion
  [ -e '/etc/profile.d/bash_completion.sh'] && [source /etc/profile.d/bash_completion.sh]
  [ -e '/etc/bash_completion.sh'] && [source /etc/bash_completion.sh]
fi

# Google Cloud SDK
# The next line updates PATH for the Google Cloud SDK.
    if [ -f '\$HOME/google-cloud-sdk/path.bash.inc' ]; then . '\$HOME/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
    if [ -f '\$HOME/google-cloud-sdk/completion.bash.inc' ]; then . '\$HOME/google-cloud-sdk/completion.bash.inc'; fi

# NVM
# Is this needed on Linux/Debian/Ubuntu?
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \
    source "\$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \
    source "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias python='python3'
alias pip='pip3'
alias ipython='ipython3'
alias ic="ibmcloud"

# --------------------------------------------------------------------
# End autogenerated content from setup-new-computer.sh   $VERSION
# --------------------------------------------------------------------


EOT
}

# Get root user for later. Brew needs the user to be admin for
sudo ls > /dev/null


#===============================================================================
# Installer: Settings
#===============================================================================


# Show IDE Selection Menu
clear
while
    showToolsMenuLoop && \
    read -r -e -p "Enable or Disable by typing number. Hit ENTER to continue " \
    -n1 SELECTION && [[ -n "$SELECTION" ]]; \
do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${devtoolchoices[SELECTION]}" == "+" ]]; then
            devtoolchoices[SELECTION]=""
        else
            devtoolchoices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done
printDivider



#===============================================================================
#  Installer: Set up shell profiles
#===============================================================================


# Create .bash_profile and .zprofile if they dont exist
printHeading "Prep Bash"
printDivider
    echo "✔ Touch ~/.bash_profile"
        touch ~/.bash_profile
printDivider
    if grep --quiet "setup-new-computer.sh" ~/.bash_profile; then
        echo "✔ .bash_profile already modified. Skipping"
    else
        writetoBashProfile
        echo "✔ Added to .bash_profile"
    fi
printDivider


#===============================================================================
#  Installer: Main Payload
#===============================================================================

printDivider


# Install Utilities
printHeading "Installing Packages"
    printStep "Git"                         "sudo apt-get install git"
    printStep "Github CLI - gh"             "sudo apt-get install gh"
printDivider

# Install  Apps
printHeading "Installing Applications"
    printStep "Slack"                       "sudo apt-get install slack"
    printStep "Firefox"                     "sudo apt-get install firefox"
    printStep "Google Chrome"               "sudo apt-get install google-chrome"
    printStep "Docker"              "sudo apt-get install docker"
    printStep "Postman"                     "sudo apt-get install postman"
    # Install Visual Studio Code
    if [[ "${devtoolchoices[0]}" == "+" ]]; then
        printStep "Visual Studio Code"      "sudo apt-get install visual-studio-code"
    fi
    # Install Jetbrains IntelliJ
    if [[ "${devtoolchoices[1]}" == "+" ]]; then
        printStep "Jetbrains Toolbox"       "sudo apt-get install jetbrains-toolbox"
    fi
    # Install PyCharm
    if [[ "${devtoolchoices[2]}" == "+" ]]; then
        printStep "PyCharm"                 "sudo apt-get install pycharm"
    fi
    # Install Goland
    if [[ "${devtoolchoices[3]}" == "+" ]]; then
        printStep "Goland"                  "sudo apt-get install goland"
    fi
    # Install WebStorm
    if [[ "${devtoolchoices[4]}" == "+" ]]; then
        printStep "WebStorm"                "sudo apt-get install webstorm"
    fi
    # Install Sublime Text
    if [[ "${devtoolchoices[5]}" == "+" ]]; then
        printStep "Sublime Text"            "sudo apt-get install sublime-text"
    fi
    # Install iTerm2
    if [[ "${devtoolchoices[6]}" == "+" ]]; then
        printStep "iTerm2"                  "sudo apt-get install iterm2"
    fi
printDivider


# Install Google Cloud SDK and Components
# TODO: refactor from mac to nix
printHeading "Install Google Cloud SDK and Components"
    printStep "Google Cloud SDK"        "sudo apt-get install google-cloud-sdk"
    printDivider
        echo "✔ Prepping Autocompletes and Paths"
        source "$(sudo apt-get --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
        source "$(sudo apt-get --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
    printDivider
        if [ -e ~/google-cloud-sdk ]; then
            echo "✔ ~/google-cloud-sdk exists. Skipping"
        else
            echo "✔ Creating ~/google-cloud-sdk symlink"
            ln -s "$(sudo apt-get --prefix)/Caskroom/google-cloud-sdk" ~/google-cloud-sdk &>/dev/null
            # make a convenience symlink at the install path for google-cloud-sdk when installed manually
        fi
    printStep "App Engine - Go"             "gcloud components install app-engine-go --quiet"
    printStep "App Engine - Python"         "gcloud components install app-engine-python --quiet"
    printStep "App Engine - Python Extras"  "gcloud components install app-engine-python-extras --quiet"
    printStep "Kubectl"                     "gcloud components install kubectl --quiet"
    printStep "Docker Credentials"          "gcloud components install docker-credential-gcr --quiet"
printDivider


# TODO: install python, pip
# TODO: install podman, Anaconda
# TODO: install Linode, R,
# TODO: install firefox, chrome, chromium
# TODO: install Authy, Joplin, Nextcloud, Zotero, Republic Wireless, TopTracker, Pomatez, Microsoft Teams, Pithos, MEGAsync, KeePass2, LibreOffice

# TODO: install FreeCAD, Cura, VLC, ImageMagick, GIMP

# Install System Tweaks
printHeading "System Tweaks"
    printDivider
    echo "✔ General: Expand save and print panel by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    echo "✔ General: Save to disk (not to iCloud) by default"
        defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    echo "✔ General: Avoid creating .DS_Store files on network volumes"
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    printDivider

    echo "✔ Typing: Disable smart quotes and dashes as they cause problems when typing code"
        defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
        defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    echo "✔ Typing: Disable press-and-hold for keys in favor of key repeat"
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    printDivider

    echo "✔ Finder: Show status bar and path bar"
        defaults write com.apple.finder ShowStatusBar -bool true
        defaults write com.apple.finder ShowPathbar -bool true
    echo "✔ Finder: Disable the warning when changing a file extension"
        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    echo "✔ Finder: Show the ~/Library folder"
        chflags nohidden ~/Library
    printDivider

    echo "✔ Safari: Enable Safari’s Developer Settings"
        defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
        defaults write com.apple.Safari IncludeDevelopMenu -bool true
        defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
        defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
        defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
    printDivider

    echo "✔ Chrome: Disable the all too sensitive backswipe on Trackpads and Magic Mice"
        defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
        defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
        defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
        defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false
    echo "✔ Chrome: Use the system print dialog and expand dialog by default"
        defaults write com.google.Chrome DisablePrintPreview -bool true
        defaults write com.google.Chrome.canary DisablePrintPreview -bool true
        defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
        defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
printDivider



#===============================================================================
#  Installer: Git
#===============================================================================


# Set up Git
printHeading "Set Up Git"

# Configure git to always ssh when dealing with https github repos
git config --global url."git@github.com:".insteadOf https://github.com/

printDivider
    echo "✔ Set Git to store credentials in Keychain"
    git config --global credential.helper osxkeychain
printDivider
    if [ -n "$(git config --global user.email)" ]; then
        echo "✔ Git email is set to $(git config --global user.email)"
    else
        read -p 'What is your Git email address?: ' gitEmail
        git config --global user.email "$gitEmail"
    fi
printDivider
    if [ -n "$(git config --global user.name)" ]; then
        echo "✔ Git display name is set to $(git config --global user.name)"
    else
        read -p 'What is your Git display name (Firstname Lastname)?: ' gitName
        git config --global user.name "$gitName"
    fi
printDivider



#===============================================================================
#  Installer: Complete
#===============================================================================

printHeading "Script Complete"
printDivider

tput setaf 2 # set text color to green
cat << "EOT"

   ╭─────────────────────────────────────────────────────────────────╮
   │░░░░░░░░░░░░░░░░░░░░░░░░░░░ Next Steps ░░░░░░░░░░░░░░░░░░░░░░░░░░│
   ├─────────────────────────────────────────────────────────────────┤
   │                                                                 │
   │   There are still a few steps you need to do to finish setup.   │
   │                                                                 │
   │        The link below has Post Installation Instructions        │
   │                                                                 │
   └─────────────────────────────────────────────────────────────────┘

EOT
tput sgr0 # reset text
echo "Link:"
echo $README
echo ""
echo ""
tput bold # bold text
read -n 1 -r -s -p $'             Press any key to to open the link in a browser...\n\n'
open $README
tput sgr0 # reset text

echo ""
echo ""
echo "Please open a new terminal window to continue your setup steps"


exit
