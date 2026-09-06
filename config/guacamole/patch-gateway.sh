#!/bin/bash
# ----------------------------------------------------
# PT-CAD Central Gateway Boot Patch (Dynamic Watch Loop)
# ----------------------------------------------------

echo "=== PT-CAD Central: Initialization Script Triggered ==="

TARGET_INDEX="/usr/local/tomcat/webapps/guacamole/index.html"

# Define the patch function to watch and inject code asynchronously
run_background_patch() {
    echo "PT-CAD Central: Background watch loop spawned. Waiting for Tomcat to unpack assets..."
    
    # Loop for a maximum of 60 seconds looking for the index file
    for i in {1..60}; do
        if [ -f "$TARGET_INDEX" ]; then
            echo "PT-CAD Central: Catch! Located real index file at $TARGET_INDEX after $i seconds."
            
            # Check if we already patched it to avoid duplicate loops
            if grep -q "PT-CAD Central" "$TARGET_INDEX"; then
                echo "PT-CAD Central: Patch wrapper already present. Exiting watch loop."
            else
                echo "PT-CAD Central: Injecting constructor boot hook into fresh index..."
                cat << 'EOF' >> "$TARGET_INDEX"
<script>
console.log('PT-CAD Central: Injected constructor boot hook active.');
window.addEventListener('load', () => {
    if (window.Guacamole && Guacamole.Client) {
        console.log('PT-CAD Central: Client framework verified. Hooking instances.');
        const OriginalClient = Guacamole.Client;
        Guacamole.Client = function(tunnel) {
            console.log('PT-CAD Central: Live Client connection instantiated.');
            const instance = new OriginalClient(tunnel);
            instance.onstatechange = function(state) {
                if (state === 5) {
                    console.log('PT-CAD Central: Connection drop caught. Bouncing home portal.');
                    window.location.href = window.location.origin + '/guacamole/#/';
                    return;
                }
            };
            return instance;
        };
        Guacamole.Client.prototype = OriginalClient.prototype;
    }
});
</script>
EOF
                echo "PT-CAD Central: Gateway UI successfully patched behind the scenes!"
            fi
            return 0
        fi
        sleep 1
    done
    echo "PT-CAD Central: CRITICAL TIMEOUT - Tomcat failed to unpack index.html within 60 seconds."
}

# Run the watch function in a detached background thread so it does not block container boot
run_background_patch &

echo "=== PT-CAD Central: Handing control over to Guacamole init immediately ==="
# Hand control back to Guacamole's native daemon to start unpacking webapps
exec /init
