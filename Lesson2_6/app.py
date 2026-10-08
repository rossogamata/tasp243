import os

from flask import Flask, jsonify
from redis import Redis
from redis.exceptions import RedisError

app = Flask(__name__)
redis_client = Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=6379,
    decode_responses=True,
    socket_connect_timeout=2,
    socket_timeout=2,
)


@app.get("/")
def index():
    try:
        visits = redis_client.incr("visits")
    except RedisError:
        app.logger.exception("Could not increment the visit counter in Redis")
        return "Сховище тимчасово недоступне\n", 503

    return f"Заняття 2.6: Docker Compose. Кількість відвідувань: {visits}\n"


@app.get("/health")
def health():
    try:
        redis_client.ping()
    except RedisError:
        app.logger.exception("Redis health check failed")
        return jsonify(status="unhealthy", redis="unavailable"), 503

    return jsonify(status="healthy", redis="available")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
