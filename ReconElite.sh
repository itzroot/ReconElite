#!/bin/bash

# ReconElite - Bash Tool for Reconnaissance

# showing the banner of the tool
echo -e "\n"
toilet -f mono9 -F border ReconElite
echo -e "\n\n"

echo -e "===>WARNING!! This tool performs active scanning. Try it at your own risk!<===\n\n"

# Check if required tools are installed
check_tools() {
    local required_tools=("subfinder" "nslookup" "httprobe" "dig" "whois" "nuclei" "rustscan" "gobuster" "waybackurls")

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "Error: $tool is not installed. Please install it and try again."
            exit 1
        fi
    done
}

echo -e "flag is: nfsuCTF{617hub_4_u} \n"

# Check if a target argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a target argument."
    echo "Usage: $0 <target>"
    exit 1
fi

target=$1

# Create the results directory
results_dir="results-$target"
mkdir -p "$results_dir"

# Create subdirectories for each category of information
mkdir -p "$results_dir/Domain-reconnaissance"
mkdir -p "$results_dir/Vulnerability-scanning"
mkdir -p "$results_dir/Network-mapping"
mkdir -p "$results_dir/Reporting"

# Log file paths
nslookup_log="$results_dir/Domain-reconnaissance/nslookup.txt"
dig_log="$results_dir/Domain-reconnaissance/dns_records.txt"
whois_log="$results_dir/Domain-reconnaissance/whois_information.txt"
subfinder_log="$results_dir/Domain-reconnaissance/subdomains.txt"
httprobe_log="$results_dir/Domain-reconnaissance/httprobe_output.txt"
rustscan_log="$results_dir/Network-mapping/rustscan_network_map.txt"
gobuster_log="$results_dir/Domain-reconnaissance/directory.txt"
nuclei_log="$results_dir/Vulnerability-scanning/nuclei_output.txt"
waybackurls_log="$results_dir/Domain-reconnaissance/waybackurls_output.txt"



generate_html_report() {
    local report_file="$results_dir/Reporting/report.html"
    local css_file="$results_dir/Reporting/report.css"

    cat <<EOF > "$report_file"
<!DOCTYPE html>
<html>
<head>
    <title>ReconElite Report - $target</title>
    <link rel="stylesheet" type="text/css" href="report.css">
</head>
<body>
    <h1>ReconElite Report - $target</h1>
EOF

    # Appendding the content of each tool's output to the report
    echo "<h2>Domain Reconnaissance using nslookup</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/nslookup.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>DNS Resolution using dig</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/dns_records.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>whois information</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/whois_information.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>Subdomains</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/subdomains.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>Alive subdomains using httprobe</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/httprobe_output.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>Network Scanning results</h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Network-mapping/rustscan_network_map.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>Directory Enumeration </h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Domain-reconnaissance/directory.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "<h2>Vulnerability scanning results </h2>" >> "$report_file"
    echo "<pre>" >> "$report_file"
    cat "$results_dir/Vulnerability-scanning/nuclei_output.txt" >> "$report_file"
    echo "</pre>" >> "$report_file"

    echo "</body></html>" >> "$report_file"

    # Copy the CSS file to the reporting directory
    cp "report.css" "$css_file"
}

# Perform DNS lookup using nslookup
nslookup_lookup() {
    echo -e "===>Performing DNS lookup using nslookup...<===\n \n" 
    nslookup "$target" > "$nslookup_log"
    echo -e "###DNS lookup completed.###\n"
}

# Perform DNS resolution using dig
dig_resolve() {
    echo -e "===>Performing DNS resolution using dig...<===\n \n"
    dig "$target" > "$dig_log"
    echo -e "###DNS resolution completed.###\n"
}

# Perform WHOIS lookup
whois_lookup() {
    echo -e "===>Performing WHOIS lookup...<===\n\n"
    whois -H "$target" > "$whois_log"
    echo -e "###WHOIS lookup completed.###\n"
}

# Perform Subdomain enumeration using Subfinder
subfinder_enum() {
    echo -e "===>Performing Subdomain enumeration using Subfinder...<===\n \n"
    subfinder -d $target -duc -silent -timeout 10 > "$subfinder_log"
    echo -e "###Subdomain enumeration completed.###\n"
}

# Probe HTTP/HTTPS servers using httprobe
httprobe_probe() {
    echo -e  "===>Probing HTTP/HTTPS servers using httprobe...<===\n \n"
    cat "$results_dir/Domain-reconnaissance/subdomains.txt" | httprobe --prefer-https > "$httprobe_log"
    echo -e "###Server probing completed.###\n"
}

# Extract URLs using waybackurls
waybackurls_enum() {
    echo -e "===>Extracting URLs using waybackurls...\<===n \n"
    cat "$results_dir/Domain-reconnaissance/subdomains.txt" | waybackurls > "$waybackurls_log"
    echo -e "###URL extraction using waybackurls completed.###\n"
}

# Perform network scanning using Rustscan
rustscan_scan() {
    echo -e  "===>Performing network scanning using Rustscan...<===\n \n"
    rustscan -a "$target"  -u 3000 -- -sV   > $results_dir/Network-mapping/rustscan_out.txt
    sed 's/\x1b\[[0-9;]*m//g' $results_dir/Network-mapping/rustscan_out.txt > "$rustscan_log"
    echo -e "###Network scanning completed. ###\n"
}

# Perform directory and file enumeration using Gobuster
gobuster_enum() {
    echo -e  "===>Performing directory and file enumeration using Gobuster...<===\n \n"
    gobuster dir -u "$target" -q -r --no-error -t 50  -z -w /usr/share/wordlists/dirb/common.txt  > "$gobuster_log"
    echo  -e "###Directory and file enumeration completed.###\n"
}

# Scan for vulnerabilities using Nuclei
nuclei_scan() {
    echo -e "===>Scanning for vulnerabilities using Nuclei...<===\n \n"
    nuclei -u "$target" -silent -rl 500 -timeout 5 -o "$nuclei_log" 
    echo -e "###Vulnerability scanning completed. ###\n"
}


echo -e "https://pastebin.com/ihj4UWui\n"

# Main function
main() {
    check_tools 

    nslookup_lookup &
    dig_resolve &
    whois_lookup &

    wait
    
    subfinder_enum 
    httprobe_probe
    waybackurls_enum & 
    rustscan_scan &
    gobuster_enum & 
    nuclei_scan &
    
    wait

    generate_html_report

    echo "###===>Reconnaissance completed. HTML report generated.<===###"
}

# Calling  the main function
main
