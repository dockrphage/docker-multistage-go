#!/bin/bash

echo "=== Multi-Stage Build Analysis ==="
echo

echo "1. Size Comparison:"
docker images | grep -E "myapp:(single|multistage|advanced|production)" | awk '{printf "%-15s %10s %s\n", $1":"$2, $7, $8}'

echo -e "\n2. Layer Analysis (Advanced build):"
docker history myapp:advanced --format "table {{.Size}}\t{{.CreatedBy}}"

echo -e "\n3. Security Scan:"
trivy image myapp:production --severity HIGH,CRITICAL --no-progress 2>/dev/null || echo "Install trivy: brew install aquasecurity/trivy/trivy"

echo -e "\n4. Binary Verification:"
docker run --entrypoint file myapp:production /myapp

echo -e "\n5. Build Cache Analysis:"
docker builder du
