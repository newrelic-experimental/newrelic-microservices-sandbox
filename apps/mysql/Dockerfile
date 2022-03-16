FROM mysql

COPY ./01_customers.sql.gz /docker-entrypoint-initdb.d/01_customers.sql.gz
COPY ./02_tokens.sql.gz /docker-entrypoint-initdb.d/02_tokens.sql.gz

CMD [ "--default-authentication-plugin=mysql_native_password" ]