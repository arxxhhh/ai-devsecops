#!/bin/bash
set -e

REPORT="trivy-report.json"
SEVERITY="CRITICAL,HIGH"

echo "Installing Trivy..."
curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

echo "Running Trivy fs scan..."
trivy fs . \
  --format json \
  --output "$REPORT" \
  --severity "$SEVERITY" \
  --quiet

echo "Checking for $SEVERITY vulnerabilities..."
COUNT=$(python3 -c "
import json
data = json.load(open('$REPORT'))
vulns = [v for r in (data.get('Results') or []) for v in (r.get('Vulnerabilities') or []) if v.get('Severity') in ('CRITICAL','HIGH')]
print(len(vulns))
")

echo "Found $COUNT $SEVERITY vulnerabilities"

if [ "$COUNT" -gt 0 ]; then
  echo "Security gate FAILED: fix CRITICAL/HIGH vulnerabilities before building."
  exit 1
fi

echo "Security gate PASSED: no CRITICAL/HIGH vulnerabilities found."
