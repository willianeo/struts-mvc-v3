FROM debian:stable-slim

WORKDIR /app

# Instala dependências básicas
RUN apt-get update && apt-get install -y \
    libx11-6 \
    unzip \
    tar \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copia os arquivos necessários para dentro do container
COPY jdk-6-linux-amd64.bin /app/
COPY apache-ant-1.8.0-bin.tar.gz /app/
COPY . /app/

# Instala o JDK 6 manualmente
RUN chmod +x jdk-6-linux-amd64.bin && \
    echo "yes" | ./jdk-6-linux-amd64.bin && mv jdk1.6.0 java6 && \
    rm jdk-6-linux-amd64.bin

# Define as variáveis de ambiente do Java
ENV JAVA_HOME=/app/java6
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar

# Instala o Ant manualmente
RUN tar -xzf apache-ant-1.8.0-bin.tar.gz && \
    rm apache-ant-1.8.0-bin.tar.gz

# Define as variáveis de ambiente do Ant
ENV ANT_HOME=/app/apache-ant-1.8.0
ENV PATH="${ANT_HOME}/bin:${PATH}"

# Baixa e instala o Tomcat manualmente
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.tar.gz && \
    tar -xzf apache-tomcat-6.0.53.tar.gz && \
    mv apache-tomcat-6.0.53 tomcat && \
    rm apache-tomcat-6.0.53.tar.gz

# Define as variáveis de ambiente do Tomcat
ENV CATALINA_HOME=/app/tomcat
ENV PATH="${CATALINA_HOME}/bin:${PATH}"

# Verifica as versões instaladas
RUN java -version && ant -version

# Constrói o projeto
RUN ant clean && ant

# Copia o WAR para o Tomcat
RUN cp dist/*.war $CATALINA_HOME/webapps/

# Expõe a porta do Tomcat
EXPOSE 8080

# Comando para iniciar o Tomcat
CMD ["/app/tomcat/bin/catalina.sh", "run"]
