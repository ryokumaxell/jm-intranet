# Sistema de Permisos - J-Intranet

## Roles y Permisos

El sistema tiene tres roles principales con diferentes niveles de acceso:

### 1. **Súper Administrador** (`super`)

**Descripción**: Acceso total al sistema. Puede gestionar todo.

**Permisos**:
- ✅ Ver y editar todos los usuarios
- ✅ Crear nuevos usuarios
- ✅ Asignar roles a otros usuarios
- ✅ Gestionar compañías (Jaysa Muebles, Helaco)
- ✅ Gestionar empleados
- ✅ Ver registros de asistencia de todas las compañías
- ✅ Crear y editar solicitudes
- ✅ Acceso a todas las secciones del sistema
- ✅ Cambiar configuración global

**Casos de uso**:
- Propietarios del negocio
- Directores generales
- Administradores del sistema

---

### 2. **Administrador** (`admin`)

**Descripción**: Acceso administrativo. Puede gestionar usuarios y datos operativos.

**Permisos**:
- ✅ Ver y editar usuarios (excepto otros administradores)
- ✅ Crear nuevos usuarios
- ✅ Gestionar empleados
- ✅ Ver registros de asistencia de sus compañías asignadas
- ✅ Crear y editar solicitudes
- ✅ Acceso a panel principal, empleados, asistencia, solicitudes
- ❌ NO puede cambiar roles de otros administradores
- ❌ NO puede ver usuarios de compañías no asignadas

**Casos de uso**:
- Gerentes de recursos humanos
- Supervisores de departamento
- Coordinadores administrativos

---

### 3. **Usuario** (`user`)

**Descripción**: Acceso limitado. Solo puede ver información relevante a su rol.

**Permisos**:
- ✅ Ver su propio perfil
- ✅ Ver registros de asistencia de sus compañías asignadas
- ✅ Ver empleados de sus compañías
- ✅ Crear solicitudes (vacaciones, permisos, etc.)
- ✅ Ver sus propias solicitudes
- ❌ NO puede crear usuarios
- ❌ NO puede editar otros usuarios
- ❌ NO puede ver información de compañías no asignadas
- ❌ NO puede editar registros de asistencia

**Casos de uso**:
- Empleados regulares
- Coordinadores operativos
- Personal administrativo sin permisos de gestión

---

## Acceso por Compañía

Cada usuario tiene acceso a una o más compañías:

- **Jaysa Muebles**: Compañía de muebles
- **Helaco**: Compañía de distribución

Un usuario solo puede ver:
- Empleados de sus compañías asignadas
- Registros de asistencia de sus compañías asignadas
- Información relevante a sus compañías

---

## Matriz de Permisos

| Acción | Super Admin | Admin | Usuario |
|--------|:-----------:|:-----:|:-------:|
| Ver todos los usuarios | ✅ | ❌ | ❌ |
| Crear usuarios | ✅ | ✅ | ❌ |
| Editar usuarios | ✅ | ✅ | Solo su perfil |
| Ver empleados | ✅ | ✅ | Solo sus compañías |
| Editar empleados | ✅ | ✅ | ❌ |
| Ver asistencia | ✅ | ✅ | Solo sus compañías |
| Editar asistencia | ✅ | ✅ | ❌ |
| Ver solicitudes | ✅ | ✅ | Solo las suyas |
| Crear solicitudes | ✅ | ✅ | ✅ |
| Aprobar solicitudes | ✅ | ✅ | ❌ |
| Cambiar configuración | ✅ | ❌ | ❌ |

---

## Ejemplo de Configuración

### Usuario: mmateo@jaysa.com
- **Rol**: Usuario
- **Compañías**: Helaco
- **Permisos**: 
  - Solo ve empleados de Helaco
  - Solo ve asistencia de Helaco
  - Puede ver su propio perfil
  - Puede crear solicitudes

### Usuario: admin@jaysa.com
- **Rol**: Administrador
- **Compañías**: Jaysa Muebles, Helaco
- **Permisos**:
  - Ve y edita empleados de ambas compañías
  - Ve asistencia de ambas compañías
  - Puede crear nuevos usuarios
  - Puede editar perfiles de usuarios regulares

### Usuario: super@jaysa.com
- **Rol**: Súper Administrador
- **Compañías**: Todas
- **Permisos**:
  - Acceso total al sistema
  - Puede gestionar todos los usuarios
  - Puede cambiar roles
  - Puede modificar configuración global
