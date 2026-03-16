# Instalación de Docker — Windows y Ubuntu

Guía de referencia para instalar Docker correctamente en entornos de desarrollo.  
Cubre Windows con WSL2 y Ubuntu Server (20.04 / 22.04 / 24.04 LTS).

---

## Índice

1. [Instalación en Windows](#instalacion-windows)
2. [Instalación en Ubuntu](#instalacion-ubuntu)
3. [Verificación final](#verificacion)
4. [Comandos esenciales](#comandos)
5. [Solución de problemas](#problemas)

---

## 1. Instalación en Windows {#instalacion-windows}

### Requisitos del sistema

| Requisito | Valor mínimo |
|---|---|
| Sistema operativo | Windows 10 build 19041 o Windows 11 |
| RAM | 4 GB (8 GB recomendado para Odoo) |
| Virtualización | Habilitada en BIOS (Intel VT-x / AMD SVM) |

### Verificar versión de Windows

Ejecuta en PowerShell:

```powershell
winver
```

Debe mostrar build 19041 o superior.

### Verificar virtualización

Abre el Administrador de tareas, ve a la pestaña **Rendimiento > CPU** y confirma que dice `Virtualización: Habilitada`.

Si dice deshabilitada, entra al BIOS de tu equipo y activa la opción `Intel VT-x` (Intel) o `SVM Mode` (AMD).

---

### Paso 1 — Instalar WSL2

Abre PowerShell como Administrador y ejecuta:

```powershell
wsl --install
```

Reinicia el equipo. Luego verifica:

```powershell
wsl --status
```

Debe mostrar `Default Version: 2`. Si no:

```powershell
wsl --set-default-version 2
```

---

### Paso 2 — Instalar Docker Desktop

1. Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop
2. Ejecuta el instalador y marca estas opciones:
   - `Enable WSL 2 based engine`
   - `Use recommended settings`
3. Reinicia el equipo si lo solicita.

---

### Paso 3 — Configurar recursos

Abre Docker Desktop y ve a **Settings > Resources > Advanced**. Configura:

| Recurso | Valor recomendado |
|---|---|
| CPU | 2 a 4 núcleos |
| RAM | 4 GB mínimo / 8 GB para Odoo |
| Swap | 2 GB |

Luego en **Settings > Resources > WSL Integration**, activa la integración con tu distribución Ubuntu.

---

### Paso 4 — Verificar instalación

```powershell
docker --version
docker compose version
docker run hello-world
```

Si el último comando muestra `Hello from Docker!`, la instalación es correcta.

---

### Recomendacion de flujo de trabajo en Windows

Para un entorno profesional, trabaja siempre dentro de WSL2 (Ubuntu), no desde rutas de Windows como `C:\Users\...`.

Abre Ubuntu desde el menu de inicio o ejecuta `wsl` en PowerShell, y trabaja en:

```bash
cd ~
mkdir proyectos
cd proyectos
```

Esto simula un entorno Linux real, equivalente a un servidor de producción.

---

## 2. Instalación en Ubuntu {#instalacion-ubuntu}

Compatible con Ubuntu 20.04, 22.04 y 24.04 LTS.

### Paso 1 — Verificar versión del sistema

```bash
lsb_release -a
```

---

### Paso 2 — Eliminar versiones antiguas

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

---

### Paso 3 — Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

### Paso 4 — Instalar dependencias

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

---

### Paso 5 — Agregar la clave GPG oficial de Docker

```bash
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

---

### Paso 6 — Agregar el repositorio oficial de Docker

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
```

---

### Paso 7 — Instalar Docker Engine

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

### Paso 8 — Iniciar y habilitar el servicio

```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```

---

### Paso 9 — Ejecutar Docker sin sudo

Agrega tu usuario al grupo `docker`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

> Es necesario cerrar sesión y volver a entrar para que el cambio surta efecto permanentemente.

---

### Paso 10 — Verificar instalación

```bash
docker --version
docker compose version
docker run hello-world
```

---

## 3. Verificación Final {#verificacion}

Ejecuta los siguientes comandos en cualquier plataforma para confirmar que todo funciona:

```bash
# Version de Docker
docker --version

# Version de Docker Compose (debe ser v2, sin guion)
docker compose version

# Contenedor de prueba
docker run hello-world
```

Resultado esperado del ultimo comando:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## 4. Comandos Esenciales {#comandos}

```bash
# Ver contenedores activos
docker ps

# Ver todos los contenedores (incluidos detenidos)
docker ps -a

# Ver imagenes descargadas
docker images

# Eliminar contenedores detenidos e imagenes sin uso
docker system prune -f

# Ver logs de un contenedor
docker logs nombre_contenedor

# Entrar a un contenedor
docker exec -it nombre_contenedor bash
```

---

## 5. Solucion de Problemas {#problemas}

### "permission denied" al ejecutar docker

El usuario no pertenece al grupo `docker`. Ejecuta:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verifica con:

```bash
groups
```

Debe aparecer `docker` en la lista.

---

### "docker: command not found" en Windows

Cierra la terminal y vuelve a abrirla. Si persiste, verifica que Docker Desktop esté abierto (icono de ballena en la barra de tareas).

---

### "WSL 2 installation is incomplete"

```powershell
wsl --update
```

---

### Docker no inicia en Ubuntu

Revisa los logs del servicio:

```bash
sudo journalctl -u docker
```

---

### Docker no inicia en Windows

Abre Docker Desktop y ve a **Troubleshoot > View logs**.

---

## Notas importantes

- Docker Compose v2 se invoca como `docker compose` (sin guion). El comando `docker-compose` (con guion) es la version antigua y ya no debe usarse.
- En servidores de produccion, no ejecutes Docker como root.
- Usa siempre imagenes con versiones fijas (ejemplo: `postgres:15`, no `postgres:latest`) para garantizar reproducibilidad.
- Para proyectos en Windows, trabaja siempre desde WSL2, no desde rutas de Windows, para evitar problemas de permisos y compatibilidad.
