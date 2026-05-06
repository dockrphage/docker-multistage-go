# ================================
# Multi‑Stage Docker Build Lab
# Automated Build & Test Pipeline
# ================================

APP_NAME=myapp
DEMO_NAME=demo

# Default target
.DEFAULT_GOAL := help

# -------------------------------
# Utility
# -------------------------------
help:
    @echo ""
    @echo "Available targets:"
    @echo "  make single        - Build single‑stage image"
    @echo "  make multistage    - Build basic multi‑stage image"
    @echo "  make advanced      - Build optimized multi‑stage image"
    @echo "  make production    - Build production image"
    @echo "  make full          - Build all images"
    @echo "  make run           - Run production image"
    @echo "  make analyze       - Run layer/security analysis"
    @echo "  make clean         - Remove all images"
    @echo "  make dev           - Run Air dev environment"
    @echo ""

# -------------------------------
# Build Targets
# -------------------------------
single:
    docker build -f Dockerfile.single -t $(APP_NAME):single .

multistage:
    docker build -f Dockerfile.multistage -t $(APP_NAME):multistage .

advanced:
    docker build -f Dockerfile.advanced -t $(APP_NAME):advanced .

production:
    docker build -f Dockerfile.production -t $(APP_NAME):production .

full: single multistage advanced production

# -------------------------------
# Run Targets
# -------------------------------
run:
    docker run --rm -p 8080:8080 $(APP_NAME):production

dev:
    docker build -f Dockerfile.production-full --target development -t $(DEMO_NAME):dev .
    docker run --rm -p 8080:8080 -v $$(pwd)/app:/app $(DEMO_NAME):dev

# -------------------------------
# Analysis & Debugging
# -------------------------------
analyze:
    ./analyze-layers.sh

debug:
    docker build -f Dockerfile.production-full --target debug -t $(DEMO_NAME):debug .
    docker run -it $(DEMO_NAME):debug sh

# -------------------------------
# Cleanup
# -------------------------------
clean:
    docker rmi -f \
        $(APP_NAME):single \
        $(APP_NAME):multistage \
        $(APP_NAME):advanced \
        $(APP_NAME):production \
        $(DEMO_NAME):dev \
        $(DEMO_NAME):debug || true
