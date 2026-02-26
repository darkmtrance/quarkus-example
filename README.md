# Quarkus Hello API - Azure Workshop

API REST de ejemplo construida con Quarkus para demostrar CI/CD con GitHub Actions y Azure Container Registry.

## 🚀 Quick Start

### Requisitos
- Java 17+
- Maven 3.8+
- Docker (opcional)

### Ejecutar en modo desarrollo

```bash
mvn quarkus:dev
```

La aplicación estará disponible en `http://localhost:8080`

### Endpoints disponibles

- `GET /api/hello` - Mensaje de bienvenida
- `GET /api/health` - Estado de salud
- `GET /api/info` - Información de la aplicación
- `GET /health` - Health check de Quarkus

### Ejemplo de uso

```bash
curl http://localhost:8080/api/hello
```

Respuesta:
```json
{
  "content": "¡Hola desde Quarkus!",
  "timestamp": "2026-02-25T10:30:45.123",
  "version": "1.0.0"
}
```

## 🔨 Build

### Compilar JAR

```bash
mvn clean package
```

### Ejecutar JAR

```bash
java -jar target/quarkus-app/quarkus-run.jar
```

### Compilar modo nativo (requiere GraalVM)

```bash
mvn package -Pnative
```

## 🐳 Docker

### Build imagen

```bash
docker build -f Dockerfile.multistage -t quarkus-hello-api:latest .
```

### Ejecutar contenedor

```bash
docker run -p 8080:8080 quarkus-hello-api:latest
```

### Build imagen nativa (más pequeña y rápida)

```bash
docker build -f Dockerfile.native -t quarkus-hello-api:native .
```

## 🧪 Testing

### Ejecutar tests

```bash
mvn test
```

### Ejecutar tests con reporte de cobertura

```bash
mvn verify
```

## 📦 Estructura del Proyecto

```
.
├── src/
│   ├── main/
│   │   ├── java/com/workshop/
│   │   │   ├── HelloResource.java
│   │   │   └── model/
│   │   │       └── Message.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/workshop/
│           └── HelloResourceTest.java
├── Dockerfile.multistage
├── Dockerfile.native
├── .dockerignore
└── pom.xml
```

## 🔧 Configuración

La configuración de la aplicación se encuentra en `src/main/resources/application.properties`:

- Puerto HTTP: 8080
- CORS habilitado
- Health checks en `/health`
- Logging nivel INFO

## 📚 Documentación

- [Guía completa del workshop](../workshop-quarkus-azure-acr.md)
- [Quarkus Documentation](https://quarkus.io/guides/)
- [Azure Container Registry](https://docs.microsoft.com/azure/container-registry/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es parte de un workshop educativo.

## ⚡ Performance

### JAR Mode
- Tiempo de inicio: ~1-2 segundos
- Memoria: ~50-100 MB
- Tamaño imagen: ~400 MB

### Native Mode
- Tiempo de inicio: ~0.016 segundos
- Memoria: ~20-30 MB
- Tamaño imagen: ~150 MB

## 🔍 Troubleshooting

### Error: Puerto 8080 ocupado

```bash
# Cambiar puerto en application.properties
quarkus.http.port=8081
```

### Error: Tests fallan

```bash
# Limpiar y recompilar
mvn clean install
```

### Error: Docker build falla

```bash
# Limpiar imágenes y caché
docker system prune -a
docker build --no-cache -f Dockerfile.multistage -t quarkus-hello-api:latest .
```

## 💡 Próximos Pasos

1. Agregar más endpoints REST
2. Integrar con base de datos
3. Agregar autenticación JWT
4. Implementar métricas con Prometheus
5. Agregar OpenAPI/Swagger
6. Desplegar en Azure Container Instances
7. Configurar Azure Application Insights

---

**Creado para Azure Workshop - Febrero 2026**
