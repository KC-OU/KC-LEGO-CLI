# Build Stage
FROM golang:1.23-alpine AS builder

# Install build dependencies for SQLite (CGO)
RUN apk add --no-cache gcc musl-dev

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application with CGO enabled (required for SQLite)
RUN CGO_ENABLED=1 GOOS=linux go build -o lego-manager ./cmd/server/main.go

# Run Stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates

WORKDIR /root/

# Copy the binary and static assets
COPY --from=builder /app/lego-manager .
COPY --from=builder /app/web ./web

# Create directories for data and uploads
RUN mkdir -p data uploads/ldraw uploads/cad

# Expose the port the app runs on
EXPOSE 8080

# The app uses $HOME/.lego-manager.db by default. 
# We'll set HOME to /root/data so the DB is stored in a mountable volume.
ENV HOME=/root/data

CMD ["./lego-manager"]
