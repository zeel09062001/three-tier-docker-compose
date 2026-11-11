# three-tier-docker-compose

In production, I’d replace the MySQL container with Amazon RDS, for managed backups and failover

os.environ["DB_HOST"]: if the variable is missing, the program stops immediately with a clear error. We use this for required settings, because it’s better for the container to refuse to start than to start and fail mysteriously later. This is called failing fast.

use   cur.execute(
                "INSERT INTO notes (title, content) VALUES (%s, %s)",
                (title.strip(), content.strip()),
            ) - to prevent sql injection - '); DROP TABLE notes; --,

LEAST PRIVILEGE
# 6. Create an ordinary user, and stop running as root
RUN useradd --create-home --uid 10001 appuser
USER appuser

On EC2, you’ll set PUBLIC_BIND_ADDRESS=0.0.0.0 in the server’s .env, so it’s reachable from the internet (through the security group).