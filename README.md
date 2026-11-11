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

time docker compose up -d --build --wait
docker compose up -d --build --wait  0.24s user 0.28s system 23% cpu 2.221 total

zeelshekhaliya@Mac three-tier-docker-compose % docker compose logs --timestamps \
  | grep -E "ready for connections|Booting worker|start worker process" \
  | sort -t'|' -k2
db-1        | 2026-11-11T17:44:08.265714715Z 2026-11-11T17:44:08.265651Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Socket: /var/run/mysqld/mysqlx.sock
db-1        | 2026-11-11T17:44:08.265750048Z 2026-11-11T17:44:08.265709Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.4.13'  socket: '/var/run/mysqld/mysqld.sock'  port: 0  MySQL Community Server - GPL.
db-1        | 2026-11-11T17:44:10.385849424Z 2026-11-11T17:44:10.385785Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
db-1        | 2026-11-11T17:44:10.385868382Z 2026-11-11T17:44:10.385840Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.4.13'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
backend-1  | 2026-11-11T17:44:15.415032760Z [2026-11-11 17:44:15 +0000] [7] [INFO] Booting worker with pid: 7
backend-1  | 2026-11-11T17:44:15.456183260Z [2026-11-11 17:44:15 +0000] [8] [INFO] Booting worker with pid: 8
frontend-1  | 2026-11-11T17:44:20.803958054Z 2026/11/11 17:44:20 [notice] 1#1: start worker processes
frontend-1  | 2026-11-11T17:44:20.804018012Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 29
frontend-1  | 2026-11-11T17:44:20.804079304Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 30
frontend-1  | 2026-11-11T17:44:20.804266596Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 31
frontend-1  | 2026-11-11T17:44:20.804281054Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 32
frontend-1  | 2026-11-11T17:44:20.804524929Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 33
frontend-1  | 2026-11-11T17:44:20.804528012Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 34
frontend-1  | 2026-11-11T17:44:20.804528929Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 35
frontend-1  | 2026-11-11T17:44:20.804610512Z 2026/11/11 17:44:20 [notice] 1#1: start worker process 36
db-1        | 2026-11-11T19:49:40.509814878Z 2026-11-11T19:49:40.509736Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
db-1        | 2026-11-11T19:49:40.509831044Z 2026-11-11T19:49:40.509800Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.4.13'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
db-1        | 2026-11-11T19:49:57.278406386Z 2026-11-11T19:49:57.278327Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
db-1        | 2026-11-11T19:49:57.278412302Z 2026-11-11T19:49:57.278366Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.4.13'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
backend-1   | 2026-11-11T20:10:49.596261465Z [2026-11-11 20:10:49 +0000] [7] [INFO] Booting worker with pid: 7
backend-1   | 2026-11-11T20:10:49.693734924Z [2026-11-11 20:10:49 +0000] [8] [INFO] Booting worker with pid: 8
backend-1   | 2026-11-11T20:26:31.721793221Z [2026-11-11 20:26:31 +0000] [7] [INFO] Booting worker with pid: 7
backend-1   | 2026-11-11T20:26:31.791870138Z [2026-11-11 20:26:31 +0000] [8] [INFO] Booting worker with pid: 8
zeelshekhaliya@Mac three-tier-docker-compose % 


zeelshekhaliya@Mac three-tier-docker-compose % docker stats --no-stream
CONTAINER ID   NAME                                   CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
198bf34cd9bc   three-tier-docker-compose-frontend-1   0.00%     8.59MiB / 3.825GiB    0.22%     38.6kB / 49.3kB   0B / 8.19kB       9
1384a3bde702   three-tier-docker-compose-backend-1    0.03%     58.79MiB / 3.825GiB   1.50%     251kB / 217kB     0B / 0B           3
09d8e3b63132   three-tier-docker-compose-db-1         3.95%     463.5MiB / 3.825GiB   11.84%    912kB / 1.05MB    31.2MB / 17.4MB   35
zeelshekhaliya@Mac three-tier-docker-compose % 



