cat >$HOME/.docker/config.json <<EOL
{
  "psFormat": "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}"
}
EOL
