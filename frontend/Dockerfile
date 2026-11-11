# ---------------------------------------------------------------------------
# Frontend image: UNPRIVILEGED Nginx (runs as a normal user, not root)
# + our config + our website files
# ---------------------------------------------------------------------------
FROM nginxinc/nginx-unprivileged:1.27-alpine

# Replace the default site settings with ours
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add the website files
COPY html/ /usr/share/nginx/html/

EXPOSE 8080