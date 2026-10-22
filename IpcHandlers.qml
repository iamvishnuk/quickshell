import Quickshell
import Quickshell.Io

Scope {
    id: root

    // Lock screen process
    Process {
        id: lockScreenProcess
        command: ["qs", "-p", Quickshell.env("HOME") + "/.config/quickshell/lockscreen/shell.qml"]
    }

    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            if (!lockScreenProcess.running) {
                lockScreenProcess.running = true;
            }
        }
    }

}
