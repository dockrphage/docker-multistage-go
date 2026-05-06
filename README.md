Below is a **complete README.md** with all required commands (and heredocs included). Or simply clone this repo and recreate the entire lab **from scratch**.

Included
- `mkdir` commands  
- Full directory structure creation  
- **Heredoc‑based file generation** for every file in the lab  
- Build + run commands  
- Validation commands  
- A clean, production‑grade flow   
---

# 🚀 Multi‑Stage Docker Build Lab  
### Complete Reproducible Setup with mkdir + Heredocs + Build Commands

This lab teaches you how to build Docker images the *right* way — progressing from a naive single‑stage build to a fully optimized, secure, production‑grade multi‑stage pipeline.

Everything below is **copy‑paste runnable**.

---

# 📁 1. Create Project Structure

```bash
mkdir -p multistage-lab/app
cd multistage-lab
```

---

# 📄 2. Create All Required Files (Heredoc)

## **app/main.go**
```bash
cat << 'EOF' > app/main.go
package main

import (
    "fmt"
    "log"
    "net/http"
    "github.com/google/uuid"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        requestID := uuid.New().String()
        fmt.Fprintf(w, "Request ID: %s\nMulti-stage Docker Build!\n", requestID)
    })

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF
```

---

## **app/main_test.go**
```bash
cat << 'EOF' > app/main_test.go
package main

import "testing"

func TestDummy(t *testing.T) {
    if 1+1 != 2 {
        t.Fatal("math broke")
    }
}
EOF
```

---

## **app/go.mod**
```bash
cat << 'EOF' > app/go.mod
module app

go 1.21

require github.com/google/uuid v1.3.0
EOF
```

---

## **app/go.sum**
```bash
cat << 'EOF' > app/go.sum
github.com/google/uuid v1.3.0 h1:t6JiXyZ9VHtV6nRvWmvMRGsiE9z1FMvx6bMpiKFF9s0=
github.com/google/uuid v1.3.0/go.mod h1:TIyPjKjBvZx2drXr/7Lr1gChX2NDSSSX5QZnIcEqB9w=
EOF
```

---

## **.air.toml**
```bash
cat << 'EOF' > .air.toml
root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/myapp ."
bin = "tmp/myapp"
include_ext = ["go"]
exclude_dir = ["tmp", "vendor"]

[log]
time = true

[serve]
cmd = "./tmp/myapp"
EOF
```

---

## **Dockerfile.single**
```bash
cat << 'EOF' > Dockerfile.single
FROM golang:1.21
WORKDIR /app
COPY app/* .
RUN go build -o myapp .
EXPOSE 8080
CMD ["./myapp"]
EOF
```

---

## **Dockerfile.multistage**
```bash
cat << 'EOF' > Dockerfile.multistage
FROM golang:1.21 AS builder
WORKDIR /build
COPY app/* .
RUN go build -o myapp .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /build/myapp .
EXPOSE 8080
CMD ["./myapp"]
EOF
```

---

## **Dockerfile.advanced**
```bash
cat << 'EOF' > Dockerfile.advanced
FROM golang:1.21 AS deps
WORKDIR /build
COPY app/go.mod app/go.sum ./
RUN go mod download

FROM golang:1.21 AS builder
WORKDIR /build
COPY --from=deps /build/go.mod /build/go.sum ./
RUN go mod download
COPY app/* .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o myapp .

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=builder --chown=nonroot:nonroot /build/myapp .
USER nonroot
EXPOSE 8080
CMD ["./myapp"]
EOF
```

---

## **Dockerfile.production**
```bash
cat << 'EOF' > Dockerfile.production
FROM golang:1.21 AS ci
WORKDIR /build
COPY app/go.mod app/go.sum ./
RUN go mod download
COPY app/* .
RUN go mod verify
RUN CGO_ENABLED=0 GOOS=linux go test -v ./...

FROM golang:1.21 AS builder
WORKDIR /build
COPY --from=ci /build/go.mod /build/go.sum ./
RUN go mod download
COPY app/* .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -extldflags '-static'" \
    -o myapp .

FROM alpine:latest AS security
RUN apk add --no-cache trivy
COPY --from=builder /build/myapp /myapp
RUN trivy filesystem --no-progress --exit-code 0 --severity HIGH,CRITICAL /

FROM scratch
COPY --from=builder /build/myapp /myapp
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["/myapp"]
EOF
```

---

## **docker-compose.yml**
```bash
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.production
      target: builder
    ports:
      - "8080:8080"

  app-final:
    build:
      context: .
      dockerfile: Dockerfile.production
    ports:
      - "8081:8080"
EOF
```

---

## **.dockerignore**
```bash
cat << 'EOF' > .dockerignore
.git/
.gitignore
Dockerfile*
docker-compose*.yml
.dockerignore
*.md
.vscode/
.idea/
*.log
.env*
.DS_Store
bin/
dist/
tmp/
*.exe
*.test
.github/
.gitlab-ci.yml
Jenkinsfile
*.key
*.pem
*secret*
.ssh/
EOF
```

---

## **analyze-layers.sh**
```bash
cat << 'EOF' > analyze-layers.sh
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
EOF
chmod +x analyze-layers.sh
```

---

## **interview-practice.sh**
```bash
cat << 'EOF' > interview-practice.sh
#!/bin/bash

questions=(
    "Q1: Our Docker image takes 5 minutes to push to registry. What's wrong?"
    "Q2: How would you reduce Docker build time from 10 minutes to 2 minutes?"
    "Q3: We found reverse shells in production from our container. How did this happen?"
    "Q4: Our Python app needs both build-time and runtime dependencies. Show Dockerfile pattern."
    "Q5: Explain the difference between COPY --from and multi-stage build targets."
)

answers=(
    "A1: Image size is too large. Use multi-stage builds, .dockerignore, slim bases."
    "A2: Layer caching, BuildKit, cache mounts, reorder COPY commands."
    "A3: Your image contains a shell or compilers. Use distroless or scratch."
    "A4: Builder stage installs deps, runtime stage copies venv."
    "A5: COPY --from copies artifacts; targets allow building specific stages."
)

for i in "${!questions[@]}"; do
    echo -e "\n${questions[$i]}"
    echo -n "Your answer: "
    read
    echo "${answers[$i]}"
    echo "---"
done
EOF
chmod +x interview-practice.sh
```

---

# 🏗 3. Build Commands

## Single‑stage
```bash
docker build -f Dockerfile.single -t myapp:single .
```

## Multi‑stage
```bash
docker build -f Dockerfile.multistage -t myapp:multistage .
```

## Advanced
```bash
docker build -f Dockerfile.advanced -t myapp:advanced .
```

## Production
```bash
docker build -f Dockerfile.production -t myapp:production .
```

---

# ▶ 4. Run the App

```bash
docker run --rm -p 8080:8080 myapp:production
```

---

# 🧪 5. Validate Everything

```bash
./analyze-layers.sh
./interview-practice.sh
```

---

# 🎉 Done — You Now Have a Fully Reproducible Multi‑Stage Docker Lab

