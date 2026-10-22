import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: {
        showFailure = false;
    }

    function tryUnlock() {
        if (currentText.length === 0 || unlockInProgress)
            return;
        unlockInProgress = true;

        if (!pam.start()) {
            unlockInProgress = false;
            currentText = "";
            showFailure = true;
        }
    }

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (responseRequired) {
                respond(root.currentText);
            }
        }

        onCompleted: result => {
            root.unlockInProgress = false;

            if (result === PamResult.Success) {
                root.currentText = "";
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }
        }

        onError: error => {
            console.warn("PAM authentication error:", error);
        }
    }
}
