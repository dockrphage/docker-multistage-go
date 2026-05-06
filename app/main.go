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
