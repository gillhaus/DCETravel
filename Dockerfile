FROM swift:5.9-jammy as build
WORKDIR /app
COPY DCETravelAPI/ .
RUN swift build -c release

FROM swift:5.9-jammy-slim
COPY --from=build /app/.build/release/App /app/App
EXPOSE 8080
CMD ["/app/App", "serve", "--env", "production", "--hostname", "0.0.0.0"]
