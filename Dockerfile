# Basis: Offizielles Piston Image
FROM ghcr.io/engineer-man/piston:latest

# Arbeitsverzeichnis auf /tmp setzen (beschreibbar bei Render)
WORKDIR /tmp

# Starte Piston explizit aus seinem Installationspfad
CMD ["node", "/piston/index.js"]
