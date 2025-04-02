#!/bin/sh
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DNS_NAME=$(dig +short -x $(hostname -I | awk '{print $NF}') | head -n 1 | cut -d'.' -f1)

# Define the output file
OUTPUT_FILE="/usr/share/nginx/html/index.html"

# Create the HTML file with the specified content
cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Info</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="flex items-center justify-center min-h-screen bg-gray-900 text-white">
    <div class="bg-gray-800 p-6 rounded-lg shadow-lg text-center">
        <h1 class="text-2xl font-bold mb-4">System Information</h1>
        <p><strong>Hostname:</strong> <span id="hostname">$HOSTNAME</span></p>
        <p><strong>IP Address:</strong> <span id="ipaddress">$IP_ADDRESS</span></p>
        <p><strong>DNS Name:</strong> <span id="dnsname">$DNS_NAME</span></p>
    </div>
</body>
</html>
EOF

/sbin/ip route add 10.0.1.0/24 via 10.0.2.254
nginx -g "daemon off;"
