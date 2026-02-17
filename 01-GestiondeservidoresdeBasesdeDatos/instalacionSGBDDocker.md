# Contenedor de SQL Server sin volumen

``` shell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1435:1433 --name servidordesqlserver  \
   -d \
   mcr.microsoft.com/mssql/server:2019-latest
```