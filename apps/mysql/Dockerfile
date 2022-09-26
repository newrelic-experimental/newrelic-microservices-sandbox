#FROM mysql
FROM mariadb:jammy

COPY ./01_customers.sql.gz /docker-entrypoint-initdb.d/01_customers.sql.gz
COPY ./02_tokens.sql.gz /docker-entrypoint-initdb.d/02_tokens.sql.gz

CMD [ "--bind-address=0.0.0.0", "--default-authentication-plugin=mysql_native_password" ]
