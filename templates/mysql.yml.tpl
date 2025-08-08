apiVersion: 1

datasources:
  - name: MySQL-Grafana
    type: mysql
    access: proxy
    isDefault: true
    editable: true
    url: mysql:3306
    database: ${GRAFANA_DB}
    user: ${GRAFANA_DB_USER}
    secureJsonData:
      password: ${GRAFANA_DB_PASSWORD}
    jsonData:
      tlsSkipVerify: true
