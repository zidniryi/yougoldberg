# Dockerfile
FROM debian:bullseye

# Install build dependencies
RUN apt update && apt install -y \
	g++ \
	make \
	libcurl4-openssl-dev \
	pkg-config \
	dpkg-dev \
	fakeroot \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /yougoldberg

# Copy source files
COPY main.cpp .
COPY platforms.hpp .
COPY build.sh .
COPY build_deb.sh .
COPY README.md .

# Make build scripts executable
RUN chmod +x build.sh build_deb.sh

# Build the application
RUN ./build.sh native

# Create a runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt update && apt install -y \
	libcurl4 \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the built binary from build stage
COPY --from=0 /yougoldberg/yougoldberg-native /app/yougoldberg

# Make it executable
RUN chmod +x /app/yougoldberg

# Set the entrypoint
ENTRYPOINT ["/app/yougoldberg"]

# Default command shows help
CMD ["--help"]
