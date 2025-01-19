FROM golang:1.23.2-alpine3.20 as builder

WORKDIR /app

ENV CGO_ENABLED 0

RUN go install go.k6.io/xk6/cmd/xk6@latest && \
    xk6 build \
    --with github.com/joanlopez/xk6-aws@latest \
    --with github.com/grafana/xk6-dashboard@latest


FROM alpine:3.21.2

# Install AWS CLI
RUN apk add --no-cache shadow bash aws-cli && \
    groupadd --gid 1000 k6 && \
    adduser -D -u 1000 -G k6 k6

WORKDIR /app

# Copy k6 binary and entrypoint script from builder stage
COPY --from=builder /app/k6 .
COPY --chown=k6:k6 --chmod=0755 entrypoint.sh .
COPY .env .

USER k6

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "/app/k6, "--version" ]

ENTRYPOINT ["/app/entrypoint.sh", "${APPLICATION}", "${ENVIRONMENT}"]
