# Prevención de Apagones.

Breve descripción de qué hace el sistema (1–2 líneas) y qué problema resuelve.

## Requisitos previos
* **Java JDK** 
* **Apache NetBeans** (con soporte para proyectos Ant)
* **PostgreSQL** (servidor instalado y corriendo, con **pgAdmin** o terminal `psql`)
* **Driver JDBC de PostgreSQL** (el proyecto ya viene con el .jar, sin embargo si hay un fallo de conexión eliminelo y descargue el .jar de la web)

---

## Pasos para correr el proyecto

### 1. Crear la base de datos y las tablas
1. Abre **pgAdmin** (o conéctate desde consola con `psql`).
2. Crea una base de datos ( nombre : `cfe`) si el script no la crea automáticamente.
3. Ejecuta el script de estructura/tablas incluido en este repositorio ('script_bd.sql').
4. **Verificación:** Revisa en el árbol de objetos de PostgreSQL que las tablas y relaciones se hayan creado sin errores.

### 2. Insertar datos de prueba (datos ficticios)
1. Sobre la misma base de datos creada en el paso anterior, ejecuta el script de poblado/datos de prueba ('datos_prueba.sql').
2. **Verificación:** Haz una consulta rápida (`SELECT * FROM ...;`) para confirmar que existan registros de prueba.

### 3. Configurar la conexión a PostgreSQL
1. Abre el archivo de configuración o la clase donde se define la conexión JDBC ('Conexion.java').
2. Ajusta los valores según tu entorno local:
   * **URL / Host / Puerto:** `jdbc:postgresql://localhost:5432/cfe`
   * **Usuario:** tu usuario de PostgreSQL
   * **Contraseña:** tu contraseña de PostgreSQL

### 4. Abrir y ejecutar en Apache NetBeans
1. Extrae el archivo `.zip` del proyecto en una carpeta local sin espacios raros o rutas muy largas.
2. En **Apache NetBeans**, ve a **File > Open Project...**, selecciona la carpeta del proyecto descomprimido y ábrela.
3. Si NetBeans marca algún faltante en **Libraries** (como el driver de PostgreSQL), haz clic derecho en **Libraries > Add JAR/Folder...** y selecciona el `.jar` correspondiente.
4. Ejecuta el proyecto con **Run Project (F6)** o ejecuta la clase principal (`Run File`).
5. **Verificación:** Comprueba en la consola de NetBeans que la conexión a PostgreSQL se estableció sin excepciones `SQLException` y que la interfaz o flujo principal arranca correctamente.
