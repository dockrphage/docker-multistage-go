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
